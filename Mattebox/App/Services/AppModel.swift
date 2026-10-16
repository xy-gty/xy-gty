import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import MatteboxDomain

@MainActor
final class AppModel: ObservableObject {
    static let defaultChips = ["ECU", "CU", "MS", "WS", "EWS"]

    @Published var sessions: [FramingSession] = []
    @Published var stills: [FrameStill] = []
    @Published var drafts: [CompositionDraft] = []
    @Published var notes: [CompositionNote] = []
    @Published var shotPlans: [ShotSizePlan] = []
    @Published var overlays: [AspectOverlay] = []
    @Published var turns: [CoachTurn] = []
    @Published var messages: [CoachMessage] = []
    @Published var voiceIntents: [VoiceIntent] = []
    @Published var directorCues: [String] = []

    @Published var activeSessionId: String?
    @Published var path: [MatteboxRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingDraft: CompositionDraft?
    @Published var pendingTurn: CoachTurn?
    @Published var editingIssueSummary = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var overlayDraftNotes = ""
    @Published var aiUnavailableReason: String?
    @Published var selectedChip = "MS"
    @Published var pendingStillId: String?
    @Published var newSessionTitle = ""
    @Published var showCamera = false
    @Published var ttsCueIndex = 0
    @Published var pendingSubject = ""
    @Published var pendingEdges = ""
    @Published var pendingSpace = ""
    @Published var pendingSymmetry = ""
    @Published var pendingAspect = "16:9"
    @Published var pendingLens = "50mm eye-level"
    @Published var pendingCues: [String] = []
    @Published var safeFrameEnabled = true
    @Published var ruleOfThirdsEnabled = true
    @Published var ttsPulse = false

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<MatteboxRoute>
    let tts = HandsFreeTTSPlayer()
    let speechService = SpeechRecognitionService()

    private let sessionStore: AtomicCodableStore<[FramingSession]>
    private let stillStore: AtomicCodableStore<[FrameStill]>
    private let draftStore: AtomicCodableStore<[CompositionDraft]>
    private let noteStore: AtomicCodableStore<[CompositionNote]>
    private let shotStore: AtomicCodableStore<[ShotSizePlan]>
    private let overlayStore: AtomicCodableStore<[AspectOverlay]>
    private let turnStore: AtomicCodableStore<[CoachTurn]>
    private let messageStore: AtomicCodableStore<[CoachMessage]>
    private let voiceStore: AtomicCodableStore<[VoiceIntent]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = MatteboxStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingCoachAction: (() -> Void)?

    var activeSession: FramingSession? {
        guard let id = activeSessionId else { return sessions.first }
        return sessions.first(where: { $0.id == id }) ?? sessions.first
    }

    var sessionStills: [FrameStill] {
        guard let id = activeSession?.id else { return [] }
        return stills.filter { $0.sessionId == id }.sorted { $0.capturedAt < $1.capturedAt }
    }

    var sessionNote: CompositionNote? {
        guard let id = activeSession?.id else { return nil }
        return notes.filter { $0.sessionId == id }.sorted { $0.confirmedAt > $1.confirmedAt }.first
    }

    var sessionShotPlan: ShotSizePlan? {
        guard let id = activeSession?.id else { return nil }
        return shotPlans.filter { $0.sessionId == id }.sorted { $0.updatedAt > $1.updatedAt }.first
    }

    var sessionOverlays: [AspectOverlay] {
        guard let id = activeSession?.id else { return [] }
        return overlays.filter { $0.sessionId == id && $0.status == "confirmed" }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var sessionMessages: [CoachMessage] {
        guard let id = activeSession?.id else { return [] }
        return messages.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var chips: [String] {
        sessionShotPlan?.chips.isEmpty == false ? sessionShotPlan!.chips : Self.defaultChips
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Mattebox", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        sessionStore = MatteboxStores.framingSessionStore(directory: root)
        stillStore = MatteboxStores.frameStillStore(directory: root)
        draftStore = MatteboxStores.compositionDraftStore(directory: root)
        noteStore = MatteboxStores.compositionNoteStore(directory: root)
        shotStore = MatteboxStores.shotSizePlanStore(directory: root)
        overlayStore = MatteboxStores.aspectOverlayStore(directory: root)
        turnStore = MatteboxStores.coachTurnStore(directory: root)
        messageStore = MatteboxStores.coachMessageStore(directory: root)
        voiceStore = MatteboxStores.voiceIntentStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = MatteboxStores.storeURL(directory: root, name: MatteboxStores.aiConsentLocal)
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
                    try? await MatteboxStores.consentKeychainStore().save(mirrorData)
                }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        if let restored = try? navigation.restore(), !restored.isEmpty {
            path = restored
        }
        if let plan = sessionShotPlan {
            selectedChip = plan.selectedChip
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
        stills = (try? stillStore.load()) ?? []
        drafts = (try? draftStore.load()) ?? []
        notes = (try? noteStore.load()) ?? []
        shotPlans = (try? shotStore.load()) ?? []
        overlays = (try? overlayStore.load()) ?? []
        turns = (try? turnStore.load()) ?? []
        messages = (try? messageStore.load()) ?? []
        voiceIntents = (try? voiceStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = sessions.first?.id
        }
        if let plan = sessionShotPlan {
            selectedChip = plan.selectedChip
        }
        rebuildDirectorCues()
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

    func push(_ route: MatteboxRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    func createSession() {
        let title = newSessionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let session = FramingSession(
            id: UUID().uuidString,
            title: title.isEmpty ? "Framing session" : title,
            currentShotSize: "MS",
            aspectRatio: "16:9",
            createdAt: Date(),
            updatedAt: Date()
        )
        sessions.insert(session, at: 0)
        try? sessionStore.save(sessions)
        let plan = ShotSizePlan(
            id: UUID().uuidString,
            sessionId: session.id,
            chips: Self.defaultChips,
            selectedChip: "MS",
            updatedAt: Date()
        )
        shotPlans.insert(plan, at: 0)
        try? shotStore.save(shotPlans)
        activeSessionId = session.id
        selectedChip = "MS"
        newSessionTitle = ""
        statusMessage = "Session opened — capture or import a framing still."
        push(.captureImport)
    }

    func openSession(_ session: FramingSession) {
        activeSessionId = session.id
        if let plan = sessionShotPlan {
            selectedChip = plan.selectedChip
        } else {
            selectedChip = session.currentShotSize
        }
        rebuildDirectorCues()
        path = [.slateStage]
        persistNavigation()
    }

    func selectChip(_ chip: String) {
        selectedChip = chip
        guard var session = activeSession else { return }
        session.currentShotSize = chip
        session.updatedAt = Date()
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
            try? sessionStore.save(sessions)
        }
        if var plan = sessionShotPlan {
            plan.selectedChip = chip
            plan.updatedAt = Date()
            if let idx = shotPlans.firstIndex(where: { $0.id == plan.id }) {
                shotPlans[idx] = plan
            }
            try? shotStore.save(shotPlans)
        } else {
            let plan = ShotSizePlan(
                id: UUID().uuidString,
                sessionId: session.id,
                chips: Self.defaultChips,
                selectedChip: chip,
                updatedAt: Date()
            )
            shotPlans.insert(plan, at: 0)
            try? shotStore.save(shotPlans)
        }
        rebuildDirectorCues()
    }

    private func touchActiveSession() {
        guard var session = activeSession else { return }
        session.updatedAt = Date()
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
            try? sessionStore.save(sessions)
        }
    }

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

        let still = FrameStill(
            id: id,
            sessionId: session.id,
            localFileRef: "imports/\(name)",
            source: source,
            capturedAt: Date()
        )
        stills.append(still)
        try stillStore.save(stills)
        pendingStillId = id

        let recognized = CompositionRecognizer.recognize(
            image: image,
            session: session,
            stillCount: sessionStills.count
        )
        pendingSubject = recognized.subject
        pendingEdges = recognized.edges
        pendingSpace = recognized.negativeSpace
        pendingSymmetry = recognized.symmetry
        pendingAspect = recognized.aspectLabel
        pendingLens = recognized.lensLanguage
        pendingCues = recognized.cueLines
        selectedChip = recognized.suggestedShot
        let draft = CompositionDraft(
            id: UUID().uuidString,
            sessionId: session.id,
            stillId: still.id,
            issueSummary: recognized.issueSummary,
            status: "draft",
            updatedAt: Date()
        )
        pendingDraft = draft
        editingIssueSummary = draft.issueSummary
        statusMessage = "Composition draft ready — Keep, Discard, or Edit."
        push(.compositionReview)
    }

    func stillImage(_ still: FrameStill) -> UIImage? {
        let path = supportRoot.appendingPathComponent(still.localFileRef)
        return UIImage(contentsOfFile: path.path)
    }

    func keepCompositionDraft() {
        guard var draft = pendingDraft, let session = activeSession else { return }
        let summary = editingIssueSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.issueSummary : editingIssueSummary
        draft.issueSummary = summary
        draft.status = "confirmed"
        draft.updatedAt = Date()
        drafts.insert(draft, at: 0)
        try? draftStore.save(drafts)

        let note = CompositionNote(
            id: UUID().uuidString,
            sessionId: session.id,
            stillId: draft.stillId,
            subject: pendingSubject,
            edges: pendingEdges,
            negativeSpace: pendingSpace,
            symmetry: pendingSymmetry,
            confirmedAt: Date()
        )
        notes.insert(note, at: 0)
        try? noteStore.save(notes)

        if var plan = sessionShotPlan {
            plan.selectedChip = selectedChip
            plan.updatedAt = Date()
            if let idx = shotPlans.firstIndex(where: { $0.id == plan.id }) {
                shotPlans[idx] = plan
            }
            try? shotStore.save(shotPlans)
        }

        if var s = sessions.first(where: { $0.id == session.id }) {
            s.currentShotSize = selectedChip
            s.aspectRatio = pendingAspect
            s.updatedAt = Date()
            if let idx = sessions.firstIndex(where: { $0.id == s.id }) {
                sessions[idx] = s
                try? sessionStore.save(sessions)
            }
        }

        if let stillId = pendingStillId {
            let overlay = AspectOverlay(
                id: UUID().uuidString,
                sessionId: session.id,
                stillId: stillId,
                aspectRatioLabel: pendingAspect,
                safeFrameEnabled: true,
                ruleOfThirdsEnabled: true,
                notes: "Draft marks from composition keep",
                status: "draft",
                updatedAt: Date()
            )
            overlays.insert(overlay, at: 0)
            try? overlayStore.save(overlays)
        }

        directorCues = pendingCues.isEmpty
            ? ["Hold \(shotPhrase(selectedChip)), watch left edge.", "Check safe-frame before rolling."]
            : pendingCues
        ttsCueIndex = 0
        touchActiveSession()
        pendingDraft = nil
        pendingStillId = nil
        statusMessage = "Composition kept — open clapper slate + shot chips."
        path = [.slateStage]
        persistNavigation()
    }

    func discardCompositionDraft() {
        pendingDraft = nil
        pendingStillId = nil
        statusMessage = "Draft discarded — stills kept; nothing confirmed."
        if activeSession != nil {
            path = [.slateStage]
        } else {
            popToHome()
        }
        persistNavigation()
    }

    func keepOverlayMarks() {
        guard let session = activeSession else {
            statusMessage = "Need a session first."
            return
        }
        let stillId = sessionStills.last?.id ?? UUID().uuidString
        let notesText = overlayDraftNotes.isEmpty
            ? "Safe-frame + thirds confirmed for \(selectedChip) / \(session.aspectRatio)"
            : overlayDraftNotes
        let overlay = AspectOverlay(
            id: UUID().uuidString,
            sessionId: session.id,
            stillId: stillId,
            aspectRatioLabel: session.aspectRatio.isEmpty ? pendingAspect : session.aspectRatio,
            safeFrameEnabled: safeFrameEnabled,
            ruleOfThirdsEnabled: ruleOfThirdsEnabled,
            notes: notesText,
            status: "confirmed",
            updatedAt: Date()
        )
        overlays.insert(overlay, at: 0)
        try? overlayStore.save(overlays)
        overlayDraftNotes = ""
        statusMessage = "Overlay marks kept."
        path = [.slateStage]
        persistNavigation()
    }

    func discardOverlayMarks() {
        overlayDraftNotes = ""
        statusMessage = "Overlay marks discarded."
        path = [.slateStage]
        persistNavigation()
    }

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
        statusMessage = "AI send blocked — slate, chips, and local overlays still available."
        refreshAIAvailability()
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "AI consent revoked — outbound sends stopped."
        } catch {
            statusMessage = "Revoke failed: \(error.localizedDescription)"
        }
    }

