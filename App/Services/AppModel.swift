import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import StopCueDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var frameSequences: [FrameSequence] = []
    @Published var drafts: [ShotPlanDraft] = []
    @Published var timingCues: [TimingCue] = []
    @Published var onionGuides: [OnionSkinGuide] = []
    @Published var turns: [CoachTurn] = []
    @Published var messages: [CoachMessage] = []
    @Published var countdownCues: [CountdownCue] = []
    @Published var dictatedIntervals: [DictatedInterval] = []

    @Published var activeProjectId: String?
    @Published var path: [StopCueRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingDraft: ShotPlanDraft?
    @Published var pendingTurn: CoachTurn?
    @Published var editingShotPlan = ""
    @Published var editingTiming = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var userFeedback = ""
    @Published var onionDraftNotes = ""
    @Published var aiUnavailableReason: String?
    @Published var currentFrameIndex = 0
    @Published var pendingFrameId: String?
    @Published var newProjectTitle = ""
    @Published var newFrameRate = "12"
    @Published var showOnionSkin = true
    @Published var onionOpacity = 0.35
    @Published var draftOverlayPoint: CGPoint?
    @Published var intervalField = "400"
    @Published var cueTextField = ""
    @Published var notesField = ""
    @Published var showCamera = false
    @Published var ttsCueIndex = 0
    @Published var pendingAlignmentHint = ""
    @Published var pendingDisplacementNote = ""

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<StopCueRoute>
    let tts = CountdownCueTTSPlayer()
    let speechService = SpeechRecognitionService()

    private let projectStore: AtomicCodableStore<[Project]>
    private let sequenceStore: AtomicCodableStore<[FrameSequence]>
    private let draftStore: AtomicCodableStore<[ShotPlanDraft]>
    private let timingStore: AtomicCodableStore<[TimingCue]>
    private let onionStore: AtomicCodableStore<[OnionSkinGuide]>
    private let turnStore: AtomicCodableStore<[CoachTurn]>
    private let messageStore: AtomicCodableStore<[CoachMessage]>
    private let countdownStore: AtomicCodableStore<[CountdownCue]>
    private let dictatedStore: AtomicCodableStore<[DictatedInterval]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = StopCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingCoachAction: (() -> Void)?

    var activeProject: Project? {
        guard let id = activeProjectId else { return projects.first }
        return projects.first(where: { $0.id == id }) ?? projects.first
    }

    var projectSequences: [FrameSequence] {
        guard let id = activeProject?.id else { return [] }
        return frameSequences.filter { $0.projectId == id }.sorted { $0.capturedAt < $1.capturedAt }
    }

    var activeSequence: FrameSequence? {
        projectSequences.last
    }

    var frameLabels: [String] {
        guard let seq = activeSequence else {
            return ["F1", "F2", "F3", "F4"]
        }
        if seq.frameRefs.isEmpty {
            return (1 ... 4).map { "F\($0)" }
        }
        return seq.frameRefs.enumerated().map { idx, _ in "F\(idx + 1)" }
    }

    var confirmedGuides: [OnionSkinGuide] {
        guard let id = activeProject?.id else { return [] }
        return onionGuides.filter { $0.projectId == id && $0.status == "confirmed" }
    }

    var sessionMessages: [CoachMessage] {
        guard let id = activeProject?.id else { return [] }
        return messages.filter { $0.projectId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeProject?.id else { return [] }
        return turns.filter { $0.projectId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var sessionCues: [CountdownCue] {
        guard let id = activeProject?.id else { return [] }
        return countdownCues.filter { $0.projectId == id }.sorted { $0.sortIndex < $1.sortIndex }
    }

    var sessionDictated: [DictatedInterval] {
        guard let id = activeProject?.id else { return [] }
        return dictatedIntervals.filter { $0.projectId == id }.sorted { $0.createdAt > $1.createdAt }
    }

    var projectTimings: [TimingCue] {
        guard let id = activeProject?.id else { return [] }
        return timingCues.filter { $0.projectId == id }.sorted { $0.confirmedAt > $1.confirmedAt }
    }

    var overlayMarks: [OnionSkinOverlayCanvas.Mark] {
        confirmedGuides.enumerated().map { idx, g in
            .init(id: g.id, xNorm: 0.35 + Double(idx % 3) * 0.15, yNorm: 0.4, label: g.alignmentHint)
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("StopCue", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        projectStore = StopCueStores.projectStore(directory: root)
        sequenceStore = StopCueStores.frameSequenceStore(directory: root)
        draftStore = StopCueStores.shotPlanDraftStore(directory: root)
        timingStore = StopCueStores.timingCueStore(directory: root)
        onionStore = StopCueStores.onionSkinGuideStore(directory: root)
        turnStore = StopCueStores.coachTurnStore(directory: root)
        messageStore = StopCueStores.coachMessageStore(directory: root)
        countdownStore = StopCueStores.countdownCueStore(directory: root)
        dictatedStore = StopCueStores.dictatedIntervalStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = StopCueStores.storeURL(directory: root, name: StopCueStores.aiConsentLocal)
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
                    try? await StopCueStores.consentKeychainStore().save(mirrorData)
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
        projects = (try? projectStore.load()) ?? []
        frameSequences = (try? sequenceStore.load()) ?? []
        drafts = (try? draftStore.load()) ?? []
        timingCues = (try? timingStore.load()) ?? []
        onionGuides = (try? onionStore.load()) ?? []
        turns = (try? turnStore.load()) ?? []
        messages = (try? messageStore.load()) ?? []
        countdownCues = (try? countdownStore.load()) ?? []
        dictatedIntervals = (try? dictatedStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeProjectId == nil {
            activeProjectId = projects.first?.id
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

    func push(_ route: StopCueRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    func createProject() {
        let title = newProjectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let rate = Double(newFrameRate) ?? 12
        let project = Project(
            id: UUID().uuidString,
            title: title.isEmpty ? "Stop-motion set" : title,
            targetFrameRate: rate,
            createdAt: Date(),
            updatedAt: Date()
        )
        projects.insert(project, at: 0)
        try? projectStore.save(projects)
        activeProjectId = project.id
        currentFrameIndex = 0
        newProjectTitle = ""
        statusMessage = "Project opened — capture or import frames."
        push(.captureImport)
    }

    func openProject(_ project: Project) {
        activeProjectId = project.id
        currentFrameIndex = 0
        path = [.stopCoach]
        persistNavigation()
    }

    func selectFrame(_ index: Int) {
        currentFrameIndex = index
        guard var project = activeProject else { return }
        project.updatedAt = Date()
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
            try? projectStore.save(projects)
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
        guard let project = activeProject else {
            statusMessage = "Create a project first."
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

        var seq = activeSequence
        if seq == nil {
            seq = FrameSequence(
                id: UUID().uuidString,
                projectId: project.id,
                frameRefs: [],
                source: source,
                capturedAt: Date()
            )
        }
        guard var sequence = seq else { return }
        sequence.frameRefs.append("imports/\(name)")
        sequence.source = source
        sequence.capturedAt = Date()
        if let idx = frameSequences.firstIndex(where: { $0.id == sequence.id }) {
            frameSequences[idx] = sequence
        } else {
            frameSequences.append(sequence)
        }
        try sequenceStore.save(frameSequences)
        pendingFrameId = id

        let recognized = ShotPlanRecognizer.recognize(
            image: image,
            project: project,
            frameCount: sequence.frameRefs.count - 1
        )
        pendingAlignmentHint = recognized.alignmentHint
        pendingDisplacementNote = recognized.displacementNote
        let draft = ShotPlanDraft(
            id: UUID().uuidString,
            projectId: project.id,
            frameSequenceId: sequence.id,
            shotPlanSummary: recognized.shotPlanSummary,
            timingSummary: recognized.timingSummary,
            status: "draft",
            updatedAt: Date()
        )
        pendingDraft = draft
        editingShotPlan = draft.shotPlanSummary
        editingTiming = draft.timingSummary
        statusMessage = "Shot-plan draft ready — Keep, Discard, or Edit."
        push(.frameReview)
    }

    func frameImage(at index: Int) -> UIImage? {
        guard let seq = activeSequence, seq.frameRefs.indices.contains(index) else { return nil }
        let path = supportRoot.appendingPathComponent(seq.frameRefs[index])
        return UIImage(contentsOfFile: path.path)
    }

    func currentFrameImage() -> UIImage? {
        frameImage(at: currentFrameIndex)
    }

    func previousFrameImage() -> UIImage? {
        guard currentFrameIndex > 0 else { return nil }
        return frameImage(at: currentFrameIndex - 1)
    }

    func keepShotPlanDraft() {
        guard var draft = pendingDraft, let project = activeProject else { return }
        draft.shotPlanSummary = editingShotPlan.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.shotPlanSummary : editingShotPlan
        draft.timingSummary = editingTiming.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.timingSummary : editingTiming
        draft.status = "confirmed"
        draft.updatedAt = Date()
        drafts.insert(draft, at: 0)
        try? draftStore.save(drafts)

        let intervalMs = Int(intervalField) ?? 400
        let timing = TimingCue(
            id: UUID().uuidString,
            projectId: project.id,
            intervalMs: intervalMs,
            countdownText: "3 · 2 · 1 · click",
            confirmedAt: Date()
        )
        timingCues.insert(timing, at: 0)
        try? timingStore.save(timingCues)

        let guide = OnionSkinGuide(
            id: UUID().uuidString,
            projectId: project.id,
            frameSequenceId: draft.frameSequenceId,
            alignmentHint: pendingAlignmentHint.isEmpty ? "Match prior silhouette" : pendingAlignmentHint,
            displacementNote: pendingDisplacementNote.isEmpty ? "Nudge closer" : pendingDisplacementNote,
            notes: onionDraftNotes,
            status: "confirmed",
            updatedAt: Date()
        )
        onionGuides.insert(guide, at: 0)
        try? onionStore.save(onionGuides)

        let cues = [
            CountdownCue(id: UUID().uuidString, projectId: project.id, cueKind: "countdown", text: "Three.", sortIndex: sessionCues.count, createdAt: Date()),
            CountdownCue(id: UUID().uuidString, projectId: project.id, cueKind: "countdown", text: "Two.", sortIndex: sessionCues.count + 1, createdAt: Date()),
            CountdownCue(id: UUID().uuidString, projectId: project.id, cueKind: "countdown", text: "One.", sortIndex: sessionCues.count + 2, createdAt: Date()),
            CountdownCue(id: UUID().uuidString, projectId: project.id, cueKind: "click", text: "Click — advance one sprocket.", sortIndex: sessionCues.count + 3, createdAt: Date()),
        ]
        countdownCues.append(contentsOf: cues)
        try? countdownStore.save(countdownCues)

        if var p = activeProject {
            p.updatedAt = Date()
            if let idx = projects.firstIndex(where: { $0.id == p.id }) {
                projects[idx] = p
                try? projectStore.save(projects)
            }
        }
        pendingDraft = nil
        pendingFrameId = nil
        statusMessage = "Shot plan kept — open film-sprocket timeline + onion skin."
        path = [.stopCoach]
        persistNavigation()
    }

    func discardShotPlanDraft() {
        pendingDraft = nil
        pendingFrameId = nil
        statusMessage = "Draft discarded — frames kept; nothing confirmed."
        if activeProject != nil {
            path = [.stopCoach]
        } else {
            popToHome()
        }
        persistNavigation()
    }

    func placeDraftOverlay(at point: CGPoint) {
        draftOverlayPoint = point
    }

    func keepOnionGuide() {
        guard let project = activeProject, let seq = activeSequence else {
            statusMessage = "Need a project with frames first."
            return
        }
        let notes: String
        if let point = draftOverlayPoint {
            notes = "Mark at (\(String(format: "%.2f", point.x)), \(String(format: "%.2f", point.y))) · \(onionDraftNotes)"
        } else {
            notes = onionDraftNotes.isEmpty ? "Onion alignment confirmed" : onionDraftNotes
        }
        let guide = OnionSkinGuide(
            id: UUID().uuidString,
            projectId: project.id,
            frameSequenceId: seq.id,
            alignmentHint: pendingAlignmentHint.isEmpty ? "Align prior frame edge" : pendingAlignmentHint,
            displacementNote: pendingDisplacementNote.isEmpty ? "Next frame a bit closer" : pendingDisplacementNote,
            notes: notes,
            status: "confirmed",
            updatedAt: Date()
        )
        onionGuides.insert(guide, at: 0)
        try? onionStore.save(onionGuides)
        draftOverlayPoint = nil
        onionDraftNotes = ""
        statusMessage = "Onion-skin guide kept."
        path = [.stopCoach]
        persistNavigation()
    }

    func discardOnionGuide() {
        draftOverlayPoint = nil
        statusMessage = "Onion guide discarded."
        path = [.stopCoach]
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
                    projectId: activeProject?.id ?? "",
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
        statusMessage = "AI send blocked — timeline, onion skin, and local cues still available."
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
        guard let project = activeProject, let key = apiKey() else {
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
            let descriptor = activeSequence.map { "\($0.frameRefs.count) frames · \($0.source)" } ?? "no sequence"
            let shot = drafts.first(where: { $0.projectId == project.id && $0.status == "confirmed" })?.shotPlanSummary ?? "no shot plan"
            let timing = projectTimings.first?.countdownText ?? "no timing"
            let onion = confirmedGuides.first.map { "\($0.alignmentHint); \($0.displacementNote)" } ?? "no onion notes"
            let priorFeedback = sessionTurns.filter { $0.role == "user" }.map(\.text)
            let dictated = sessionDictated.map { "interval=\($0.intervalMs)ms cue=\($0.cueText) notes=\($0.notes)" }
            let reply = try await client.coachStopMotion(
                frameSequenceDescriptor: descriptor,
                shotPlanSummary: shot,
                timingSummary: timing,
                onionSkinNotes: onion,
                currentFrameLabel: frameLabels.indices.contains(currentFrameIndex) ? frameLabels[currentFrameIndex] : "F1",
                chatText: coachQuestion.isEmpty ? "Next frame a bit closer?" : coachQuestion,
                voiceTranscript: speechTranscript,
                dictatedIntervalFields: dictated,
                priorFeedback: priorFeedback + (userFeedback.isEmpty ? [] : [userFeedback]),
                projectId: project.id
            )
            pendingTurn = reply
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    projectId: project.id,
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
        let project = activeProject
        let timing = projectTimings.first
        let text: String
        if let project, let timing {
            text = "Local tip (AI key gap): on \(project.title) at \(frameLabels.indices.contains(currentFrameIndex) ? frameLabels[currentFrameIndex] : "F1"), keep interval \(timing.intervalMs)ms and use onion-skin to align. Configure DeepSeek for live coach."
        } else {
            text = "Local tip: capture frames, Keep a shot plan, advance the film-sprocket timeline with onion-skin overlay. Configure DeepSeek key for live coach."
        }
        return CoachTurn(
            id: UUID().uuidString,
            projectId: project?.id ?? "",
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
                    projectId: turn.projectId,
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
                    projectId: turn.projectId,
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
        path = [.stopCoach]
        persistNavigation()
    }

    func discardPendingTurn() {
        if let turn = pendingTurn {
            messages.removeAll { $0.text == turn.text && $0.status == "draft" }
            try? messageStore.save(messages)
        }
        pendingTurn = nil
        statusMessage = "Coach draft discarded."
        path = [.stopCoach]
        persistNavigation()
    }

    func playCountdownCues() {
        let corpus = sessionCues.map(\.text)
        guard !corpus.isEmpty else {
            statusMessage = "No countdown cues yet — Keep a shot plan first."
            return
        }
        if ttsCueIndex >= corpus.count { ttsCueIndex = 0 }
        let text = corpus[ttsCueIndex]
        tts.speak(text)
        statusMessage = "Playing cue \(ttsCueIndex + 1)/\(corpus.count)"
    }

    func pauseCountdownCues() {
        tts.stop()
    }

    func nextCountdownCue() {
        ttsCueIndex += 1
        playCountdownCues()
        if !frameLabels.isEmpty {
            selectFrame(ttsCueIndex % frameLabels.count)
        }
    }

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
        case "interval":
            let digits = trimmed.filter(\.isNumber)
            if !digits.isEmpty { intervalField = digits }
            cueTextField = trimmed
        case "cue":
            cueTextField = trimmed
        case "notes":
            notesField = trimmed
        default:
            notesField = trimmed
        }
    }

    func saveDictatedInterval() {
        guard let project = activeProject else { return }
        let item = DictatedInterval(
            id: UUID().uuidString,
            projectId: project.id,
            intervalMs: Int(intervalField) ?? 400,
            cueText: cueTextField.isEmpty ? "next frame a bit closer" : cueTextField,
            notes: notesField,
            transcript: speechTranscript,
            createdAt: Date()
        )
        dictatedIntervals.insert(item, at: 0)
        try? dictatedStore.save(dictatedIntervals)
        if coachQuestion.isEmpty, !notesField.isEmpty {
            coachQuestion = notesField
        } else if coachQuestion.isEmpty, !cueTextField.isEmpty {
            coachQuestion = cueTextField
        }
        statusMessage = "Interval fields saved into coach context."
    }
}
