import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import HiveCueDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var inspections: [Inspection] = []
    @Published var frameShots: [FrameShot] = []
    @Published var drafts: [BroodDraft] = []
    @Published var findings: [Finding] = []
    @Published var overlays: [AnnotatedOverlay] = []
    @Published var turns: [CoachTurn] = []
    @Published var messages: [CoachMessage] = []
    @Published var voiceNotes: [VoiceNote] = []
    @Published var dictatedFields: [DictatedField] = []

    @Published var activeInspectionId: String?
    @Published var path: [HiveCueRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingDraft: BroodDraft?
    @Published var pendingTurn: CoachTurn?
    @Published var editingBrood = ""
    @Published var editingStores = ""
    @Published var editingPests = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var userFeedback = ""
    @Published var overlayDraftLabel = "brood"
    @Published var aiUnavailableReason: String?
    @Published var currentFrameIndex = 0
    @Published var pendingShotId: String?
    @Published var newHiveLabel = ""
    @Published var dictateBuffer = ""
    @Published var ttsNoteIndex = 0
    @Published var draftOverlayPoint: CGPoint?
    @Published var queenSeen = ""
    @Published var temperament = ""
    @Published var notesField = ""
    @Published var showCamera = false

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<HiveCueRoute>
    let tts = HandsFreeTTSPlayer()
    let speechService = SpeechRecognitionService()

    private let inspectionStore: AtomicCodableStore<[Inspection]>
    private let shotStore: AtomicCodableStore<[FrameShot]>
    private let draftStore: AtomicCodableStore<[BroodDraft]>
    private let findingStore: AtomicCodableStore<[Finding]>
    private let overlayStore: AtomicCodableStore<[AnnotatedOverlay]>
    private let turnStore: AtomicCodableStore<[CoachTurn]>
    private let messageStore: AtomicCodableStore<[CoachMessage]>
    private let voiceNoteStore: AtomicCodableStore<[VoiceNote]>
    private let dictatedFieldStore: AtomicCodableStore<[DictatedField]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = HiveCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingCoachAction: (() -> Void)?
    private var pendingHeatMarks: [(x: Double, y: Double, heat: Double, label: String)] = []

    var activeInspection: Inspection? {
        guard let id = activeInspectionId else { return inspections.first }
        return inspections.first(where: { $0.id == id }) ?? inspections.first
    }

    var frameLabels: [String] {
        guard let inspection = activeInspection else {
            return ["F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8"]
        }
        let shots = inspectionShots
        if shots.isEmpty {
            return (1 ... 8).map { "F\($0)" }
        }
        return shots.enumerated().map { idx, shot in
            "F\(idx + 1) · \(shot.source.prefix(3))"
        }
    }

    var railSteps: [String] {
        let labels = frameLabels
        if labels.isEmpty { return ["Open lid", "Pull frame", "Read brood", "Mark stores"] }
        return labels
    }

    var nextRailHint: String {
        let next = min(currentFrameIndex + 1, max(0, railSteps.count - 1))
        if railSteps.indices.contains(next), next != currentFrameIndex {
            return "Next: \(railSteps[next])"
        }
        return "Ask coach or dictate fields"
    }

    var inspectionShots: [FrameShot] {
        guard let id = activeInspection?.id else { return [] }
        return frameShots.filter { $0.inspectionId == id }.sorted { $0.capturedAt > $1.capturedAt }
    }

    var inspectionFindings: [Finding] {
        guard let id = activeInspection?.id else { return [] }
        return findings.filter { $0.inspectionId == id }.sorted { $0.confirmedAt > $1.confirmedAt }
    }

    var inspectionOverlays: [AnnotatedOverlay] {
        guard let id = activeInspection?.id else { return [] }
        return overlays.filter { $0.inspectionId == id && $0.status == "confirmed" }
    }

    var inspectionMessages: [CoachMessage] {
        guard let id = activeInspection?.id else { return [] }
        return messages.filter { $0.inspectionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var inspectionTurns: [CoachTurn] {
        guard let id = activeInspection?.id else { return [] }
        return turns.filter { $0.inspectionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var inspectionVoiceNotes: [VoiceNote] {
        guard let id = activeInspection?.id else { return [] }
        return voiceNotes.filter { $0.inspectionId == id }.sorted { $0.sortIndex < $1.sortIndex }
    }

    var inspectionDictated: [DictatedField] {
        guard let id = activeInspection?.id else { return [] }
        return dictatedFields.filter { $0.inspectionId == id }.sorted { $0.createdAt > $1.createdAt }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("HiveCue", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        inspectionStore = HiveCueStores.inspectionStore(directory: root)
        shotStore = HiveCueStores.frameShotStore(directory: root)
        draftStore = HiveCueStores.broodDraftStore(directory: root)
        findingStore = HiveCueStores.findingStore(directory: root)
        overlayStore = HiveCueStores.annotatedOverlayStore(directory: root)
        turnStore = HiveCueStores.coachTurnStore(directory: root)
        messageStore = HiveCueStores.coachMessageStore(directory: root)
        voiceNoteStore = HiveCueStores.voiceNoteStore(directory: root)
        dictatedFieldStore = HiveCueStores.dictatedFieldStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = HiveCueStores.storeURL(directory: root, name: HiveCueStores.aiConsentLocal)
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
                    try? await HiveCueStores.consentKeychainStore().save(mirrorData)
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
        inspections = (try? inspectionStore.load()) ?? []
        frameShots = (try? shotStore.load()) ?? []
        drafts = (try? draftStore.load()) ?? []
        findings = (try? findingStore.load()) ?? []
        overlays = (try? overlayStore.load()) ?? []
        turns = (try? turnStore.load()) ?? []
        messages = (try? messageStore.load()) ?? []
        voiceNotes = (try? voiceNoteStore.load()) ?? []
        dictatedFields = (try? dictatedFieldStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeInspectionId == nil {
            activeInspectionId = inspections.first?.id
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

    func push(_ route: HiveCueRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    // MARK: - Inspections

    func createInspection() {
        let label = newHiveLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        let inspection = Inspection(
            id: UUID().uuidString,
            hiveLabel: label.isEmpty ? "Hive A" : label,
            inspectedAt: Date(),
            currentFrameLabel: "F1",
            updatedAt: Date()
        )
        inspections.insert(inspection, at: 0)
        try? inspectionStore.save(inspections)
        activeInspectionId = inspection.id
        currentFrameIndex = 0
        newHiveLabel = ""
        statusMessage = "Inspection opened — capture or import a brood frame."
        push(.captureImport)
    }

    func openInspection(_ inspection: Inspection) {
        activeInspectionId = inspection.id
        currentFrameIndex = 0
        path = [.inspectionCoach]
        persistNavigation()
    }

    func selectFrame(_ index: Int) {
        currentFrameIndex = index
        guard var inspection = activeInspection else { return }
        inspection.currentFrameLabel = frameLabels.indices.contains(index) ? frameLabels[index] : "F\(index + 1)"
        inspection.updatedAt = Date()
        if let idx = inspections.firstIndex(where: { $0.id == inspection.id }) {
            inspections[idx] = inspection
            try? inspectionStore.save(inspections)
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
        guard let inspection = activeInspection else {
            statusMessage = "Create an inspection first."
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
        let shot = FrameShot(
            id: id,
            inspectionId: inspection.id,
            relativePath: "imports/\(name)",
            source: source,
            capturedAt: Date()
        )
        frameShots.insert(shot, at: 0)
        try shotStore.save(frameShots)
        pendingShotId = id

        let recognized = BroodRecognizer.recognize(image: image, inspection: inspection)
        pendingHeatMarks = recognized.heatMarks
        let draft = BroodDraft(
            id: UUID().uuidString,
            inspectionId: inspection.id,
            frameShotId: id,
            broodSummary: recognized.broodSummary,
            storesSummary: recognized.storesSummary,
            pestSigns: recognized.pestSigns,
            status: "draft",
            updatedAt: Date()
        )
        pendingDraft = draft
        editingBrood = draft.broodSummary
        editingStores = draft.storesSummary
        editingPests = draft.pestSigns
        statusMessage = "Brood draft ready — Keep, Discard, or Edit."
        push(.broodReview)
    }

    func imageURL(for shot: FrameShot) -> URL {
        supportRoot.appendingPathComponent(shot.relativePath)
    }

    func loadShotImage(_ shot: FrameShot) -> UIImage? {
        UIImage(contentsOfFile: imageURL(for: shot).path)
    }

    // MARK: - Brood review

    func keepBroodDraft() {
        guard var draft = pendingDraft, var inspection = activeInspection else { return }
        draft.broodSummary = editingBrood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.broodSummary : editingBrood
        draft.storesSummary = editingStores.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.storesSummary : editingStores
        draft.pestSigns = editingPests.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.pestSigns : editingPests
        draft.status = "confirmed"
        draft.updatedAt = Date()
        drafts.insert(draft, at: 0)
        try? draftStore.save(drafts)

        let tags: [(String, String)] = [
            ("brood", draft.broodSummary),
            ("stores", draft.storesSummary),
            ("pest", draft.pestSigns),
        ]
        for (tag, detail) in tags {
            findings.append(
                Finding(
                    id: UUID().uuidString,
                    inspectionId: draft.inspectionId,
                    frameShotId: draft.frameShotId,
                    tag: tag,
                    detail: detail,
                    confirmedAt: Date()
                )
            )
        }
        try? findingStore.save(findings)

        for mark in pendingHeatMarks {
            overlays.append(
                AnnotatedOverlay(
                    id: UUID().uuidString,
                    inspectionId: draft.inspectionId,
                    frameShotId: draft.frameShotId,
                    xNorm: mark.x,
                    yNorm: mark.y,
                    heatValue: mark.heat,
                    label: mark.label,
                    status: "confirmed",
                    updatedAt: Date()
                )
            )
        }
        try? overlayStore.save(overlays)
        pendingHeatMarks = []

        let note = VoiceNote(
            id: UUID().uuidString,
            inspectionId: draft.inspectionId,
            text: "Brood: \(draft.broodSummary). Stores: \(draft.storesSummary).",
            sortIndex: inspectionVoiceNotes.count,
            createdAt: Date()
        )
        voiceNotes.append(note)
        try? voiceNoteStore.save(voiceNotes)

        inspection.updatedAt = Date()
        if let idx = inspections.firstIndex(where: { $0.id == inspection.id }) {
            inspections[idx] = inspection
            try? inspectionStore.save(inspections)
        }
        pendingDraft = nil
        pendingShotId = nil
        statusMessage = "Findings kept — open comb grid and rail."
        path = [.inspectionCoach]
        persistNavigation()
    }

    func discardBroodDraft() {
        if let shotId = pendingDraft?.frameShotId ?? pendingShotId {
            frameShots.removeAll { $0.id == shotId }
            try? shotStore.save(frameShots)
        }
        pendingDraft = nil
        pendingShotId = nil
        pendingHeatMarks = []
        statusMessage = "Draft discarded — nothing saved."
        if activeInspection != nil {
            path = [.inspectionCoach]
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
        guard let inspection = activeInspection,
              let shot = inspectionShots.first,
              let point = draftOverlayPoint else {
            statusMessage = "Tap the frame to place a heat mark first."
            return
        }
        overlays.append(
            AnnotatedOverlay(
                id: UUID().uuidString,
                inspectionId: inspection.id,
                frameShotId: shot.id,
                xNorm: point.x,
                yNorm: point.y,
                heatValue: 0.65,
                label: overlayDraftLabel,
                status: "confirmed",
                updatedAt: Date()
            )
        )
        try? overlayStore.save(overlays)
        draftOverlayPoint = nil
        statusMessage = "Heat mark kept."
        path = [.inspectionCoach]
        persistNavigation()
    }

    func discardOverlayDraft() {
        draftOverlayPoint = nil
        statusMessage = "Heat draft discarded."
        path = [.inspectionCoach]
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
                    inspectionId: activeInspection?.id ?? "",
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
        statusMessage = "AI send blocked — comb grid, rail, and local notes still available."
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
        guard let inspection = activeInspection, let key = apiKey() else {
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
            let plan = railSteps.joined(separator: " → ")
            let brood = inspectionFindings.first(where: { $0.tag == "brood" })?.detail ?? "no brood finding"
            let stores = inspectionFindings.first(where: { $0.tag == "stores" })?.detail ?? "no stores finding"
            let pests = inspectionFindings.first(where: { $0.tag == "pest" })?.detail ?? "no pest finding"
            let priorFeedback = inspectionTurns.filter { $0.role == "user" }.map(\.text)
            let dictated = inspectionDictated.map { "\($0.fieldKey)=\($0.value)" }
            let reply = try await client.coachInspection(
                framePhotoDescriptor: inspectionShots.first.map { "\($0.source) \($0.capturedAt)" } ?? "no photo",
                broodSummary: brood,
                storesSummary: stores,
                pestSigns: pests,
                inspectionPlanSummary: plan,
                currentFrameLabel: inspection.currentFrameLabel,
                chatText: coachQuestion.isEmpty ? "What should I do on the next frame?" : coachQuestion,
                voiceTranscript: speechTranscript,
                dictatedFields: dictated,
                priorFeedback: priorFeedback + (userFeedback.isEmpty ? [] : [userFeedback]),
                inspectionId: inspection.id
            )
            pendingTurn = reply
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    inspectionId: inspection.id,
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
        let inspection = activeInspection
        let finding = inspectionFindings.first
        let text: String
        if let inspection, let finding {
            text = "Local tip (AI key gap): on \(inspection.hiveLabel) at \(inspection.currentFrameLabel), \(finding.tag): \(finding.detail) Advance the inspection rail, then mark heat if stores look thin. Configure DeepSeek for live coach."
        } else {
            text = "Local tip: capture a brood frame, Keep findings, then use the hex comb grid + inspection rail. Configure DeepSeek key for live coach."
        }
        return CoachTurn(
            id: UUID().uuidString,
            inspectionId: inspection?.id ?? "",
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
                    inspectionId: turn.inspectionId,
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
                    inspectionId: turn.inspectionId,
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
        path = [.inspectionCoach]
        persistNavigation()
    }

    func discardPendingTurn() {
        if let turn = pendingTurn {
            messages.removeAll { $0.text == turn.text && $0.status == "draft" }
            try? messageStore.save(messages)
        }
        pendingTurn = nil
        statusMessage = "Coach draft discarded."
        path = [.inspectionCoach]
        persistNavigation()
    }

    // MARK: - TTS

    func playHandsFree() {
        let notes = inspectionVoiceNotes
        let findingsText = inspectionFindings.map { "\($0.tag): \($0.detail)" }
        let corpus = notes.map(\.text) + findingsText
        guard !corpus.isEmpty else {
            statusMessage = "No notes yet — Keep a brood finding first."
            return
        }
        if ttsNoteIndex >= corpus.count { ttsNoteIndex = 0 }
        let text = corpus[ttsNoteIndex]
        tts.speak(text)
        statusMessage = "Playing note \(ttsNoteIndex + 1)/\(corpus.count)"
    }

    func pauseHandsFree() {
        tts.stop()
    }

    func nextHandsFreeNote() {
        ttsNoteIndex += 1
        playHandsFree()
        if railSteps.indices.contains(ttsNoteIndex % max(railSteps.count, 1)) {
            selectFrame(ttsNoteIndex % railSteps.count)
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
                dictateBuffer = text
                applyDictation(fieldKey: fieldKey, value: text, transcript: text)
                statusMessage = "Dictated \(fieldKey)."
            } catch {
                statusMessage = error.localizedDescription
            }
        }
    }

    func applyDictation(fieldKey: String, value: String, transcript: String) {
        guard let inspection = activeInspection else { return }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        switch fieldKey {
        case "queen_seen": queenSeen = trimmed
        case "temperament": temperament = trimmed
        case "notes": notesField = trimmed
        default: break
        }
        dictatedFields.insert(
            DictatedField(
                id: UUID().uuidString,
                inspectionId: inspection.id,
                fieldKey: fieldKey,
                value: trimmed,
                transcript: transcript,
                createdAt: Date()
            ),
            at: 0
        )
        try? dictatedFieldStore.save(dictatedFields)
        if fieldKey == "notes" || coachQuestion.isEmpty {
            coachQuestion = trimmed
        }
    }

    func saveTypedFields() {
        if !queenSeen.isEmpty { applyDictation(fieldKey: "queen_seen", value: queenSeen, transcript: queenSeen) }
        if !temperament.isEmpty { applyDictation(fieldKey: "temperament", value: temperament, transcript: temperament) }
        if !notesField.isEmpty { applyDictation(fieldKey: "notes", value: notesField, transcript: notesField) }
        statusMessage = "Inspection fields saved."
    }
}