    private func runCoach() async {
        guard let session = activeSession, let key = apiKey() else { return }
        coachBusy = true
        defer { coachBusy = false }
        let userText = coachQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        if !userText.isEmpty {
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    sessionId: session.id,
                    role: "user",
                    text: userText,
                    createdAt: Date(),
                    status: "confirmed"
                )
            )
            try? messageStore.save(messages)
        }
        do {
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                _ = try self.consentGate.permit()
            }
            let prior = messages.filter { $0.sessionId == session.id && $0.status == "confirmed" }.suffix(6).map(\.text)
            let note = sessionNote
            let composition = [note?.subject, note?.edges, note?.negativeSpace, note?.symmetry]
                .compactMap { $0 }.joined(separator: " · ")
            let stillDesc = sessionStills.last.map { "still \($0.id.prefix(8)) from \($0.source)" } ?? "no still"
            let overlayFocus = sessionOverlays.first.map {
                "\($0.aspectRatioLabel) safe=\($0.safeFrameEnabled) thirds=\($0.ruleOfThirdsEnabled)"
            } ?? "none"
            let turn = try await client.coachFraming(
                stillDescriptor: stillDesc,
                compositionSummary: composition.isEmpty ? "no confirmed notes yet" : composition,
                shotSizeLabel: selectedChip,
                aspectRatioLabel: session.aspectRatio,
                lensLanguage: pendingLens,
                overlayFocus: overlayFocus,
                chatText: userText,
                voiceTranscript: speechTranscript,
                priorFeedback: Array(prior),
                sessionId: session.id
            )
            pendingTurn = turn
            turns.insert(turn, at: 0)
            try? turnStore.save(turns)
            coachQuestion = ""
            push(.turnReview)
        } catch {
            statusMessage = "Coach failed: \(error.localizedDescription)"
            let local = localCoachReply()
            pendingTurn = local
            push(.turnReview)
        }
    }

    private func localCoachReply() -> CoachTurn {
        let sid = activeSession?.id ?? ""
        let noteHint = sessionNote.map { "Reuse: \($0.subject)." } ?? "Capture a still and Keep composition notes first."
        let text = "Local framing note (AI key gap): hold \(shotPhrase(selectedChip)) at \(activeSession?.aspectRatio ?? "16:9"). \(noteHint) Watch edges; refresh safe-frame if subject drifts."
        return CoachTurn(id: UUID().uuidString, sessionId: sid, role: "coach", text: text, createdAt: Date())
    }

    func keepTurn() {
        guard let turn = pendingTurn, let session = activeSession else { return }
        messages.append(
            CoachMessage(
                id: UUID().uuidString,
                sessionId: session.id,
                role: "coach",
                text: turn.text,
                createdAt: Date(),
                status: "confirmed"
            )
        )
        try? messageStore.save(messages)
        if let parsed = CompositionRecognizer.parseShot(from: turn.text) {
            selectChip(parsed)
        }
        directorCues.insert(turn.text, at: 0)
        pendingTurn = nil
        statusMessage = "Coach turn kept."
        path = [.slateStage]
        persistNavigation()
    }

    func discardTurn() {
        pendingTurn = nil
        statusMessage = "Coach turn discarded — not persisted as confirmed."
        path = [.coachChat]
        persistNavigation()
    }

    func playCurrentCue() {
        let cues = directorCues.isEmpty
            ? ["Hold \(shotPhrase(selectedChip)), watch left edge."]
            : directorCues
        let idx = min(max(0, ttsCueIndex), cues.count - 1)
        ttsPulse = true
        tts.play(cues[idx])
        tts.onFinished = { [weak self] in
            self?.ttsPulse = false
        }
    }

    func nextCue() {
        let count = max(directorCues.count, 1)
        ttsCueIndex = (ttsCueIndex + 1) % count
        playCurrentCue()
    }

    func dictateShot() async {
        speechBusy = true
        defer { speechBusy = false }
        do {
            let text = try await speechService.transcribeOnce()
            speechTranscript = text
            coachQuestion = text
            if let session = activeSession {
                let shot = CompositionRecognizer.parseShot(from: text) ?? selectedChip
                if CompositionRecognizer.parseShot(from: text) != nil {
                    selectChip(shot)
                }
                let intent = VoiceIntent(
                    id: UUID().uuidString,
                    sessionId: session.id,
                    transcript: text,
                    shotSizeLabel: shot,
                    lensLanguage: pendingLens,
                    createdAt: Date()
                )
                voiceIntents.insert(intent, at: 0)
                try? voiceStore.save(voiceIntents)
                statusMessage = "Voice intent captured — review overlays / ask coach."
                push(.coachChat)
            }
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func rebuildDirectorCues() {
        if !pendingCues.isEmpty {
            directorCues = pendingCues
            return
        }
        let note = sessionNote
        var lines = [
            "Hold \(shotPhrase(selectedChip)), watch left edge.",
            "Keep \(activeSession?.aspectRatio ?? "16:9") safe-frame readable on slate.",
        ]
        if let note {
            lines.append("Subject: \(note.subject)")
        }
        if let overlay = sessionOverlays.first {
            lines.append(overlay.notes)
        }
        directorCues = lines
    }

    private func shotPhrase(_ chip: String) -> String {
        switch chip {
        case "ECU": return "extreme close-up"
        case "CU": return "close-up"
        case "MS": return "medium shot"
        case "WS": return "wide shot"
        case "EWS": return "extreme wide shot"
        default: return chip
        }
    }
}
