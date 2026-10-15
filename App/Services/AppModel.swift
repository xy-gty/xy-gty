import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import YarnCueDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var wipShots: [WIPShot] = []
    @Published var drafts: [StitchRecognitionDraft] = []
    @Published var stitchCues: [StitchCue] = []
    @Published var overlays: [AnnotatedOverlay] = []
    @Published var turns: [CoachTurn] = []
    @Published var messages: [CoachMessage] = []
    @Published var notes: [PatternNote] = []

    @Published var activeProjectId: String?
    @Published var path: [YarnCueRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingDraft: StitchRecognitionDraft?
    @Published var pendingTurn: CoachTurn?
    @Published var editingStitchName = ""
    @Published var editingRowNumber = 1
    @Published var editingNotes = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var userFeedback = ""
    @Published var overlayDraftLabel = ""
    @Published var aiUnavailableReason: String?
    @Published var currentStepIndex = 0
    @Published var pendingShotId: String?
    @Published var newProjectTitle = ""
    @Published var dictateBuffer = ""
    @Published var ttsStepIndex = 0

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<YarnCueRoute>
    let tts = HandsFreeTTSPlayer()
    let speechService = SpeechRecognitionService()

    private let projectsStore: AtomicCodableStore<[Project]>
    private let wipStore: AtomicCodableStore<[WIPShot]>
    private let draftStore: AtomicCodableStore<[StitchRecognitionDraft]>
    private let cueStore: AtomicCodableStore<[StitchCue]>
    private let overlayStore: AtomicCodableStore<[AnnotatedOverlay]>
    private let turnStore: AtomicCodableStore<[CoachTurn]>
    private let messageStore: AtomicCodableStore<[CoachMessage]>
    private let noteStore: AtomicCodableStore<[PatternNote]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = YarnCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingCoachAction: (() -> Void)?
    private var pendingOverlayPoint: CGPoint?

    var activeProject: Project? {
        guard let id = activeProjectId else { return projects.first }
        return projects.first(where: { $0.id == id }) ?? projects.first
    }

    var projectCues: [StitchCue] {
        guard let id = activeProject?.id else { return [] }
        return stitchCues.filter { $0.projectId == id }.sorted { $0.stepIndex < $1.stepIndex }
    }

    var projectShots: [WIPShot] {
        guard let id = activeProject?.id else { return [] }
        return wipShots.filter { $0.projectId == id }.sorted { $0.capturedAt > $1.capturedAt }
    }

    var projectOverlays: [AnnotatedOverlay] {
        guard let id = activeProject?.id else { return [] }
        return overlays.filter { $0.projectId == id && $0.status == "confirmed" }
    }

    var projectMessages: [CoachMessage] {
        guard let id = activeProject?.id else { return [] }
        return messages.filter { $0.projectId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var projectTurns: [CoachTurn] {
        guard let id = activeProject?.id else { return [] }
        return turns.filter { $0.projectId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var projectNotes: [PatternNote] {
        guard let id = activeProject?.id else { return [] }
        return notes.filter { $0.projectId == id }.sorted { $0.createdAt > $1.createdAt }
    }

    var stepLabels: [String] {
        let cues = projectCues
        if cues.isEmpty {
            return ["Capture a WIP to build next-row steps"]
        }
        return cues.map { "R\($0.rowNumber) · \($0.stitchName)" }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("YarnCue", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        projectsStore = YarnCueStores.projectStore(directory: root)
        wipStore = YarnCueStores.wipShotStore(directory: root)
        draftStore = YarnCueStores.stitchRecognitionDraftStore(directory: root)
        cueStore = YarnCueStores.stitchCueStore(directory: root)
        overlayStore = YarnCueStores.annotatedOverlayStore(directory: root)
        turnStore = YarnCueStores.coachTurnStore(directory: root)
        messageStore = YarnCueStores.coachMessageStore(directory: root)
        noteStore = YarnCueStores.patternNoteStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = YarnCueStores.storeURL(directory: root, name: YarnCueStores.aiConsentLocal)
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
                    try? await YarnCueStores.consentKeychainStore().save(mirrorData)
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
        projects = (try? projectsStore.load()) ?? []
        wipShots = (try? wipStore.load()) ?? []
        drafts = (try? draftStore.load()) ?? []
        stitchCues = (try? cueStore.load()) ?? []
        overlays = (try? overlayStore.load()) ?? []
        turns = (try? turnStore.load()) ?? []
        messages = (try? messageStore.load()) ?? []
        notes = (try? noteStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeProjectId == nil {
            activeProjectId = projects.first?.id
        }
        if let cues = activeProject.map({ id in stitchCues.filter { $0.projectId == id } }),
           let idx = cues.firstIndex(where: { $0.stepIndex == (activeProject?.currentRow ?? 0) }) {
            currentStepIndex = idx
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

    func push(_ route: YarnCueRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    // MARK: - Projects

    func createProject() {
        let title = newProjectTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let project = Project(
            id: UUID().uuidString,
            title: title.isEmpty ? "WIP project" : title,
            yarnSwatchHexes: YarnCueTheme.defaultSwatches,
            currentRow: 1,
            updatedAt: Date()
        )
        projects.insert(project, at: 0)
        try? projectsStore.save(projects)
        activeProjectId = project.id
        newProjectTitle = ""
        statusMessage = "Project created — capture a yarn or WIP photo."
        push(.captureImport)
    }

    func openProject(_ project: Project) {
        activeProjectId = project.id
        currentStepIndex = 0
        path = [.projectCoach]
        persistNavigation()
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
        let shot = WIPShot(
            id: id,
            projectId: project.id,
            relativePath: "imports/\(name)",
            source: source,
            capturedAt: Date()
        )
        wipShots.insert(shot, at: 0)
        try wipStore.save(wipShots)
        pendingShotId = id

        let recognized = StitchRecognizer.recognize(image: image, project: project)
        let draft = StitchRecognitionDraft(
            id: UUID().uuidString,
            projectId: project.id,
            wipShotId: id,
            stitchName: recognized.stitchName,
            rowNumber: recognized.rowNumber,
            stepIndex: projectCues.count,
            notes: recognized.notes,
            status: "draft",
            updatedAt: Date()
        )
        pendingDraft = draft
        editingStitchName = draft.stitchName
        editingRowNumber = draft.rowNumber
        editingNotes = draft.notes
        statusMessage = "Stitch draft ready — Keep, Discard, or Edit."
        push(.stitchReview)
    }

    func imageURL(for shot: WIPShot) -> URL {
        supportRoot.appendingPathComponent(shot.relativePath)
    }

    func loadShotImage(_ shot: WIPShot) -> UIImage? {
        UIImage(contentsOfFile: imageURL(for: shot).path)
    }

    // MARK: - Stitch review

    func keepStitchDraft() {
        guard var draft = pendingDraft, var project = activeProject else { return }
        draft.stitchName = editingStitchName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.stitchName : editingStitchName
        draft.rowNumber = max(1, editingRowNumber)
        draft.notes = editingNotes
        draft.status = "confirmed"
        draft.updatedAt = Date()
        drafts.insert(draft, at: 0)
        try? draftStore.save(drafts)

        let cue = StitchCue(
            id: UUID().uuidString,
            projectId: draft.projectId,
            stepIndex: projectCues.count,
            stitchName: draft.stitchName,
            rowNumber: draft.rowNumber,
            notes: draft.notes,
            confirmedAt: Date()
        )
        stitchCues.append(cue)
        try? cueStore.save(stitchCues)

        project.currentRow = draft.rowNumber
        project.updatedAt = Date()
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
            try? projectsStore.save(projects)
        }
        currentStepIndex = max(0, projectCues.count - 1)
        pendingDraft = nil
        pendingShotId = nil
        statusMessage = "Stitch cue kept."
        path = [.projectCoach]
        persistNavigation()
    }

    func discardStitchDraft() {
        if let shotId = pendingDraft?.wipShotId ?? pendingShotId {
            wipShots.removeAll { $0.id == shotId }
            try? wipStore.save(wipShots)
        }
        pendingDraft = nil
        pendingShotId = nil
        statusMessage = "Draft discarded — nothing saved."
        if activeProject != nil {
            path = [.projectCoach]
        } else {
            popToHome()
        }
        persistNavigation()
    }

    func selectStep(_ index: Int) {
        currentStepIndex = index
        guard var project = activeProject, projectCues.indices.contains(index) else { return }
        project.currentRow = projectCues[index].rowNumber
        project.updatedAt = Date()
        if let idx = projects.firstIndex(where: { $0.id == project.id }) {
            projects[idx] = project
            try? projectsStore.save(projects)
        }
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
        statusMessage = "AI send blocked — local next-row steps still available."
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
            let cueSummary = projectCues.map { "R\($0.rowNumber) \($0.stitchName)" }.joined(separator: "; ")
            let priorFeedback = projectTurns.filter { $0.role == "user" }.map(\.text)
            let reply = try await client.coachNextRow(
                wipPhotoDescriptor: projectShots.first.map { "\($0.source) \($0.capturedAt)" } ?? "no photo",
                recognizedStitchSummary: cueSummary.isEmpty ? "no cues yet" : cueSummary,
                currentRow: project.currentRow,
                nextRowIntent: coachQuestion.isEmpty ? "What is the next row stitch?" : coachQuestion,
                patternNoteText: projectNotes.first?.text ?? "",
                chatText: coachQuestion,
                voiceTranscript: speechTranscript,
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
        let cue = projectCues.indices.contains(currentStepIndex) ? projectCues[currentStepIndex] : projectCues.last
        let text: String
        if let cue, let project {
            text = "Local weave tip (AI key gap): after \(cue.stitchName) on row \(cue.rowNumber) in \(project.title), work the next row matching yarn tension; keep stitch count even. Configure DeepSeek for live coach."
        } else {
            text = "Local weave tip: capture a WIP, Keep a stitch cue, then ask for the next row. Configure DeepSeek key for live coach."
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
        if let kept = messages.first(where: { $0.projectId == turn.projectId && $0.status == "draft" && $0.text == turn.text }) {
            var confirmed = kept
            confirmed.status = "confirmed"
            messages.removeAll { $0.id == kept.id }
            messages.append(confirmed)
        } else {
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    projectId: turn.projectId,
                    role: turn.role,
                    text: turn.text,
                    createdAt: turn.createdAt,
                    status: "confirmed"
                )
            )
        }
        messages.removeAll { $0.projectId == turn.projectId && $0.status == "draft" }
        try? messageStore.save(messages)
        pendingTurn = nil
        coachQuestion = ""
        userFeedback = ""
        statusMessage = "Coach turn kept."
        if path.last == .turnReview { _ = path.popLast() }
        persistNavigation()
    }

    func discardPendingTurn() {
        if let turn = pendingTurn {
            messages.removeAll { $0.projectId == turn.projectId && $0.status == "draft" }
            try? messageStore.save(messages)
        }
        pendingTurn = nil
        statusMessage = "Coach draft discarded — not written."
        if path.last == .turnReview { _ = path.popLast() }
        persistNavigation()
    }

    // MARK: - Annotations

    func beginOverlayTap(at point: CGPoint, in size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        pendingOverlayPoint = CGPoint(x: point.x / size.width, y: point.y / size.height)
        if overlayDraftLabel.isEmpty {
            overlayDraftLabel = projectCues.indices.contains(currentStepIndex)
                ? projectCues[currentStepIndex].stitchName
                : "Stitch mark"
        }
    }

    func keepOverlayMark() {
        guard let project = activeProject,
              let shot = projectShots.first,
              let point = pendingOverlayPoint else {
            statusMessage = "Tap the WIP photo to place a mark."
            return
        }
        let mark = AnnotatedOverlay(
            id: UUID().uuidString,
            projectId: project.id,
            wipShotId: shot.id,
            xNorm: point.x,
            yNorm: point.y,
            label: overlayDraftLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Mark" : overlayDraftLabel,
            status: "confirmed",
            updatedAt: Date()
        )
        overlays.append(mark)
        try? overlayStore.save(overlays)
        pendingOverlayPoint = nil
        statusMessage = "Annotation kept on WIP."
    }

    func discardOverlayDraft() {
        pendingOverlayPoint = nil
        overlayDraftLabel = ""
        statusMessage = "Annotation draft cleared — original photo unchanged."
    }

    // MARK: - TTS / Dictate

    func playHandsFree() {
        let cues = projectCues
        guard !cues.isEmpty else {
            statusMessage = "No stitch cues to speak yet."
            return
        }
        let idx = min(max(0, ttsStepIndex), cues.count - 1)
        currentStepIndex = idx
        let cue = cues[idx]
        let text = "Row \(cue.rowNumber). \(cue.stitchName). \(cue.notes)"
        tts.speak(text)
        statusMessage = "Speaking step \(idx + 1)."
    }

    func nextHandsFreeStep() {
        let cues = projectCues
        guard !cues.isEmpty else { return }
        ttsStepIndex = min(ttsStepIndex + 1, cues.count - 1)
        playHandsFree()
    }

    func pauseHandsFree() {
        tts.stop()
        statusMessage = "TTS paused."
    }

    func saveDictatedNote() {
        guard let project = activeProject else { return }
        let text = dictateBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            statusMessage = "Type or dictate a note first."
            return
        }
        let note = PatternNote(
            id: UUID().uuidString,
            projectId: project.id,
            text: text,
            source: speechTranscript.isEmpty ? "typed" : "speech",
            createdAt: Date()
        )
        notes.insert(note, at: 0)
        try? noteStore.save(notes)
        if coachQuestion.isEmpty {
            coachQuestion = text
        }
        dictateBuffer = ""
        statusMessage = "Pattern note saved."
    }

    func startDictate() async {
        speechBusy = true
        defer { speechBusy = false }
        do {
            let text = try await speechService.transcribeOnce()
            speechTranscript = text
            dictateBuffer = text
            statusMessage = "Heard: \(text)"
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

enum StitchRecognizer {
    static func recognize(image: UIImage, project: Project) -> (stitchName: String, rowNumber: Int, notes: String) {
        let pixels = Int(image.size.width * image.scale * image.size.height * image.scale)
        let stitch: String
        if pixels > 2_000_000 {
            stitch = "Double crochet"
        } else if pixels > 800_000 {
            stitch = "Knit stockinette"
        } else {
            stitch = "Single crochet"
        }
        let row = max(1, project.currentRow)
        let notes = "Local recognition from WIP photo (\(Int(image.size.width))×\(Int(image.size.height))). Review before Keep."
        return (stitch, row, notes)
    }
}
