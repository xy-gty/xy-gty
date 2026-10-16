import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import FieldmarkDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var state = FieldmarkState()
    @Published var path: [FieldmarkRoute] = []
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
    @Published var editingMarksText = ""
    @Published var overlayCallouts: [OverlayCallout] = []

    let consentGate: AIConsentGate
    let navigation: FieldmarkNavigationStore
    let tts = TTSPlayer()
    let speechService = SpeechRecognitionService()
    let voiceRecorder = VoiceNoteRecorder()

    private let sightingStore: SightingStore
    private let supportRoot: URL
    private let photosRoot: URL
    private let audioRoot: URL
    private let keychain = FieldmarkStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingAIAction: (() -> Void)?
    private var importGeneration = 0

    var activeSession: IDSession? {
        guard let id = activeSessionId else { return state.sessions.first }
        return state.sessions.first(where: { $0.id == id })
    }

    var sessionCandidates: [SpeciesCandidate] {
        guard let id = activeSession?.id else { return [] }
        return state.candidates.filter { $0.sessionId == id }.sorted { $0.rank < $1.rank }
    }

    var sessionMarks: [FieldMark] {
        let ids = Set(sessionCandidates.map(\.scientificName))
        return state.fieldMarks.filter { ids.contains($0.candidateId) }
            .sorted { $0.salience > $1.salience }
    }

    var sessionLookalike: LookalikePair? {
        guard let id = activeSession?.id else { return nil }
        return state.lookalikePairs.first(where: { $0.sessionId == id })
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeSession?.id else { return [] }
        return state.coachTurns.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var sessionOverlay: AnnotatedOverlay? {
        guard let id = activeSession?.id else { return nil }
        return state.overlays.filter { $0.sessionId == id }.sorted { $0.createdAt > $1.createdAt }.first
    }

    var confirmedMarksContext: [String] {
        state.sessions.filter { $0.status == "confirmed" }.flatMap { session in
            let candIds = state.candidates.filter { $0.sessionId == session.id && $0.rank == 1 }.map(\.scientificName)
            return state.fieldMarks.filter { candIds.contains($0.candidateId) }.map(\.label)
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent(FieldmarkStores.mediaDirectoryName, isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        photosRoot = root.appendingPathComponent("photos", isDirectory: true)
        audioRoot = root.appendingPathComponent("audio", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: audioRoot, withIntermediateDirectories: true)

        sightingStore = SightingStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = FieldmarkStores.storeURL(directory: root, name: FieldmarkStores.aiConsentLocal)
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
                Task { try? await FieldmarkStores.consentKeychainStore().save(mirrorData) }
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
        state = (try? sightingStore.load()) ?? FieldmarkState()
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = state.sessions.first?.id
        }
    }

    func persist() {
        try? sightingStore.save(state)
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

    func push(_ route: FieldmarkRoute) {
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
            let session = IDSession(
                id: id,
                createdAt: Date(),
                photoLocalURL: url.path,
                source: source,
                status: "draft"
            )
            state.sessions.insert(session, at: 0)
            activeSessionId = id
            persist()
            setBanner(source == "camera" ? "Field still captured." : "Trip still imported.")
            push(.idResult(sessionId: id))
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
        setBanner("Reading plumage…")
        defer { identifyBusy = false }
        do {
            let permit = try consentGate.permit()
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                try self.consentGate.validate(permit)
            }
            let descriptor = "local_bird_still:\(URL(fileURLWithPath: session.photoLocalURL).lastPathComponent)"
            let payload = try await client.identifySpecies(
                sessionId: session.id,
                photoDescriptor: descriptor,
                confirmedMarks: confirmedMarksContext,
                question: "Identify species and field marks"
            )
            try consentGate.validate(permit)

            let priorNames = Set(state.candidates.filter { $0.sessionId == session.id }.map(\.scientificName))
            state.fieldMarks.removeAll { priorNames.contains($0.candidateId) }
            state.candidates.removeAll { $0.sessionId == session.id }
            state.lookalikePairs.removeAll { $0.sessionId == session.id }

            state.candidates.append(contentsOf: payload.candidates)
            state.fieldMarks.append(contentsOf: payload.fieldMarks)
            if let pair = payload.lookalike {
                state.lookalikePairs.append(pair)
            }
            if let idx = state.sessions.firstIndex(where: { $0.id == session.id }) {
                state.sessions[idx].status = "identified"
            }
            persist()
            setBanner(payload.coachTip.isEmpty ? "Species candidates ready." : payload.coachTip)
            if state.settings.ttsEnabled, let top = payload.candidates.first {
                let tip = payload.fieldMarks.first?.label ?? "Check the field marks."
                tts.speak(speciesName: top.commonName, tip: tip)
            }
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func saveID() {
        guard let session = activeSession,
              let idx = state.sessions.firstIndex(where: { $0.id == session.id }) else { return }
        state.sessions[idx].status = "confirmed"
        persist()
        setBanner("ID saved for feedback reuse.")
    }

    func dismissID() {
        setBanner("Result dismissed — confirmed species unchanged.")
    }

    func applyEditedMarks() {
        guard let top = sessionCandidates.first else { return }
        let labels = editingMarksText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !labels.isEmpty else { return }
        state.fieldMarks.removeAll { $0.candidateId == top.scientificName }
        for (i, label) in labels.enumerated() {
            state.fieldMarks.append(
                FieldMark(
                    candidateId: top.scientificName,
                    label: label,
                    bodyRegion: "edited",
                    salience: 1.0 - Double(i) * 0.1,
                    chipEmphasis: i == 0
                )
            )
        }
        persist()
        setBanner("Marks edited — Save ID to reuse on next Identify.")
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
                text: "AI not configured. Compare wing bars and supercilium on the silhouette bar locally.",
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
                confirmedMarks: confirmedMarksContext
            )
            try consentGate.validate(permit)
            state.coachTurns.append(
                CoachTurn(
                    sessionId: sessionId,
                    role: "coach",
                    text: reply,
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

    // MARK: - Overlay / TTS / Voice

    func buildOverlayDraft() {
        guard let session = activeSession else { return }
        let marks = sessionMarks
        overlayCallouts = marks.enumerated().map { index, mark in
            OverlayCallout(
                markId: "\(mark.candidateId)-\(index)",
                x: 0.2 + Double(index % 3) * 0.25,
                y: 0.25 + Double(index / 3) * 0.2,
                label: mark.label
            )
        }
        if overlayCallouts.isEmpty {
            overlayCallouts = [
                OverlayCallout(markId: "hint", x: 0.5, y: 0.4, label: "Identify first for callouts")
            ]
        }
        push(.overlayStudio(sessionId: session.id))
    }

    func saveOverlay() {
        guard let session = activeSession else { return }
        let overlay = AnnotatedOverlay(
            sessionId: session.id,
            photoLocalURL: session.photoLocalURL,
            callouts: overlayCallouts,
            createdAt: Date()
        )
        state.overlays.insert(overlay, at: 0)
        persist()
        setBanner("Overlay saved on the same field still.")
    }

    func speakTip() {
        guard state.settings.ttsEnabled else {
            setBanner("TTS disabled in Settings.")
            return
        }
        let name = sessionCandidates.first?.commonName ?? "Unknown species"
        let tip = sessionMarks.first?.label ?? "Check the oversized field-mark chips."
        tts.speak(speciesName: name, tip: tip)
    }

    func startVoiceNote() {
        voiceRecorder.start(to: audioRoot)
        showVoiceNote = true
    }

    func stopVoiceNote() {
        guard let url = voiceRecorder.stop() else {
            setBanner(voiceRecorder.lastError ?? "Recording failed.", error: true)
            return
        }
        let note = VoiceNote(
            sessionId: activeSessionId,
            localAudioURL: url.path,
            transcript: nil,
            createdAt: Date()
        )
        state.voiceNotes.insert(note, at: 0)
        persist()
        showVoiceNote = false
        setBanner("Voice note saved.")
    }

    // MARK: - Consent

    func runWithConsent(_ action: @escaping () -> Void) {
        refreshAIAvailability()
        if apiKey() == nil {
            action()
            return
        }
        if consentGate.state.granted {
            action()
        } else {
            pendingAIAction = action
            showConsent = true
        }
    }

    func grantConsentAndContinue() {
        do {
            try consentGate.grant()
            consentGranted = true
            state.settings.consentRevoked = false
            persist()
            showConsent = false
            refreshAIAvailability()
            let action = pendingAIAction
            pendingAIAction = nil
            action?()
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func dismissConsent() {
        showConsent = false
        pendingAIAction = nil
        setBanner("Outbound AI cancelled — photo kept.")
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            state.settings.consentRevoked = true
            persist()
            refreshAIAvailability()
            setBanner("AI consent revoked — outbound stopped.")
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func photoImage(for session: IDSession?) -> UIImage? {
        guard let path = session?.photoLocalURL else { return nil }
        return UIImage(contentsOfFile: path)
    }
}
