import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import StirboardDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var state = StirboardState()
    @Published var path: [StirboardRoute] = []
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
    @Published var pourOrdinal = 1
    @Published var legalPageName = "privacy"
    @Published var captureSubject = "bottle"

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<StirboardRoute>
    let tts = TTSPlayer()
    let speechService = SpeechRecognitionService()
    let voiceRecorder = VoiceNoteRecorder()

    private let mixStore: MixStore
    private let supportRoot: URL
    private let photosRoot: URL
    private let audioRoot: URL
    private let keychain = StirboardStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingAIAction: (() -> Void)?
    private var importGeneration = 0

    var activeSession: MixSession? {
        guard let id = activeSessionId else { return state.sessions.first }
        return state.sessions.first(where: { $0.id == id })
    }

    var sessionCandidates: [SpiritCandidate] {
        guard let id = activeSession?.id else { return [] }
        return state.candidates.filter { $0.sessionId == id }.sorted { $0.rank < $1.rank }
    }

    var sessionRecipe: RecipeCard? {
        guard let id = activeSession?.id else { return nil }
        return state.recipes.first(where: { $0.sessionId == id })
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeSession?.id else { return [] }
        return state.coachTurns.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var currentPourStep: PourStep? {
        guard let recipe = sessionRecipe else { return nil }
        return PourBoardBuilder.currentStep(in: recipe, ordinal: pourOrdinal)
    }

    var confirmedSpiritsContext: [String] {
        state.sessions.filter { $0.status == "confirmed" }.compactMap { session in
            state.candidates
                .filter { $0.sessionId == session.id }
                .sorted { $0.rank < $1.rank }
                .first
                .map { "\($0.displayName) (\($0.baseSpirit))" }
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent(StirboardStores.mediaDirectoryName, isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        photosRoot = root.appendingPathComponent("photos", isDirectory: true)
        audioRoot = root.appendingPathComponent("audio", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: audioRoot, withIntermediateDirectories: true)

        mixStore = MixStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: StirboardNavigation.isValid
        )

        let consentURL = StirboardStores.storeURL(directory: root, name: StirboardStores.aiConsentLocal)
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
                Task { try? await StirboardStores.consentKeychainStore().save(mirrorData) }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        if let restored = try? navigation.restore(), !restored.isEmpty {
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
        state = (try? mixStore.load()) ?? StirboardState()
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = state.sessions.first?.id
        }
        if let recipe = sessionRecipe {
            pourOrdinal = recipe.steps.map(\.ordinal).sorted().first ?? 1
        }
    }

    func persist() {
        try? mixStore.save(state)
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

    func push(_ route: StirboardRoute) {
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
            let session = MixSession(
                id: id,
                createdAt: Date(),
                photoLocalURL: url.path,
                source: source,
                subject: captureSubject,
                status: "draft"
            )
            state.sessions.insert(session, at: 0)
            activeSessionId = id
            persist()
            setBanner(source == "camera" ? "Bottle still captured." : "Bar-shelf still imported.")
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
            setBanner("AI not configured — local capture still works.", error: true)
            refreshAIAvailability()
            return
        }
        identifyBusy = true
        setBanner("Reading label…")
        defer { identifyBusy = false }
        do {
            let permit = try consentGate.permit()
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                try self.consentGate.validate(permit)
            }
            let descriptor = "local_bottle_still:\(URL(fileURLWithPath: session.photoLocalURL).lastPathComponent)"
            let payload = try await client.identifySpirit(
                sessionId: session.id,
                photoDescriptor: descriptor,
                subject: session.subject,
                confirmedSpirits: confirmedSpiritsContext,
                question: "Identify base spirit and label notes"
            )
            try consentGate.validate(permit)

            state.candidates.removeAll { $0.sessionId == session.id }
            state.candidates.append(contentsOf: payload.candidates)
            if let idx = state.sessions.firstIndex(where: { $0.id == session.id }) {
                state.sessions[idx].status = "identified"
            }
            if state.recipes.first(where: { $0.sessionId == session.id }) == nil,
               let top = payload.candidates.sorted(by: { $0.rank < $1.rank }).first {
                state.recipes.append(PourBoardBuilder.placeholderRecipe(sessionId: session.id, baseSpirit: top.baseSpirit))
                pourOrdinal = 1
            }
            persist()
            setBanner(payload.coachTip.isEmpty ? "Spirit candidates ready on the bottle rail." : payload.coachTip)
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func saveMix() {
        guard let session = activeSession,
              let idx = state.sessions.firstIndex(where: { $0.id == session.id }) else { return }
        state.sessions[idx].status = "confirmed"
        persist()
        setBanner("Mix saved for feedback reuse.")
    }

    func dismissID() {
        setBanner("Result dismissed — confirmed spirits unchanged.")
    }

    func openPourBoard() {
        if sessionRecipe == nil, let session = activeSession {
            let base = sessionCandidates.first?.baseSpirit ?? "spirit"
            state.recipes.append(PourBoardBuilder.placeholderRecipe(sessionId: session.id, baseSpirit: base))
            persist()
        }
        pourOrdinal = sessionRecipe?.steps.map(\.ordinal).sorted().first ?? 1
        push(.pourBoard)
    }

    func advancePourStep() {
        guard let recipe = sessionRecipe else { return }
        pourOrdinal = PourBoardBuilder.advanceOrdinal(current: pourOrdinal, recipe: recipe)
    }

    func toggleGarnish(_ chip: GarnishChip) {
        guard let session = activeSession,
              let ridx = state.recipes.firstIndex(where: { $0.sessionId == session.id }) else { return }
        if let cidx = state.recipes[ridx].garnishChips.firstIndex(where: { $0.name == chip.name }) {
            state.recipes[ridx].garnishChips[cidx].placed.toggle()
            persist()
        }
    }

    func speakCurrentStep() {
        guard let step = currentPourStep else {
            setBanner("No pour step to speak yet.", error: true)
            return
        }
        guard state.settings.ttsEnabled else {
            setBanner("TTS disabled in Settings.", error: true)
            return
        }
        tts.speak(step.instruction)
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
                text: "AI not configured. Try a citrus swap or simple syrup locally, then open the pour board.",
                sttSource: nil,
                createdAt: Date()
            )
            state.coachTurns.append(local)
            if sessionRecipe == nil {
                let base = sessionCandidates.first?.baseSpirit ?? "spirit"
                state.recipes.append(PourBoardBuilder.placeholderRecipe(sessionId: sessionId, baseSpirit: base))
            }
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
            let reply = try await client.coachRecipe(
                sessionId: sessionId,
                question: question,
                candidates: sessionCandidates,
                confirmedSpirits: confirmedSpiritsContext
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
            if let recipe = reply.recipe {
                state.recipes.removeAll { $0.sessionId == sessionId }
                state.recipes.append(recipe)
                pourOrdinal = recipe.steps.map(\.ordinal).sorted().first ?? 1
            }
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
