import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import FolioCueDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var state = FolioCueState()
    @Published var path: [FolioCueRoute] = []
    @Published var statusMessage: String?
    @Published var statusIsError = false
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var identifyBusy = false
    @Published var coachBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var showCamera = false
    @Published var showVoiceNote = false
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var aiUnavailableReason: String?
    @Published var activeSessionId: String?
    @Published var legalPageName = "privacy"
    @Published var captureKind = "cover"
    @Published var editTitleDraft = ""
    @Published var editProgressDraft = 0

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<FolioCueRoutePayload>
    let tts = TTSPlayer()
    let speechService = SpeechRecognitionService()
    let voiceRecorder = VoiceNoteRecorder()

    private let shelfStore: ShelfStore
    private let supportRoot: URL
    private let photosRoot: URL
    private let audioRoot: URL
    private let cardsRoot: URL
    private let keychain = FolioCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingAIAction: (() -> Void)?
    private var importGeneration = 0

    var activeSession: ShelfSession? {
        guard let id = activeSessionId else { return state.sessions.first }
        return state.sessions.first(where: { $0.id == id })
    }

    var activeBookID: BookID? {
        guard let id = activeSession?.id else { return nil }
        return state.bookIDs.first(where: { $0.sessionId == id })
    }

    var activeProgress: ReadingProgress? {
        guard let id = activeSession?.id else { return nil }
        return state.readingProgress.first(where: { $0.sessionId == id })
    }

    var activeCapture: CoverCapture? {
        guard let id = activeSession?.id else { return nil }
        return state.captures.first(where: { $0.sessionId == id })
    }

    var activeShelfCard: ShelfCardAnnotation? {
        guard let id = activeSession?.id else { return nil }
        return state.shelfCards.first(where: { $0.sessionId == id })
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeSession?.id else { return [] }
        return state.coachTurns.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var confirmedBookNotes: [String] {
        state.sessions.filter { $0.status == "confirmed" }.compactMap { session in
            state.bookIDs.first(where: { $0.sessionId == session.id }).map { book in
                let progress = state.readingProgress.first(where: { $0.sessionId == session.id })
                let pct = progress.map { "\($0.state) \($0.percent)%" } ?? "tbr"
                return "\(book.title) by \(book.author) [\(pct)]"
            }
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("foliocue", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        photosRoot = root.appendingPathComponent("photos", isDirectory: true)
        audioRoot = root.appendingPathComponent("audio", isDirectory: true)
        cardsRoot = root.appendingPathComponent("cards", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: audioRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: cardsRoot, withIntermediateDirectories: true)

        shelfStore = ShelfStore(directory: root)
        navigation = TypedNavigationStore(
            url: FolioCueStores.storeURL(directory: root, name: FolioCueStores.navigationFile),
            isValid: { FolioCueRoute.allCases.contains($0.route) }
        )

        let consentURL = FolioCueStores.storeURL(directory: root, name: FolioCueStores.aiConsentLocal)
        consentGate = AIConsentContract.makeGate(
            load: {
                guard FileManager.default.fileExists(atPath: consentURL.path) else { return nil }
                return try JSONDecoder().decode(AIConsentGate.State.self, from: Data(contentsOf: consentURL))
            },
            persist: { gateState in
                let data = try JSONEncoder().encode(gateState)
                try data.write(to: consentURL, options: .atomic)
                let mirror = AIConsentRecord(
                    provider: AIConsentContract.provider,
                    disclosureVersion: gateState.disclosureVersion,
                    grantedAt: Date(),
                    revokedAt: gateState.granted ? nil : Date()
                )
                let mirrorData = try JSONEncoder().encode(mirror)
                Task { try? await FolioCueStores.consentKeychainStore().save(mirrorData) }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        if ProcessInfo.processInfo.arguments.contains("-uitest-seed") {
            seedUITestShelfIfNeeded()
        }
        if let restored = try? navigation.restore(), !restored.isEmpty {
            path = restored.map(\.route)
        }
        Task { await self.loadAPIKeyFromKeychain() }
        refreshAIAvailability()
    }

    /// Simulator/UITest-only seed so core shelf flows can be exercised without camera hardware.
    private func seedUITestShelfIfNeeded() {
        state = FolioCueState()
        let id = "uitest-session"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 480)).image { ctx in
            UIColor(red: 0.024, green: 0.373, blue: 0.275, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 320, height: 480))
            UIColor(red: 0.996, green: 0.953, blue: 0.780, alpha: 1).setFill()
            ctx.fill(CGRect(x: 40, y: 80, width: 240, height: 320))
        }
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        let url = photosRoot.appendingPathComponent("\(id).jpg")
        try? data.write(to: url, options: .atomic)
        let session = ShelfSession(
            id: id,
            createdAt: Date(),
            source: "photos",
            status: "draft",
            shelfNote: "uitest",
            disclaimerAck: true
        )
        let capture = CoverCapture(
            sessionId: id,
            captureKind: "cover",
            photoLocalURL: url.path,
            capturedAt: Date()
        )
        state.sessions = [session]
        state.captures = [capture]
        activeSessionId = id
        persist()
    }

    private func loadAPIKeyFromKeychain() async {
        if let data = try? await keychain.load(),
           let key = String(data: data, encoding: .utf8),
           !key.isEmpty {
            cachedAPIKey = key
        }
        refreshAIAvailability()
    }

    func reload() {
        state = (try? shelfStore.load()) ?? FolioCueState()
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = state.sessions.first?.id
        }
        if let book = activeBookID {
            editTitleDraft = book.title
        }
        editProgressDraft = activeProgress?.percent ?? 0
    }

    func persist() {
        try? shelfStore.save(state)
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI not configured — local shelf still works."
        } else if !consentGate.state.granted {
            aiUnavailableReason = "AI unavailable until you allow data sharing."
        } else {
            aiUnavailableReason = nil
        }
    }

    func apiKey() -> String? {
        if let key = cachedAPIKey, !key.isEmpty { return key }
        if let env = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY") as? String,
           !env.isEmpty, env != "$(DEEPSEEK_API_KEY)" {
            return env
        }
        return nil
    }

    func persistNavigation() {
        let payloads = path.map { FolioCueRoutePayload(route: $0, sessionId: activeSessionId) }
        try? navigation.save(payloads)
    }

    func push(_ route: FolioCueRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    func setBanner(_ text: String, error: Bool = false) {
        statusMessage = text
        statusIsError = error
    }

    func setTTSEnabled(_ enabled: Bool) {
        state.settings.ttsEnabled = enabled
        persist()
    }

    func setSpeechEnabled(_ enabled: Bool) {
        state.settings.speechInputEnabled = enabled
        persist()
    }

    // MARK: - Capture / Import

    func saveImage(_ image: UIImage, source: String) {
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            setBanner("Could not encode photo.", error: true)
            return
        }
        let id = UUID().uuidString
        let url = photosRoot.appendingPathComponent("\(id).jpg")
        do {
            try data.write(to: url, options: .atomic)
            let session = ShelfSession(
                id: id,
                createdAt: Date(),
                source: source,
                status: "draft",
                shelfNote: nil,
                disclaimerAck: true
            )
            let capture = CoverCapture(
                sessionId: id,
                captureKind: captureKind,
                photoLocalURL: url.path,
                capturedAt: Date()
            )
            state.sessions.insert(session, at: 0)
            state.captures.removeAll { $0.sessionId == id }
            state.captures.append(capture)
            activeSessionId = id
            persist()
            setBanner(source == "camera" ? "Cover/spine still captured." : "Library still imported.")
            push(.bookIdResult)
        } catch {
            setBanner("Save failed: \(error.localizedDescription)", error: true)
        }
    }

    func handleCameraImage(_ image: UIImage) {
        showCamera = false
        saveImage(image, source: "camera")
    }

    func handlePhotoImport() {
        guard let item = selectedPhotoItem else { return }
        importGeneration += 1
        let generation = importGeneration
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    setBanner("Could not decode album still.", error: true)
                    return
                }
                guard generation == importGeneration else {
                    setBanner("Late picker result rejected after cancel.")
                    return
                }
                saveImage(image, source: "photos")
            } catch {
                setBanner("Import failed: \(error.localizedDescription)", error: true)
            }
            selectedPhotoItem = nil
        }
    }

    func cancelPhotoImport() {
        importGeneration += 1
        selectedPhotoItem = nil
    }

    // MARK: - Identify

    func requestIdentify() {
        guard activeSession != nil else { return }
        runWithConsent { [weak self] in
            Task { await self?.performIdentify() }
        }
    }

    private func performIdentify() async {
        guard let session = activeSession else { return }
        guard let key = apiKey() else {
            // Honest unconfigured: local placeholder ID for shelf smoke, not claimed as live AI.
            let local = BookID(
                sessionId: session.id,
                title: "Untitled shelf volume",
                author: "Unknown author",
                editionHint: "local-only",
                confidence: 0.35,
                rationale: "AI not configured. Local draft ID only — confirm to keep on your personal shelf.",
                complianceBanner: FolioCueCompliance.personalBookshelfCoach
            )
            applyIdentified(book: local, sessionId: session.id, banner: "AI not configured — local draft ID ready.", error: true)
            return
        }
        identifyBusy = true
        setBanner("Reading cover / spine…")
        defer { identifyBusy = false }
        do {
            let permit = try consentGate.permit()
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                try self.consentGate.validate(permit)
            }
            let photoName = activeCapture.map { URL(fileURLWithPath: $0.photoLocalURL).lastPathComponent } ?? "none"
            let payload = try await client.identifyBook(
                sessionId: session.id,
                photoDescriptor: "local_cover_spine_still:\(photoName)",
                captureKind: activeCapture?.captureKind ?? captureKind,
                confirmedNotes: confirmedBookNotes,
                question: "Identify this personal shelf book from cover/spine"
            )
            try consentGate.validate(permit)
            applyIdentified(book: payload.book, sessionId: session.id, banner: "Book ID ready on the cover card.")
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    private func applyIdentified(book: BookID, sessionId: String, banner: String, error: Bool = false) {
        state.bookIDs.removeAll { $0.sessionId == sessionId }
        state.bookIDs.append(book)
        if let idx = state.sessions.firstIndex(where: { $0.id == sessionId }) {
            state.sessions[idx].status = "identified"
        }
        if state.readingProgress.first(where: { $0.sessionId == sessionId }) == nil {
            state.readingProgress.append(
                ReadingProgress(sessionId: sessionId, state: "tbr", percent: 0, updatedAt: Date())
            )
        }
        let spine = SpineRailItem(
            bookId: sessionId,
            spineLabel: String(book.title.prefix(18)),
            coverThumbURL: activeCapture?.photoLocalURL,
            position: state.spineRail.count,
            shelfLane: "home"
        )
        state.spineRail.removeAll { $0.bookId == sessionId }
        state.spineRail.append(spine)
        editTitleDraft = book.title
        editProgressDraft = activeProgress?.percent ?? 0
        persist()
        setBanner(banner, error: error)
        refreshAIAvailability()
    }

    func saveToShelf() {
        guard let session = activeSession,
              let idx = state.sessions.firstIndex(where: { $0.id == session.id }),
              activeBookID != nil else { return }
        if !editTitleDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let bidx = state.bookIDs.firstIndex(where: { $0.sessionId == session.id }) {
            state.bookIDs[bidx].title = editTitleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
            let label = String(state.bookIDs[bidx].title.prefix(18))
            if let sidx = state.spineRail.firstIndex(where: { $0.bookId == session.id }) {
                state.spineRail[sidx].spineLabel = label
            }
        }
        if let pidx = state.readingProgress.firstIndex(where: { $0.sessionId == session.id }) {
            state.readingProgress[pidx].percent = min(100, max(0, editProgressDraft))
            state.readingProgress[pidx].updatedAt = Date()
            if state.readingProgress[pidx].percent > 0 && state.readingProgress[pidx].state == "tbr" {
                state.readingProgress[pidx].state = "reading"
            }
        }
        state.sessions[idx].status = "confirmed"
        persist()
        setBanner("Saved to personal shelf.")
    }

    func dismissID() {
        setBanner("Result dismissed — confirmed shelf unchanged.")
    }

    func markReadingState(_ value: String) {
        guard let session = activeSession else { return }
        if let pidx = state.readingProgress.firstIndex(where: { $0.sessionId == session.id }) {
            state.readingProgress[pidx].state = value
            if value == "reading" && state.readingProgress[pidx].percent == 0 {
                state.readingProgress[pidx].percent = 5
            }
            if value == "done" {
                state.readingProgress[pidx].percent = 100
            }
            state.readingProgress[pidx].updatedAt = Date()
            persist()
        }
    }

    // MARK: - Shelf card / TTS

    func buildShelfCard() {
        guard let session = activeSession, let book = activeBookID else {
            setBanner("Identify a book before annotating a shelf card.", error: true)
            return
        }
        let progress = activeProgress
        let callouts = [
            book.title,
            book.author,
            progress.map { "\($0.state) · \($0.percent)%" } ?? "tbr · 0%",
            FolioCueCompliance.personalBookshelfCoach,
        ]
        let path = cardsRoot.appendingPathComponent("\(session.id).txt")
        let body = callouts.joined(separator: "\n")
        try? body.write(to: path, atomically: true, encoding: .utf8)
        let card = ShelfCardAnnotation(
            sessionId: session.id,
            callouts: callouts,
            imageLocalURL: activeCapture?.photoLocalURL ?? path.path,
            generatedAt: Date()
        )
        state.shelfCards.removeAll { $0.sessionId == session.id }
        state.shelfCards.append(card)
        persist()
        setBanner("Annotated shelf card ready.")
        push(.shelfCard)
    }

    func speakFindCallout() {
        guard let session = activeSession, let book = activeBookID else {
            setBanner("No book to find yet.", error: true)
            return
        }
        guard state.settings.ttsEnabled else {
            setBanner("TTS disabled in Settings.", error: true)
            return
        }
        let lane = state.spineRail.first(where: { $0.bookId == session.id })?.shelfLane ?? "home"
        let script = """
        FolioCue find cue: \(book.title) by \(book.author) is on your \(lane) spine rail. \
        \(FolioCueCompliance.personalBookshelfCoach). \
        \(FolioCueCompliance.notBookstoreCatalogScraping). \
        \(FolioCueCompliance.notFullTextPiracyReader). \
        \(FolioCueCompliance.notHomeworkGrading).
        """
        let callout = FindCallout(
            sessionId: session.id,
            scriptText: script,
            spokenAt: Date(),
            ttsLocale: "en-US"
        )
        state.findCallouts.removeAll { $0.sessionId == session.id }
        state.findCallouts.append(callout)
        persist()
        tts.speak(script)
        setBanner("Speaking find-my-book callout.")
        push(.findCallout)
    }

    // MARK: - Coach

    func sendCoachQuestion(sttSource: Bool? = nil) {
        let text = (sttSource == true ? speechTranscript : coachQuestion)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let session = activeSession else { return }
        let strategy: String
        let lower = text.lowercased()
        if lower.contains("where") {
            strategy = "find"
        } else if lower.contains("reading") || lower.contains("mark") {
            strategy = "reading"
        } else {
            strategy = "tbr"
        }
        let userTurn = CoachTurn(
            sessionId: session.id,
            role: "user",
            text: text,
            strategy: strategy,
            sttSource: sttSource,
            createdAt: Date()
        )
        state.coachTurns.append(userTurn)
        persist()
        coachQuestion = ""
        if strategy == "reading" {
            markReadingState("reading")
        }
        runWithConsent { [weak self] in
            Task { await self?.performCoach(question: text, sessionId: session.id, strategy: strategy) }
        }
    }

    private func performCoach(question: String, sessionId: String, strategy: String) async {
        guard let key = apiKey() else {
            let local = CoachTurn(
                sessionId: sessionId,
                role: "coach",
                text: localCoachReply(question: question, strategy: strategy),
                strategy: strategy,
                sttSource: nil,
                createdAt: Date()
            )
            state.coachTurns.append(local)
            persist()
            setBanner("Local coach tip (no AI key).", error: true)
            return
        }
        coachBusy = true
        defer { coachBusy = false }
        do {
            let permit = try consentGate.permit()
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                try self.consentGate.validate(permit)
            }
            let reply = try await client.coachShelf(
                sessionId: sessionId,
                question: question,
                book: activeBookID,
                progress: activeProgress,
                confirmedNotes: confirmedBookNotes,
                strategy: strategy
            )
            try consentGate.validate(permit)
            state.coachTurns.append(
                CoachTurn(
                    sessionId: sessionId,
                    role: "coach",
                    text: reply.reply,
                    strategy: reply.strategy,
                    sttSource: nil,
                    createdAt: Date()
                )
            )
            persist()
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    private func localCoachReply(question: String, strategy: String) -> String {
        switch strategy {
        case "find":
            return "AI not configured. Check the spine rail lane for this title, then use Speak Find for a TTS cue. \(FolioCueCompliance.personalBookshelfCoach)."
        case "reading":
            return "AI not configured. Marked locally as reading — nudge yourself one chapter today. Not homework grading."
        default:
            return "AI not configured. For TBR: park this on the rail and pick the shortest unread next. Question remembered: \(question)"
        }
    }

    func startSpeechQuestion() {
        guard state.settings.speechInputEnabled else {
            setBanner("Speech input disabled in Settings.", error: true)
            return
        }
        Task {
            let status = await speechService.requestAuthorization()
            guard status == .authorized else {
                setBanner("Speech denied — typed chat still works.", error: true)
                return
            }
            speechService.transcript = ""
            speechService.start()
        }
    }

    func finishSpeechQuestion() {
        speechService.stop()
        speechTranscript = speechService.transcript
        if !speechTranscript.isEmpty {
            sendCoachQuestion(sttSource: true)
        }
    }

    // MARK: - Voice notes

    func startVoiceNote() {
        voiceRecorder.start(to: audioRoot)
    }

    func stopVoiceNote() {
        guard let url = voiceRecorder.stop() else { return }
        let note = VoiceNote(
            sessionId: activeSessionId,
            localAudioURL: url.path,
            transcript: nil,
            createdAt: Date()
        )
        state.voiceNotes.insert(note, at: 0)
        persist()
        setBanner("Voice shelf note saved.")
        showVoiceNote = false
    }

    // MARK: - Consent

    func runWithConsent(_ action: @escaping () -> Void) {
        refreshAIAvailability()
        if consentGate.state.granted {
            action()
            return
        }
        pendingAIAction = action
        showConsent = true
    }

    func grantConsentAndContinue() {
        do {
            try consentGate.grant()
            consentGranted = true
            state.settings.consentRevoked = false
            persist()
            showConsent = false
            refreshAIAvailability()
            let pending = pendingAIAction
            pendingAIAction = nil
            pending?()
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func dismissConsent() {
        showConsent = false
        pendingAIAction = nil
        setBanner("Local shelf still works without AI.", error: false)
        refreshAIAvailability()
    }

    func revokeAIConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            state.settings.consentRevoked = true
            persist()
            refreshAIAvailability()
            setBanner("AI consent revoked — outbound stopped.", error: true)
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func openLegal(_ page: String) {
        legalPageName = page
        push(.legal)
    }

    func selectSpineItem(_ item: SpineRailItem) {
        activeSessionId = item.bookId
        push(.bookIdResult)
    }
}
