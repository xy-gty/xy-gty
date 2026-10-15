import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import RuleCueDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var sessions: [GameSession] = []
    @Published var tablePhotos: [TablePhoto] = []
    @Published var drafts: [ComponentDraft] = []
    @Published var componentMaps: [ComponentMap] = []
    @Published var phaseSteps: [PhaseStep] = []
    @Published var setupOverlays: [SetupOverlay] = []
    @Published var turns: [CoachTurn] = []
    @Published var messages: [CoachMessage] = []
    @Published var hostCues: [HostCue] = []
    @Published var spokenQuestions: [SpokenQuestion] = []

    @Published var activeSessionId: String?
    @Published var path: [RuleCueRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingDraft: ComponentDraft?
    @Published var pendingTurn: CoachTurn?
    @Published var editingComponentSummary = ""
    @Published var editingPhaseSummary = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var userFeedback = ""
    @Published var overlayDraftNotes = ""
    @Published var aiUnavailableReason: String?
    @Published var selectedZoneIndex = 0
    @Published var currentStepIndex = 0
    @Published var pendingPhotoId: String?
    @Published var newGameName = ""
    @Published var newPlayerCount = "4"
    @Published var showCamera = false
    @Published var ttsCueIndex = 0
    @Published var pendingZoneLabels: [String] = []
    @Published var pendingPhaseTitles: [String] = []
    @Published var pendingOverlayNotes = ""
    @Published var draftMarkLabel = ""

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<RuleCueRoute>
    let tts = HostCueTTSPlayer()
    let speechService = SpeechRecognitionService()

    private let sessionStore: AtomicCodableStore<[GameSession]>
    private let photoStore: AtomicCodableStore<[TablePhoto]>
    private let draftStore: AtomicCodableStore<[ComponentDraft]>
    private let mapStore: AtomicCodableStore<[ComponentMap]>
    private let phaseStore: AtomicCodableStore<[PhaseStep]>
    private let overlayStore: AtomicCodableStore<[SetupOverlay]>
    private let turnStore: AtomicCodableStore<[CoachTurn]>
    private let messageStore: AtomicCodableStore<[CoachMessage]>
    private let hostCueStore: AtomicCodableStore<[HostCue]>
    private let spokenStore: AtomicCodableStore<[SpokenQuestion]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = RuleCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingCoachAction: (() -> Void)?

    var activeSession: GameSession? {
        guard let id = activeSessionId else { return sessions.first }
        return sessions.first(where: { $0.id == id }) ?? sessions.first
    }

    var sessionPhotos: [TablePhoto] {
        guard let id = activeSession?.id else { return [] }
        return tablePhotos.filter { $0.sessionId == id }.sorted { $0.capturedAt < $1.capturedAt }
    }

    var sessionMap: ComponentMap? {
        guard let id = activeSession?.id else { return nil }
        return componentMaps.filter { $0.sessionId == id }.sorted { $0.confirmedAt > $1.confirmedAt }.first
    }

    var sessionPhases: [PhaseStep] {
        guard let id = activeSession?.id else { return [] }
        return phaseSteps.filter { $0.sessionId == id }.sorted { $0.order < $1.order }
    }

    var sessionOverlays: [SetupOverlay] {
        guard let id = activeSession?.id else { return [] }
        return setupOverlays.filter { $0.sessionId == id && $0.status == "confirmed" }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var sessionMessages: [CoachMessage] {
        guard let id = activeSession?.id else { return [] }
        return messages.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var sessionHostCues: [HostCue] {
        guard let id = activeSession?.id else { return [] }
        return hostCues.filter { $0.sessionId == id }.sorted { $0.sortIndex < $1.sortIndex }
    }

    var sessionSpoken: [SpokenQuestion] {
        guard let id = activeSession?.id else { return [] }
        return spokenQuestions.filter { $0.sessionId == id }.sorted { $0.createdAt > $1.createdAt }
    }

    var zoneLabels: [String] {
        if let map = sessionMap, !map.items.isEmpty { return map.items }
        if !pendingZoneLabels.isEmpty { return pendingZoneLabels }
        return ["Deck", "Board", "Player mats", "Tokens"]
    }

    var currentZoneLabel: String {
        let zones = zoneLabels
        guard zones.indices.contains(selectedZoneIndex) else { return zones.first ?? "Board" }
        return zones[selectedZoneIndex]
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("RuleCue", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        sessionStore = RuleCueStores.gameSessionStore(directory: root)
        photoStore = RuleCueStores.tablePhotoStore(directory: root)
        draftStore = RuleCueStores.componentDraftStore(directory: root)
        mapStore = RuleCueStores.componentMapStore(directory: root)
        phaseStore = RuleCueStores.phaseStepStore(directory: root)
        overlayStore = RuleCueStores.setupOverlayStore(directory: root)
        turnStore = RuleCueStores.coachTurnStore(directory: root)
        messageStore = RuleCueStores.coachMessageStore(directory: root)
        hostCueStore = RuleCueStores.hostCueStore(directory: root)
        spokenStore = RuleCueStores.spokenQuestionStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = RuleCueStores.storeURL(directory: root, name: RuleCueStores.aiConsentLocal)
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
                    try? await RuleCueStores.consentKeychainStore().save(mirrorData)
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
        tablePhotos = (try? photoStore.load()) ?? []
        drafts = (try? draftStore.load()) ?? []
        componentMaps = (try? mapStore.load()) ?? []
        phaseSteps = (try? phaseStore.load()) ?? []
        setupOverlays = (try? overlayStore.load()) ?? []
        turns = (try? turnStore.load()) ?? []
        messages = (try? messageStore.load()) ?? []
        hostCues = (try? hostCueStore.load()) ?? []
        spokenQuestions = (try? spokenStore.load()) ?? []
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

    func push(_ route: RuleCueRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    func createSession() {
        let name = newGameName.trimmingCharacters(in: .whitespacesAndNewlines)
        let players = Int(newPlayerCount) ?? 4
        let session = GameSession(
            id: UUID().uuidString,
            gameName: name.isEmpty ? "Table session" : name,
            playerCount: max(1, players),
            currentPhase: "setup",
            createdAt: Date(),
            updatedAt: Date()
        )
        sessions.insert(session, at: 0)
        try? sessionStore.save(sessions)
        activeSessionId = session.id
        selectedZoneIndex = 0
        currentStepIndex = 0
        newGameName = ""
        statusMessage = "Session opened — capture or import rulebook / table photos."
        push(.captureImport)
    }

    func openSession(_ session: GameSession) {
        activeSessionId = session.id
        selectedZoneIndex = 0
        currentStepIndex = 0
        path = [.tableCoach]
        persistNavigation()
    }

    func selectZone(_ index: Int) {
        selectedZoneIndex = index
        touchActiveSession()
    }

    func selectStep(_ index: Int) {
        currentStepIndex = index
        if var session = activeSession {
            let steps = sessionPhases
            if steps.indices.contains(index) {
                session.currentPhase = steps[index].title
            }
            session.updatedAt = Date()
            if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
                sessions[idx] = session
                try? sessionStore.save(sessions)
            }
        }
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
            try ingestImage(image, source: "library", kind: "rulebook_or_table")
        } catch {
            statusMessage = "Import cancelled or failed: \(error.localizedDescription)"
        }
    }

    func importCameraImage(_ image: UIImage) {
        do {
            try ingestImage(image, source: "camera", kind: "table_layout")
        } catch {
            statusMessage = "Camera save failed: \(error.localizedDescription)"
        }
    }

    private func ingestImage(_ image: UIImage, source: String, kind: String) throws {
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

        let photo = TablePhoto(
            id: id,
            sessionId: session.id,
            localFileRef: "imports/\(name)",
            source: source,
            kind: kind,
            capturedAt: Date()
        )
        tablePhotos.append(photo)
        try photoStore.save(tablePhotos)
        pendingPhotoId = id

        let recognized = ComponentRecognizer.recognize(
            image: image,
            session: session,
            photoCount: sessionPhotos.count
        )
        pendingZoneLabels = recognized.zoneLabels
        pendingPhaseTitles = recognized.phaseTitles
        pendingOverlayNotes = recognized.overlayNotes
        let draft = ComponentDraft(
            id: UUID().uuidString,
            sessionId: session.id,
            tablePhotoId: photo.id,
            componentSummary: recognized.componentSummary,
            phaseSummary: recognized.phaseSummary,
            status: "draft",
            updatedAt: Date()
        )
        pendingDraft = draft
        editingComponentSummary = draft.componentSummary
        editingPhaseSummary = draft.phaseSummary
        statusMessage = "Component / phase draft ready — Keep, Discard, or Edit."
        push(.componentReview)
    }

    func photoImage(_ photo: TablePhoto) -> UIImage? {
        let path = supportRoot.appendingPathComponent(photo.localFileRef)
        return UIImage(contentsOfFile: path.path)
    }

    func keepComponentDraft() {
        guard var draft = pendingDraft, let session = activeSession else { return }
        draft.componentSummary = editingComponentSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.componentSummary : editingComponentSummary
        draft.phaseSummary = editingPhaseSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.phaseSummary : editingPhaseSummary
        draft.status = "confirmed"
        draft.updatedAt = Date()
        drafts.insert(draft, at: 0)
        try? draftStore.save(drafts)

        let zones = pendingZoneLabels.isEmpty ? ["Deck", "Board", "Player mats", "Tokens"] : pendingZoneLabels
        let map = ComponentMap(
            id: UUID().uuidString,
            sessionId: session.id,
            items: zones,
            confirmedAt: Date()
        )
        componentMaps.insert(map, at: 0)
        try? mapStore.save(componentMaps)

        let titles = pendingPhaseTitles.isEmpty
            ? ["Setup", "Deal", "Turn", "Score"]
            : pendingPhaseTitles
        var newPhases: [PhaseStep] = []
        for (idx, title) in titles.enumerated() {
            newPhases.append(
                PhaseStep(
                    id: UUID().uuidString,
                    sessionId: session.id,
                    order: idx + 1,
                    title: title,
                    hint: "Advance when \(title.lowercased()) is done.",
                    confirmedAt: Date()
                )
            )
        }
        phaseSteps.removeAll { $0.sessionId == session.id }
        phaseSteps.append(contentsOf: newPhases)
        try? phaseStore.save(phaseSteps)

        if let photoId = pendingPhotoId {
            let overlay = SetupOverlay(
                id: UUID().uuidString,
                sessionId: session.id,
                tablePhotoId: photoId,
                zoneBoxes: zones,
                arrowNotes: ["Start at \(zones[0])", "Then seat players"],
                notes: pendingOverlayNotes,
                status: "draft",
                updatedAt: Date()
            )
            setupOverlays.insert(overlay, at: 0)
            try? overlayStore.save(setupOverlays)
        }

        let base = sessionHostCues.count
        let cues = [
            HostCue(id: UUID().uuidString, sessionId: session.id, cueKind: "host", text: "Place the main board in the center.", sortIndex: base, createdAt: Date()),
            HostCue(id: UUID().uuidString, sessionId: session.id, cueKind: "host", text: "Sort decks into the deck zone.", sortIndex: base + 1, createdAt: Date()),
            HostCue(id: UUID().uuidString, sessionId: session.id, cueKind: "host", text: "Deal starting hands, then begin turn one.", sortIndex: base + 2, createdAt: Date()),
        ]
        hostCues.append(contentsOf: cues)
        try? hostCueStore.save(hostCues)

        selectedZoneIndex = 0
        currentStepIndex = 0
        touchActiveSession()
        pendingDraft = nil
        pendingPhotoId = nil
        statusMessage = "Components kept — open table zone cards + turn step bar."
        path = [.tableCoach]
        persistNavigation()
    }

    func discardComponentDraft() {
        pendingDraft = nil
        pendingPhotoId = nil
        statusMessage = "Draft discarded — photos kept; nothing confirmed."
        if activeSession != nil {
            path = [.tableCoach]
        } else {
            popToHome()
        }
        persistNavigation()
    }

    func keepSetupOverlay() {
        guard let session = activeSession else {
            statusMessage = "Need a session first."
            return
        }
        let photoId = sessionPhotos.last?.id ?? UUID().uuidString
        let notes = overlayDraftNotes.isEmpty
            ? (pendingOverlayNotes.isEmpty ? "Zone guide confirmed for \(currentZoneLabel)" : pendingOverlayNotes)
            : overlayDraftNotes
        let mark = draftMarkLabel.isEmpty ? currentZoneLabel : draftMarkLabel
        let overlay = SetupOverlay(
            id: UUID().uuidString,
            sessionId: session.id,
            tablePhotoId: photoId,
            zoneBoxes: zoneLabels,
            arrowNotes: ["Focus: \(mark)", "Next tip on turn step bar"],
            notes: notes,
            status: "confirmed",
            updatedAt: Date()
        )
        setupOverlays.insert(overlay, at: 0)
        try? overlayStore.save(setupOverlays)
        overlayDraftNotes = ""
        draftMarkLabel = ""
        statusMessage = "Setup overlay kept for \(mark)."
        path = [.tableCoach]
        persistNavigation()
    }

    func discardSetupOverlay() {
        overlayDraftNotes = ""
        draftMarkLabel = ""
        statusMessage = "Setup overlay discarded."
        path = [.tableCoach]
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
        statusMessage = "AI send blocked — table zones, steps, and local cues still available."
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
            statusMessage = aiUnavailableReason ?? "Missing session or key."
            return
        }
        coachBusy = true
        defer { coachBusy = false }
        do {
            try assertAuthorized()
            let client = DeepSeekClient(apiKey: key, assertAuthorized: { [weak self] in
                try self?.assertAuthorized()
            })
            let prior = sessionMessages.filter { $0.status == "confirmed" }.suffix(6).map(\.text)
            let turn = try await client.coachRules(
                gameSessionSummary: "\(session.gameName) · \(session.playerCount) players · phase \(session.currentPhase)",
                componentMapSummary: sessionMap?.items.joined(separator: ", ") ?? pendingZoneLabels.joined(separator: ", "),
                phaseStepsSummary: sessionPhases.map(\.title).joined(separator: " → "),
                setupOverlayNotes: sessionOverlays.first?.notes ?? pendingOverlayNotes,
                currentZoneLabel: currentZoneLabel,
                chatText: coachQuestion,
                voiceTranscript: speechTranscript,
                spokenQuestion: sessionSpoken.first?.questionText ?? "",
                priorFeedback: Array(prior),
                sessionId: session.id
            )
            pendingTurn = turn
            turns.insert(turn, at: 0)
            try? turnStore.save(turns)
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    sessionId: session.id,
                    role: "user",
                    text: coachQuestion.isEmpty ? (speechTranscript.isEmpty ? "Rules check" : speechTranscript) : coachQuestion,
                    createdAt: Date(),
                    status: "confirmed"
                )
            )
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    sessionId: session.id,
                    role: "coach",
                    text: turn.text,
                    createdAt: Date(),
                    status: "draft"
                )
            )
            try? messageStore.save(messages)
            statusMessage = "Coach reply ready — Keep or Discard."
            push(.turnReview)
        } catch {
            statusMessage = "Coach failed: \(error.localizedDescription)"
            let local = localCoachReply()
            pendingTurn = local
            push(.turnReview)
        }
    }

    private func localCoachReply() -> CoachTurn {
        let zone = currentZoneLabel
        let step = sessionPhases.indices.contains(currentStepIndex)
            ? sessionPhases[currentStepIndex].title
            : "Setup"
        let q = coachQuestion.isEmpty ? (speechTranscript.isEmpty ? "Can I play this card?" : speechTranscript) : coachQuestion
        let text =
            "Local tip (AI not configured): For \(activeSession?.gameName ?? "this game") at \(zone) during \(step) — "
            + "check the rulebook for \(q). Keep reviewed zones and steps; they will reuse on the next coach call."
        return CoachTurn(
            id: UUID().uuidString,
            sessionId: activeSession?.id ?? "",
            role: "coach",
            text: text,
            createdAt: Date()
        )
    }

    func keepTurn() {
        guard let turn = pendingTurn, let session = activeSession else { return }
        if let idx = messages.lastIndex(where: { $0.sessionId == session.id && $0.role == "coach" && $0.status == "draft" }) {
            messages[idx].status = "confirmed"
            messages[idx].text = turn.text
            try? messageStore.save(messages)
        }
        if !userFeedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let tip = PhaseStep(
                id: UUID().uuidString,
                sessionId: session.id,
                order: (sessionPhases.last?.order ?? 0) + 1,
                title: "Tip",
                hint: userFeedback,
                confirmedAt: Date()
            )
            phaseSteps.append(tip)
            try? phaseStore.save(phaseSteps)
        }
        pendingTurn = nil
        coachQuestion = ""
        userFeedback = ""
        statusMessage = "Coach reply kept."
        path = [.tableCoach]
        persistNavigation()
    }

    func discardTurn() {
        if let session = activeSession,
           let idx = messages.lastIndex(where: { $0.sessionId == session.id && $0.role == "coach" && $0.status == "draft" }) {
            messages.remove(at: idx)
            try? messageStore.save(messages)
        }
        pendingTurn = nil
        statusMessage = "Coach reply discarded."
        path = [.tableCoach]
        persistNavigation()
    }

    func playHostCue() {
        let cues = sessionHostCues
        guard !cues.isEmpty else {
            statusMessage = "No host cues yet — Keep a component draft first."
            return
        }
        if ttsCueIndex >= cues.count { ttsCueIndex = 0 }
        let cue = cues[ttsCueIndex]
        tts.onFinished = { [weak self] in
            self?.statusMessage = "Finished cue \(cue.sortIndex + 1)."
        }
        tts.play(cue.text)
        if let err = tts.lastError {
            statusMessage = err
        } else {
            statusMessage = "Playing host cue \(ttsCueIndex + 1)/\(cues.count)."
        }
    }

    func pauseHostCue() {
        tts.pause()
        statusMessage = "Host cue paused."
    }

    func nextHostCue() {
        let cues = sessionHostCues
        guard !cues.isEmpty else { return }
        ttsCueIndex = (ttsCueIndex + 1) % cues.count
        playHostCue()
    }

    func dictateRulesQuestion() async {
        speechBusy = true
        defer { speechBusy = false }
        do {
            let text = try await speechService.transcribeOnce()
            speechTranscript = text
            coachQuestion = text
            let spoken = SpokenQuestion(
                id: UUID().uuidString,
                sessionId: activeSession?.id ?? "",
                questionText: text,
                transcript: text,
                notes: "Triggered next tip from dictate",
                createdAt: Date()
            )
            spokenQuestions.insert(spoken, at: 0)
            try? spokenStore.save(spokenQuestions)
            statusMessage = "Spoken question captured — opening coach chat."
            // Advance tip on turn step bar
            if !sessionPhases.isEmpty {
                currentStepIndex = min(currentStepIndex + 1, sessionPhases.count - 1)
                selectStep(currentStepIndex)
            }
            push(.coachChat)
        } catch {
            statusMessage = "Dictate failed: \(error.localizedDescription). Type your rules question instead."
        }
    }
}
