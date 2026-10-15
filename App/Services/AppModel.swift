import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import SporeCueDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var state = SporeCueState()
    @Published var path: [SporeCueRoute] = []
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
    @Published var captureSubject = "gill"
    @Published var draftCallouts: [MorphologyCallout] = []

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<SporeCueRoute>
    let tts = TTSPlayer()
    let speechService = SpeechRecognitionService()
    let voiceRecorder = VoiceNoteRecorder()

    private let forageStore: ForageStore
    private let supportRoot: URL
    private let photosRoot: URL
    private let audioRoot: URL
    private let keychain = SporeCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingAIAction: (() -> Void)?
    private var importGeneration = 0

    var activeSession: ForageSession? {
        guard let id = activeSessionId else { return state.sessions.first }
        return state.sessions.first(where: { $0.id == id })
    }

    var sessionCandidates: [SpeciesCandidate] {
        guard let id = activeSession?.id else { return [] }
        return state.candidates.filter { $0.sessionId == id }.sorted { $0.rank < $1.rank }
    }

    var sessionChips: [CautionChip] {
        guard let id = activeSession?.id else { return [] }
        return state.chips.filter { $0.sessionId == id }
    }

    var sessionCallouts: [MorphologyCallout] {
        guard let id = activeSession?.id else { return [] }
        return state.callouts.filter { $0.sessionId == id }
    }

    var sessionOverlay: OverlayAnnotation? {
        guard let id = activeSession?.id else { return nil }
        return state.overlays.first(where: { $0.sessionId == id })
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeSession?.id else { return [] }
        return state.coachTurns.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var sessionBrief: FieldBrief? {
        guard let id = activeSession?.id else { return nil }
        return state.fieldBriefs.first(where: { $0.sessionId == id })
    }

    var confirmedSpeciesContext: [String] {
        state.sessions.filter { $0.status == "confirmed" }.compactMap { session in
            state.candidates
                .filter { $0.sessionId == session.id }
                .sorted { $0.rank < $1.rank }
                .first
                .map { candidate in
                    let sci = candidate.scientificName.map { " (\($0))" } ?? ""
                    return "\(candidate.displayName)\(sci)"
                }
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent(SporeCueStores.mediaDirectoryName, isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        photosRoot = root.appendingPathComponent("photos", isDirectory: true)
        audioRoot = root.appendingPathComponent("audio", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: audioRoot, withIntermediateDirectories: true)

        forageStore = ForageStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: SporeCueNavigation.isValid
        )

        let consentURL = SporeCueStores.storeURL(directory: root, name: SporeCueStores.aiConsentLocal)
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
                Task { try? await SporeCueStores.consentKeychainStore().save(mirrorData) }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        let uiSmokeReset = ProcessInfo.processInfo.arguments.contains("-ui-smoke-reset")
        if uiSmokeReset {
            path = []
            try? navigation.save([])
        } else if let restored = try? navigation.restore(), !restored.isEmpty {
            path = restored
        }
        Task { await self.loadAPIKeyFromKeychain() }
        refreshAIAvailability()
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
        state = (try? forageStore.load()) ?? SporeCueState()
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = state.sessions.first?.id
        }
    }

    func persist() {
        try? forageStore.save(state)
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI not configured — local capture still works."
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
        try? navigation.save(path)
    }

    func push(_ route: SporeCueRoute) {
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

    func setAlwaysShowDisclaimer(_ enabled: Bool) {
        // Hard compliance: ID surfaces always show disclaimer; toggle cannot fully hide.
        state.settings.alwaysShowEdibilityDisclaimer = true
        if !enabled {
            setBanner("Disclaimer stays on every ID / foraging surface.", error: false)
        }
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
            let session = ForageSession(
                id: id,
                createdAt: Date(),
                photoLocalURL: url.path,
                source: source,
                subject: captureSubject,
                status: "draft",
                disclaimerAck: true
            )
            state.sessions.insert(session, at: 0)
            activeSessionId = id
            persist()
            setBanner(source == "camera" ? "Cap/gill/pore still captured." : "Hike still imported.")
            push(.idResult)
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
            setBanner("AI not configured — local capture still works. No canned species.", error: true)
            refreshAIAvailability()
            return
        }
        identifyBusy = true
        setBanner("Reading morphology…")
        defer { identifyBusy = false }
        do {
            let permit = try consentGate.permit()
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                try self.consentGate.validate(permit)
            }
            let descriptor = "local_forage_still:\(URL(fileURLWithPath: session.photoLocalURL).lastPathComponent)"
            let payload = try await client.identifySpecies(
                sessionId: session.id,
                photoDescriptor: descriptor,
                subject: session.subject,
                confirmedNotes: confirmedSpeciesContext,
                question: "Identify species hypotheses and morphology cues"
            )
            try consentGate.validate(permit)

            state.candidates.removeAll { $0.sessionId == session.id }
            state.candidates.append(contentsOf: payload.candidates)
            state.chips.removeAll { $0.sessionId == session.id }
            state.chips.append(contentsOf: payload.chips)
            state.callouts.removeAll { $0.sessionId == session.id }
            state.callouts.append(contentsOf: payload.callouts)
            if let idx = state.sessions.firstIndex(where: { $0.id == session.id }) {
                state.sessions[idx].status = "identified"
            }
            let top = payload.candidates.sorted { $0.rank < $1.rank }.first
            let lookalike = payload.candidates.sorted { $0.rank < $1.rank }.dropFirst().first?.displayName
            let brief = FieldBriefBuilder.script(
                sessionId: session.id,
                topName: top?.displayName ?? "unknown find",
                lookalike: lookalike,
                cues: top?.morphologyCues ?? []
            )
            state.fieldBriefs.removeAll { $0.sessionId == session.id }
            state.fieldBriefs.append(brief)
            persist()
            setBanner(payload.coachTip)
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func saveFind() {
        guard let session = activeSession,
              let idx = state.sessions.firstIndex(where: { $0.id == session.id }) else { return }
        state.sessions[idx].status = "confirmed"
        state.sessions[idx].disclaimerAck = true
        persist()
        setBanner("Find saved for feedback reuse. \(SporeCueCompliance.requiredDisclaimer)")
    }

    func dismissID() {
        setBanner("Result dismissed — confirmed finds unchanged.")
    }

    func openOverlay() {
        guard let session = activeSession else { return }
        if let existing = sessionOverlay {
            draftCallouts = existing.callouts
        } else if !sessionCallouts.isEmpty {
            draftCallouts = sessionCallouts
        } else {
            let placeholder = OverlayAnnotator.placeholderOverlay(
                sessionId: session.id,
                imageLocalURL: session.photoLocalURL,
                subject: session.subject
            )
            draftCallouts = placeholder.callouts
        }
        push(.overlayAnnotate)
    }

    func keepOverlay() {
        guard let session = activeSession else { return }
        let overlay = OverlayAnnotation(
            sessionId: session.id,
            callouts: draftCallouts,
            imageLocalURL: session.photoLocalURL
        )
        state.overlays.removeAll { $0.sessionId == session.id }
        state.overlays.append(overlay)
        state.callouts.removeAll { $0.sessionId == session.id }
        state.callouts.append(contentsOf: draftCallouts)
        persist()
        setBanner("Overlay kept. \(SporeCueCompliance.requiredDisclaimer)")
        if path.last == .overlayAnnotate {
            path.removeLast()
            persistNavigation()
        }
    }

    func rejectOverlayDraft() {
        draftCallouts = []
        setBanner("Draft callouts discarded — photo kept.")
        if path.last == .overlayAnnotate {
            path.removeLast()
            persistNavigation()
        }
    }

    func playFieldBrief() {
        guard let brief = sessionBrief else {
            setBanner("No field brief yet — Identify first.", error: true)
            return
        }
        guard state.settings.ttsEnabled else {
            setBanner("TTS disabled in Settings.", error: true)
            return
        }
        if let idx = state.fieldBriefs.firstIndex(where: { $0.sessionId == brief.sessionId }) {
            state.fieldBriefs[idx].spokenAt = Date()
            persist()
        }
        tts.speak(brief.scriptText)
        push(.fieldBrief)
    }

    // MARK: - Coach

    func sendCoachQuestion(sttSource: String? = nil) {
        let text = (sttSource == nil ? coachQuestion : speechTranscript)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let session = activeSession else { return }
        let userTurn = CoachTurn(
            sessionId: session.id,
            role: "user",
            text: text,
            sttSource: sttSource,
            createdAt: Date()
        )
        state.coachTurns.append(userTurn)
        persist()
        coachQuestion = ""
        runWithConsent { [weak self] in
            Task { await self?.performCoach(question: text, sessionId: session.id) }
        }
    }

    private func performCoach(question: String, sessionId: String) async {
        guard let key = apiKey() else {
            let local = CoachTurn(
                sessionId: sessionId,
                role: "coach",
                text: ChipRailBuilder.ensureDisclaimer(
                    "AI not configured. Compare gill spacing and habitat notes locally — never treat this as edible certification."
                ),
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
            let reply = try await client.coachLookalike(
                sessionId: sessionId,
                question: question,
                candidates: sessionCandidates,
                confirmedNotes: confirmedSpeciesContext
            )
            try consentGate.validate(permit)
            state.coachTurns.append(
                CoachTurn(
                    sessionId: sessionId,
                    role: "coach",
                    text: reply.reply,
                    sttSource: nil,
                    createdAt: Date()
                )
            )
            persist()
        } catch {
            setBanner(error.localizedDescription, error: true)
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
            sendCoachQuestion(sttSource: "speech")
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
        setBanner("Voice note saved.")
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
        setBanner("Local capture still works without AI.", error: false)
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
}
