import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import ShutterduskDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var nightFrames: [NightFrame] = []
    @Published var drafts: [ExposureDraft] = []
    @Published var findings: [DiagnosisFinding] = []
    @Published var overlays: [AnnotatedOverlay] = []
    @Published var turns: [CoachTurn] = []
    @Published var messages: [CoachMessage] = []
    @Published var fieldCues: [FieldCue] = []
    @Published var dictatedExposures: [DictatedExposure] = []

    @Published var activeSessionId: String?
    @Published var path: [ShutterduskRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingDraft: ExposureDraft?
    @Published var pendingTurn: CoachTurn?
    @Published var editingExposure = ""
    @Published var editingNoise = ""
    @Published var editingTrail = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var userFeedback = ""
    @Published var overlayDraftLabel = "underexposed"
    @Published var aiUnavailableReason: String?
    @Published var currentFrameIndex = 0
    @Published var pendingFrameId: String?
    @Published var newLocationLabel = ""
    @Published var newSceneGoal = ""
    @Published var showOverlays = true
    @Published var draftOverlayPoint: CGPoint?
    @Published var isoField = ""
    @Published var shutterField = ""
    @Published var apertureField = ""
    @Published var notesField = ""
    @Published var showCamera = false
    @Published var ttsCueIndex = 0

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<ShutterduskRoute>
    let tts = FieldCueTTSPlayer()
    let speechService = SpeechRecognitionService()

    private let sessionStore: AtomicCodableStore<[Session]>
    private let frameStore: AtomicCodableStore<[NightFrame]>
    private let draftStore: AtomicCodableStore<[ExposureDraft]>
    private let findingStore: AtomicCodableStore<[DiagnosisFinding]>
    private let overlayStore: AtomicCodableStore<[AnnotatedOverlay]>
    private let turnStore: AtomicCodableStore<[CoachTurn]>
    private let messageStore: AtomicCodableStore<[CoachMessage]>
    private let fieldCueStore: AtomicCodableStore<[FieldCue]>
    private let dictatedStore: AtomicCodableStore<[DictatedExposure]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = ShutterduskStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingCoachAction: (() -> Void)?
    private var pendingDiagnosisMarks: [(x: Double, y: Double, value: Double, label: String)] = []

    var activeSession: Session? {
        guard let id = activeSessionId else { return sessions.first }
        return sessions.first(where: { $0.id == id }) ?? sessions.first
    }

    var frameLabels: [String] {
        guard let session = activeSession else {
            return ["N1", "N2", "N3", "N4"]
        }
        let frames = sessionFrames
        if frames.isEmpty {
            return (1 ... 4).map { "N\($0)" }
        }
        return frames.enumerated().map { idx, frame in
            "N\(idx + 1) · \(frame.source.prefix(3))"
        }
    }

    var sessionFrames: [NightFrame] {
        guard let id = activeSession?.id else { return [] }
        return nightFrames.filter { $0.sessionId == id }.sorted { $0.capturedAt > $1.capturedAt }
    }

    var sessionFindings: [DiagnosisFinding] {
        guard let id = activeSession?.id else { return [] }
        return findings.filter { $0.sessionId == id }.sorted { $0.confirmedAt > $1.confirmedAt }
    }

    var sessionOverlays: [AnnotatedOverlay] {
        guard let id = activeSession?.id else { return [] }
        return overlays.filter { $0.sessionId == id && $0.status == "confirmed" }
    }

    var sessionMessages: [CoachMessage] {
        guard let id = activeSession?.id else { return [] }
        return messages.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeSession?.id else { return [] }
        return turns.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var sessionCues: [FieldCue] {
        guard let id = activeSession?.id else { return [] }
        return fieldCues.filter { $0.sessionId == id }.sorted { $0.sortIndex < $1.sortIndex }
    }

    var sessionDictated: [DictatedExposure] {
        guard let id = activeSession?.id else { return [] }
        return dictatedExposures.filter { $0.sessionId == id }.sorted { $0.createdAt > $1.createdAt }
    }

    var overlayMarks: [ExposureDiagnosisOverlayCanvas.Mark] {
        sessionOverlays.map {
            .init(id: $0.id, xNorm: $0.xNorm, yNorm: $0.yNorm, diagnosisValue: $0.diagnosisValue, label: $0.label)
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Shutterdusk", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        sessionStore = ShutterduskStores.sessionStore(directory: root)
        frameStore = ShutterduskStores.nightFrameStore(directory: root)
        draftStore = ShutterduskStores.exposureDraftStore(directory: root)
        findingStore = ShutterduskStores.diagnosisFindingStore(directory: root)
        overlayStore = ShutterduskStores.annotatedOverlayStore(directory: root)
        turnStore = ShutterduskStores.coachTurnStore(directory: root)
        messageStore = ShutterduskStores.coachMessageStore(directory: root)
        fieldCueStore = ShutterduskStores.fieldCueStore(directory: root)
        dictatedStore = ShutterduskStores.dictatedExposureStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = ShutterduskStores.storeURL(directory: root, name: ShutterduskStores.aiConsentLocal)
        consentGate = AIConsentContract.makeGate(
            load: {
                guard FileManager.default.fileExists(atPath: consentURL.path) else { return nil }
                return try JSONDecoder().decode(AIConsentGate.State.self, from: Data(contentsOf: consentURL))
            },
            persist: { state in
                let data = try JSONEncoder().encode(state)
                try data.write(to: consentURL, options: .atomic)
                let mirror = AIConsentRecord(
                    disclosureVersion: state.disclosureVersion,
                    allowed: state.granted
                )
                let mirrorData = try JSONEncoder().encode(mirror)
                Task {
                    try? await ShutterduskStores.consentKeychainStore().save(mirrorData)
                }
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
        sessions = (try? sessionStore.load()) ?? []
        nightFrames = (try? frameStore.load()) ?? []
        drafts = (try? draftStore.load()) ?? []
        findings = (try? findingStore.load()) ?? []
        overlays = (try? overlayStore.load()) ?? []
        turns = (try? turnStore.load()) ?? []
        messages = (try? messageStore.load()) ?? []
        fieldCues = (try? fieldCueStore.load()) ?? []
        dictatedExposures = (try? dictatedStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = sessions.first?.id
        }
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI unavailable: DeepSeek key not configured (local_only gap)."
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

    func push(_ route: ShutterduskRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    // MARK: - Sessions

    func createSession() {
        let location = newLocationLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        let goal = newSceneGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        let session = Session(
            id: UUID().uuidString,
            locationLabel: location.isEmpty ? "City overlook" : location,
            sessionDate: Date(),
            sceneGoal: goal.isEmpty ? "Night long exposure" : goal,
            currentFrameLabel: "N1",
            updatedAt: Date()
        )
        sessions.insert(session, at: 0)
        try? sessionStore.save(sessions)
        activeSessionId = session.id
        currentFrameIndex = 0
        newLocationLabel = ""
        newSceneGoal = ""
        statusMessage = "Session opened — capture or import a night test frame."
        push(.captureImport)
    }

    func openSession(_ session: Session) {
        activeSessionId = session.id
        currentFrameIndex = 0
        path = [.nightCoach]
        persistNavigation()
    }

    func selectFrame(_ index: Int) {
        currentFrameIndex = index
        guard var session = activeSession else { return }
        session.currentFrameLabel = frameLabels.indices.contains(index) ? frameLabels[index] : "N\(index + 1)"
        session.updatedAt = Date()
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
            try? sessionStore.save(sessions)
        }
    }

    // MARK: - Capture / Import

    func importPhotoFromLibrary() async {
        guard let item = selectedPhotoItem else { return }
        importBusy = true
        defer { importBusy = false }
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                statusMessage = "Could not decode library image."
                return
            }
            try ingestImage(image, source: "library")
        } catch {
            statusMessage = "Import cancelled or failed: \(error.localizedDescription)"
        }
    }

    func importCameraImage(_ image: UIImage) {
        do {
            try ingestImage(image, source: "camera")
        } catch {
            statusMessage = "Camera save failed: \(error.localizedDescription)"
        }
    }

    private func ingestImage(_ image: UIImage, source: String) throws {
        guard let session = activeSession else {
            statusMessage = "Create a session first."
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            statusMessage = "Image encode failed."
            return
        }
        let id = UUID().uuidString
        let name = "\(id).jpg"
        let url = importsRoot.appendingPathComponent(name)
        try data.write(to: url, options: .atomic)
        let frame = NightFrame(
            id: id,
            sessionId: session.id,
            relativePath: "imports/\(name)",
            source: source,
            capturedAt: Date()
        )
        nightFrames.insert(frame, at: 0)
        try frameStore.save(nightFrames)
        pendingFrameId = id

        let recognized = ExposureRecognizer.recognize(image: image, session: session)
        pendingDiagnosisMarks = recognized.diagnosisMarks
        let draft = ExposureDraft(
            id: UUID().uuidString,
            sessionId: session.id,
            nightFrameId: id,
            exposureSummary: recognized.exposureSummary,
            noiseSummary: recognized.noiseSummary,
            trailSigns: recognized.trailSigns,
            status: "draft",
            updatedAt: Date()
        )
        pendingDraft = draft
        editingExposure = draft.exposureSummary
        editingNoise = draft.noiseSummary
        editingTrail = draft.trailSigns
        statusMessage = "Exposure draft ready — Keep, Discard, or Edit."
        push(.exposureReview)
    }

    func imageURL(for frame: NightFrame) -> URL {
        supportRoot.appendingPathComponent(frame.relativePath)
    }

    func loadFrameImage(_ frame: NightFrame) -> UIImage? {
        UIImage(contentsOfFile: imageURL(for: frame).path)
    }

    // MARK: - Exposure review

    func keepExposureDraft() {
        guard var draft = pendingDraft, var session = activeSession else { return }
        draft.exposureSummary = editingExposure.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.exposureSummary : editingExposure
        draft.noiseSummary = editingNoise.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.noiseSummary : editingNoise
        draft.trailSigns = editingTrail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.trailSigns : editingTrail
        draft.status = "confirmed"
        draft.updatedAt = Date()
        drafts.insert(draft, at: 0)
        try? draftStore.save(drafts)

        let tags: [(String, String)] = [
            ("underexposed", draft.exposureSummary),
            ("noise", draft.noiseSummary),
            ("trail", draft.trailSigns),
        ]
        for (tag, detail) in tags {
            findings.append(
                DiagnosisFinding(
                    id: UUID().uuidString,
                    sessionId: draft.sessionId,
                    nightFrameId: draft.nightFrameId,
                    tag: tag,
                    detail: detail,
                    confirmedAt: Date()
                )
            )
        }
        try? findingStore.save(findings)

        for mark in pendingDiagnosisMarks {
            overlays.append(
                AnnotatedOverlay(
                    id: UUID().uuidString,
                    sessionId: draft.sessionId,
                    nightFrameId: draft.nightFrameId,
                    xNorm: mark.x,
                    yNorm: mark.y,
                    diagnosisValue: mark.value,
                    label: mark.label,
                    status: "confirmed",
                    updatedAt: Date()
                )
            )
        }
        try? overlayStore.save(overlays)
        pendingDiagnosisMarks = []

        let cues = [
            FieldCue(id: UUID().uuidString, sessionId: draft.sessionId, cueKind: "iso", text: "Set ISO to 800 or lower if shutter can hold.", sortIndex: sessionCues.count, createdAt: Date()),
            FieldCue(id: UUID().uuidString, sessionId: draft.sessionId, cueKind: "shutter", text: "Try 15 to 30 seconds on a locked tripod.", sortIndex: sessionCues.count + 1, createdAt: Date()),
            FieldCue(id: UUID().uuidString, sessionId: draft.sessionId, cueKind: "focus", text: "Manual focus on a bright distant light, then recompose.", sortIndex: sessionCues.count + 2, createdAt: Date()),
        ]
        fieldCues.append(contentsOf: cues)
        try? fieldCueStore.save(fieldCues)

        session.updatedAt = Date()
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
            try? sessionStore.save(sessions)
        }
        pendingDraft = nil
        pendingFrameId = nil
        statusMessage = "Diagnosis kept — open night-frame rail and overlays."
        path = [.nightCoach]
        persistNavigation()
    }

    func discardExposureDraft() {
        // PM: Discard drops the draft only; NightFrame stays for another diagnosis pass.
        pendingDraft = nil
        pendingFrameId = nil
        pendingDiagnosisMarks = []
        statusMessage = "Draft discarded — NightFrame kept; nothing confirmed."
        if activeSession != nil {
            path = [.nightCoach]
        } else {
            popToHome()
        }
        persistNavigation()
    }

    // MARK: - Annotated overlay

    func placeDraftOverlay(at point: CGPoint) {
        draftOverlayPoint = point
    }

    func keepOverlayMarks() {
        guard let session = activeSession,
              let frame = sessionFrames.first,
              let point = draftOverlayPoint else {
            statusMessage = "Tap the night frame to place a diagnosis mark first."
            return
        }
        overlays.append(
            AnnotatedOverlay(
                id: UUID().uuidString,
                sessionId: session.id,
                nightFrameId: frame.id,
                xNorm: point.x,
                yNorm: point.y,
                diagnosisValue: 0.65,
                label: overlayDraftLabel,
                status: "confirmed",
                updatedAt: Date()
            )
        )
        try? overlayStore.save(overlays)
        draftOverlayPoint = nil
        statusMessage = "Diagnosis mark kept."
        path = [.nightCoach]
        persistNavigation()
    }

    func discardOverlayDraft() {
        draftOverlayPoint = nil
        statusMessage = "Overlay draft discarded."
        path = [.nightCoach]
        persistNavigation()
    }

    // MARK: - Coach

    func requestCoach() {
        refreshAIAvailability()
        guard apiKey() != nil else {
            statusMessage = aiUnavailableReason ?? "DeepSeek key not configured."
            let local = localCoachReply()
            pendingTurn = local
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    sessionId: activeSession?.id ?? "",
                    role: "coach",
                    text: local.text,
                    createdAt: Date(),
                    status: "draft"
                )
            )
            try? messageStore.save(messages)
            push(.turnReview)
            return
        }
        guard consentGate.state.granted else {
            pendingCoachAction = { [weak self] in
                Task { await self?.runCoach() }
            }
            showConsent = true
            push(.consentSheet)
            return
        }
        Task { await runCoach() }
    }

    func grantConsentAndContinue() {
        do {
            try consentGate.grant()
            consentGranted = true
            refreshAIAvailability()
            showConsent = false
            if path.last == .consentSheet { _ = path.popLast(); persistNavigation() }
            let action = pendingCoachAction
            pendingCoachAction = nil
            action?()
        } catch {
            statusMessage = "Consent persist failed: \(error.localizedDescription)"
        }
    }

    func dismissConsent() {
        showConsent = false
        pendingCoachAction = nil
        if path.last == .consentSheet { _ = path.popLast(); persistNavigation() }
        statusMessage = "AI send blocked — night-frame rail, overlays, and local notes still available."
        refreshAIAvailability()
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "AI consent revoked — outbound blocked."
        } catch {
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "Consent revoked in memory; disk error: \(error.localizedDescription)"
        }
    }

    private func assertAuthorized() throws {
        let permit = try consentGate.permit()
        try consentGate.validate(permit)
    }

    private func runCoach() async {
        guard let session = activeSession, let key = apiKey() else {
            statusMessage = aiUnavailableReason
            return
        }
        coachBusy = true
        defer { coachBusy = false }
        do {
            try assertAuthorized()
            let client = DeepSeekClient(apiKey: key, assertAuthorized: { [weak self] in
                try self?.assertAuthorized()
            })
            let plan = frameLabels.joined(separator: " → ")
            let exposure = sessionFindings.first(where: { $0.tag == "underexposed" })?.detail ?? "no exposure finding"
            let noise = sessionFindings.first(where: { $0.tag == "noise" })?.detail ?? "no noise finding"
            let trail = sessionFindings.first(where: { $0.tag == "trail" })?.detail ?? "no trail finding"
            let priorFeedback = sessionTurns.filter { $0.role == "user" }.map(\.text)
            let dictated = sessionDictated.map { "iso=\($0.iso) shutter=\($0.shutterS) aperture=\($0.aperture) notes=\($0.notes)" }
            let reply = try await client.coachNight(
                framePhotoDescriptor: sessionFrames.first.map { "\($0.source) \($0.capturedAt)" } ?? "no photo",
                exposureSummary: exposure,
                noiseSummary: noise,
                trailSigns: trail,
                scenePlanSummary: plan,
                currentFrameLabel: session.currentFrameLabel,
                chatText: coachQuestion.isEmpty ? "What shutter and ISO next?" : coachQuestion,
                voiceTranscript: speechTranscript,
                dictatedExposureFields: dictated,
                priorFeedback: priorFeedback + (userFeedback.isEmpty ? [] : [userFeedback]),
                sessionId: session.id
            )
            pendingTurn = reply
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    sessionId: session.id,
                    role: "coach",
                    text: reply.text,
                    createdAt: Date(),
                    status: "draft"
                )
            )
            try? messageStore.save(messages)
            push(.turnReview)
        } catch {
            statusMessage = "Coach failed: \(error.localizedDescription)"
            let local = localCoachReply()
            pendingTurn = local
            push(.turnReview)
        }
    }

    private func localCoachReply() -> CoachTurn {
        let session = activeSession
        let finding = sessionFindings.first
        let text: String
        if let session, let finding {
            text = "Local tip (AI key gap): at \(session.locationLabel) on \(session.currentFrameLabel), \(finding.tag): \(finding.detail) Advance the night-frame rail, then confirm diagnosis overlays. Configure DeepSeek for live coach."
        } else {
            text = "Local tip: capture a night test frame, Keep diagnosis, then use the night-frame rail + exposure overlays. Configure DeepSeek key for live coach."
        }
        return CoachTurn(
            id: UUID().uuidString,
            sessionId: session?.id ?? "",
            role: "coach",
            text: text,
            createdAt: Date()
        )
    }

    func keepPendingTurn() {
        guard let turn = pendingTurn else { return }
        turns.append(turn)
        if !coachQuestion.isEmpty {
            turns.append(
                CoachTurn(
                    id: UUID().uuidString,
                    sessionId: turn.sessionId,
                    role: "user",
                    text: coachQuestion,
                    createdAt: Date()
                )
            )
        }
        if !userFeedback.isEmpty {
            turns.append(
                CoachTurn(
                    id: UUID().uuidString,
                    sessionId: turn.sessionId,
                    role: "user",
                    text: userFeedback,
                    createdAt: Date()
                )
            )
        }
        try? turnStore.save(turns)
        if let idx = messages.firstIndex(where: { $0.text == turn.text && $0.status == "draft" }) {
            messages[idx].status = "confirmed"
            try? messageStore.save(messages)
        }
        pendingTurn = nil
        coachQuestion = ""
        userFeedback = ""
        statusMessage = "Coach turn kept."
        path = [.nightCoach]
        persistNavigation()
    }

    func discardPendingTurn() {
        if let turn = pendingTurn {
            messages.removeAll { $0.text == turn.text && $0.status == "draft" }
            try? messageStore.save(messages)
        }
        pendingTurn = nil
        statusMessage = "Coach draft discarded."
        path = [.nightCoach]
        persistNavigation()
    }

    // MARK: - TTS

    func playFieldCues() {
        let corpus = sessionCues.map(\.text)
        guard !corpus.isEmpty else {
            statusMessage = "No exposure notes yet — Keep an exposure finding first."
            return
        }
        if ttsCueIndex >= corpus.count { ttsCueIndex = 0 }
        let text = corpus[ttsCueIndex]
        tts.speak(text)
        statusMessage = "Playing note \(ttsCueIndex + 1)/\(corpus.count)"
    }

    func pauseFieldCues() {
        tts.stop()
    }

    func nextFieldCue() {
        ttsCueIndex += 1
        playFieldCues()
        if frameLabels.indices.contains(ttsCueIndex % max(frameLabels.count, 1)) {
            selectFrame(ttsCueIndex % frameLabels.count)
        }
    }

    // MARK: - Dictate

    func startDictate(fieldKey: String) {
        speechBusy = true
        Task {
            defer { speechBusy = false }
            do {
                let text = try await speechService.transcribeOnce()
                speechTranscript = text
                applyDictation(fieldKey: fieldKey, value: text, transcript: text)
                statusMessage = "Dictated \(fieldKey)."
            } catch {
                statusMessage = error.localizedDescription
            }
        }
    }

    func applyDictation(fieldKey: String, value: String, transcript: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        switch fieldKey {
        case "iso": isoField = trimmed
        case "shutter": shutterField = trimmed
        case "aperture": apertureField = trimmed
        case "notes": notesField = trimmed
        default: break
        }
    }

    func saveDictatedExposure() {
        guard let session = activeSession else { return }
        let item = DictatedExposure(
            id: UUID().uuidString,
            sessionId: session.id,
            iso: isoField,
            shutterS: shutterField,
            aperture: apertureField,
            notes: notesField,
            transcript: speechTranscript,
            createdAt: Date()
        )
        dictatedExposures.insert(item, at: 0)
        try? dictatedStore.save(dictatedExposures)
        if coachQuestion.isEmpty, !notesField.isEmpty {
            coachQuestion = notesField
        }
        statusMessage = "Exposure fields saved into coach context."
    }
}
