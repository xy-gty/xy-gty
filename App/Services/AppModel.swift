import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import WorkrestDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var formShots: [FormShot] = []
    @Published var drafts: [WorkrestDraft] = []
    @Published var corrections: [FormCorrection] = []
    @Published var blocks: [IntervalBlock] = []
    @Published var overlays: [AnnotatedOverlay] = []
    @Published var turns: [CoachTurn] = []
    @Published var messages: [CoachMessage] = []
    @Published var intents: [VoiceIntent] = []

    @Published var activeSessionId: String?
    @Published var path: [WorkrestRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingDraft: WorkrestDraft?
    @Published var pendingTurn: CoachTurn?
    @Published var editingPosture = ""
    @Published var editingFocus = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var userFeedback = ""
    @Published var overlayDraftLabel = ""
    @Published var aiUnavailableReason: String?
    @Published var currentBlockIndex = 0
    @Published var pendingShotId: String?
    @Published var newSessionTitle = ""
    @Published var dictateBuffer = ""
    @Published var ttsBlockIndex = 0
    @Published var ringSecondsRemaining = 40
    @Published var ringTotalSeconds = 40
    @Published var ringIsRest = false
    @Published var selectedPolaroidIndex: Int?

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<WorkrestRoute>
    let tts = HandsFreeTTSPlayer()
    let speechService = SpeechRecognitionService()

    private let sessionStore: AtomicCodableStore<[Session]>
    private let shotStore: AtomicCodableStore<[FormShot]>
    private let draftStore: AtomicCodableStore<[WorkrestDraft]>
    private let correctionStore: AtomicCodableStore<[FormCorrection]>
    private let blockStore: AtomicCodableStore<[IntervalBlock]>
    private let overlayStore: AtomicCodableStore<[AnnotatedOverlay]>
    private let turnStore: AtomicCodableStore<[CoachTurn]>
    private let messageStore: AtomicCodableStore<[CoachMessage]>
    private let intentStore: AtomicCodableStore<[VoiceIntent]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = WorkrestStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingCoachAction: (() -> Void)?
    private var pendingOverlayPoint: CGPoint?
    private var ringTimer: Timer?

    var activeSession: Session? {
        guard let id = activeSessionId else { return sessions.first }
        return sessions.first(where: { $0.id == id }) ?? sessions.first
    }

    var sessionBlocks: [IntervalBlock] {
        guard let id = activeSession?.id else { return [] }
        return blocks.filter { $0.sessionId == id }.sorted { $0.sortIndex < $1.sortIndex }
    }

    var sessionShots: [FormShot] {
        guard let id = activeSession?.id else { return [] }
        return formShots.filter { $0.sessionId == id }.sorted { $0.capturedAt > $1.capturedAt }
    }

    var sessionCorrections: [FormCorrection] {
        guard let id = activeSession?.id else { return [] }
        return corrections.filter { $0.sessionId == id }.sorted { $0.confirmedAt > $1.confirmedAt }
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

    var chipLabels: [String] {
        let list = sessionBlocks
        if list.isEmpty {
            return ["Warm-up · 30/20", "Main HIIT · 40/20", "Finisher · 20/40"]
        }
        return list.map { "\($0.label) · \($0.workSeconds)/\($0.restSeconds)" }
    }

    var polaroidTitles: [String] {
        let cues = sessionCorrections
        if cues.isEmpty {
            return ["Snap a mid-set pose"]
        }
        return cues.map { $0.cueText.isEmpty ? $0.jointHint : $0.cueText }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Workrest", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        sessionStore = WorkrestStores.sessionStore(directory: root)
        shotStore = WorkrestStores.formShotStore(directory: root)
        draftStore = WorkrestStores.workrestDraftStore(directory: root)
        correctionStore = WorkrestStores.formCorrectionStore(directory: root)
        blockStore = WorkrestStores.intervalBlockStore(directory: root)
        overlayStore = WorkrestStores.annotatedOverlayStore(directory: root)
        turnStore = WorkrestStores.coachTurnStore(directory: root)
        messageStore = WorkrestStores.coachMessageStore(directory: root)
        intentStore = WorkrestStores.voiceIntentStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = WorkrestStores.storeURL(directory: root, name: WorkrestStores.aiConsentLocal)
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
                    try? await WorkrestStores.consentKeychainStore().save(mirrorData)
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
        syncRingFromCurrentBlock()
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
        formShots = (try? shotStore.load()) ?? []
        drafts = (try? draftStore.load()) ?? []
        corrections = (try? correctionStore.load()) ?? []
        blocks = (try? blockStore.load()) ?? []
        overlays = (try? overlayStore.load()) ?? []
        turns = (try? turnStore.load()) ?? []
        messages = (try? messageStore.load()) ?? []
        intents = (try? intentStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = sessions.first?.id
        }
        syncRingFromCurrentBlock()
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

    func push(_ route: WorkrestRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    // MARK: - Sessions

    func createSession() {
        let title = newSessionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let session = Session(
            id: UUID().uuidString,
            title: title.isEmpty ? "HIIT session" : title,
            targetBodyArea: "full body",
            currentBlockLabel: "Warm-up",
            updatedAt: Date()
        )
        sessions.insert(session, at: 0)
        try? sessionStore.save(sessions)
        activeSessionId = session.id
        seedDefaultBlocks(for: session.id)
        newSessionTitle = ""
        statusMessage = "Session created — capture a mid-set form photo."
        push(.captureImport)
    }

    private func seedDefaultBlocks(for sessionId: String) {
        let defaults: [(String, Int, Int, Int)] = [
            ("Warm-up", 30, 20, 2),
            ("Main HIIT", 40, 20, 4),
            ("Finisher", 20, 40, 2),
        ]
        for (idx, item) in defaults.enumerated() {
            blocks.append(
                IntervalBlock(
                    id: UUID().uuidString,
                    sessionId: sessionId,
                    label: item.0,
                    workSeconds: item.1,
                    restSeconds: item.2,
                    rounds: item.3,
                    sortIndex: idx
                )
            )
        }
        try? blockStore.save(blocks)
        currentBlockIndex = 0
        syncRingFromCurrentBlock()
    }

    func openSession(_ session: Session) {
        activeSessionId = session.id
        currentBlockIndex = 0
        path = [.sessionCoach]
        persistNavigation()
        syncRingFromCurrentBlock()
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
        let shot = FormShot(
            id: id,
            sessionId: session.id,
            relativePath: "imports/\(name)",
            source: source,
            capturedAt: Date()
        )
        formShots.insert(shot, at: 0)
        try shotStore.save(formShots)
        pendingShotId = id

        let recognized = FormRecognizer.recognize(image: image, session: session)
        let draft = WorkrestDraft(
            id: UUID().uuidString,
            sessionId: session.id,
            formShotId: id,
            postureSummary: recognized.posture,
            correctionFocus: recognized.focus,
            status: "draft",
            updatedAt: Date()
        )
        pendingDraft = draft
        editingPosture = draft.postureSummary
        editingFocus = draft.correctionFocus
        statusMessage = "Form draft ready — Keep, Discard, or Edit."
        push(.formReview)
    }

    func imageURL(for shot: FormShot) -> URL {
        supportRoot.appendingPathComponent(shot.relativePath)
    }

    func loadShotImage(_ shot: FormShot) -> UIImage? {
        UIImage(contentsOfFile: imageURL(for: shot).path)
    }

    // MARK: - Form review

    func keepFormDraft() {
        guard var draft = pendingDraft, var session = activeSession else { return }
        draft.postureSummary = editingPosture.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.postureSummary : editingPosture
        draft.correctionFocus = editingFocus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? draft.correctionFocus : editingFocus
        draft.status = "confirmed"
        draft.updatedAt = Date()
        drafts.insert(draft, at: 0)
        try? draftStore.save(drafts)

        let correction = FormCorrection(
            id: UUID().uuidString,
            sessionId: draft.sessionId,
            formShotId: draft.formShotId,
            jointHint: draft.correctionFocus,
            alignmentHint: draft.postureSummary,
            cueText: draft.correctionFocus,
            confirmedAt: Date()
        )
        corrections.append(correction)
        try? correctionStore.save(corrections)

        session.updatedAt = Date()
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
            try? sessionStore.save(sessions)
        }
        pendingDraft = nil
        pendingShotId = nil
        statusMessage = "Form correction kept."
        path = [.sessionCoach]
        persistNavigation()
    }

    func discardFormDraft() {
        if let shotId = pendingDraft?.formShotId ?? pendingShotId {
            formShots.removeAll { $0.id == shotId }
            try? shotStore.save(formShots)
        }
        pendingDraft = nil
        pendingShotId = nil
        statusMessage = "Draft discarded — nothing saved."
        if activeSession != nil {
            path = [.sessionCoach]
        } else {
            popToHome()
        }
        persistNavigation()
    }

    func selectBlock(_ index: Int) {
        currentBlockIndex = index
        guard var session = activeSession, sessionBlocks.indices.contains(index) else {
            syncRingFromCurrentBlock()
            return
        }
        session.currentBlockLabel = sessionBlocks[index].label
        session.updatedAt = Date()
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
            try? sessionStore.save(sessions)
        }
        syncRingFromCurrentBlock()
    }

    func syncRingFromCurrentBlock() {
        let list = sessionBlocks
        if list.indices.contains(currentBlockIndex) {
            let block = list[currentBlockIndex]
            ringIsRest = false
            ringTotalSeconds = block.workSeconds
            ringSecondsRemaining = block.workSeconds
        } else {
            ringIsRest = false
            ringTotalSeconds = 40
            ringSecondsRemaining = 40
        }
    }

    func startRingCountdown() {
        ringTimer?.invalidate()
        ringTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.ringSecondsRemaining > 0 {
                    self.ringSecondsRemaining -= 1
                } else {
                    self.advanceRingPhase()
                }
            }
        }
    }

    func pauseRingCountdown() {
        ringTimer?.invalidate()
        ringTimer = nil
    }

    private func advanceRingPhase() {
        let list = sessionBlocks
        guard list.indices.contains(currentBlockIndex) else { return }
        let block = list[currentBlockIndex]
        if !ringIsRest {
            ringIsRest = true
            ringTotalSeconds = block.restSeconds
            ringSecondsRemaining = block.restSeconds
            tts.speak("Rest. \(block.restSeconds) seconds.")
        } else {
            ringIsRest = false
            let next = min(currentBlockIndex + 1, max(0, list.count - 1))
            currentBlockIndex = next
            let nextBlock = list[next]
            ringTotalSeconds = nextBlock.workSeconds
            ringSecondsRemaining = nextBlock.workSeconds
            tts.speak("Work. \(nextBlock.label). \(nextBlock.workSeconds) seconds.")
        }
    }

    func skipRest() {
        guard ringIsRest else {
            statusMessage = "Not in rest — chip rail still on work."
            return
        }
        advanceRingPhase()
        statusMessage = "Rest skipped."
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
        statusMessage = "AI send blocked — local chip rail and rest ring still available."
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
            let plan = sessionBlocks.map { "\($0.label) \($0.workSeconds)/\($0.restSeconds)" }.joined(separator: "; ")
            let posture = sessionCorrections.first.map { "\($0.jointHint): \($0.cueText)" } ?? "no correction yet"
            let priorFeedback = sessionTurns.filter { $0.role == "user" }.map(\.text)
            let reply = try await client.coachForm(
                formPhotoDescriptor: sessionShots.first.map { "\($0.source) \($0.capturedAt)" } ?? "no photo",
                postureSummary: posture,
                intervalPlanSummary: plan.isEmpty ? "default HIIT blocks" : plan,
                currentBlockLabel: session.currentBlockLabel,
                correctionFocus: sessionCorrections.first?.cueText ?? "",
                chatText: coachQuestion.isEmpty ? "Plan my next HIIT block" : coachQuestion,
                voiceTranscript: speechTranscript,
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
        let block = sessionBlocks.indices.contains(currentBlockIndex) ? sessionBlocks[currentBlockIndex] : sessionBlocks.first
        let correction = sessionCorrections.first
        let text: String
        if let block, let session {
            let cue = correction.map { " Keep hips stacked: \($0.cueText)." } ?? ""
            text = "Local form tip (AI key gap): on \(block.label) in \(session.title), work \(block.workSeconds)s / rest \(block.restSeconds)s.\(cue) Configure DeepSeek for live coach."
        } else {
            text = "Local form tip: capture a mid-set pose, Keep a correction, then run the chip rail + rest ring. Configure DeepSeek key for live coach."
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
        if let kept = messages.first(where: { $0.sessionId == turn.sessionId && $0.status == "draft" && $0.text == turn.text }) {
            var confirmed = kept
            confirmed.status = "confirmed"
            messages.removeAll { $0.id == kept.id }
            messages.append(confirmed)
        } else {
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    sessionId: turn.sessionId,
                    role: turn.role,
                    text: turn.text,
                    createdAt: turn.createdAt,
                    status: "confirmed"
                )
            )
        }
        messages.removeAll { $0.sessionId == turn.sessionId && $0.status == "draft" }
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
            messages.removeAll { $0.sessionId == turn.sessionId && $0.status == "draft" }
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
            overlayDraftLabel = sessionCorrections.first?.cueText ?? "Align form"
        }
    }

    func keepOverlayMark() {
        guard let session = activeSession,
              let shot = sessionShots.first,
              let point = pendingOverlayPoint else {
            statusMessage = "Tap the form photo to place a mark."
            return
        }
        let mark = AnnotatedOverlay(
            id: UUID().uuidString,
            sessionId: session.id,
            formShotId: shot.id,
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
        statusMessage = "Annotation kept on form shot."
    }

    func discardOverlayDraft() {
        pendingOverlayPoint = nil
        overlayDraftLabel = ""
        statusMessage = "Annotation draft cleared — original photo unchanged."
    }

    // MARK: - TTS / Dictate

    func playHandsFree() {
        let list = sessionBlocks
        guard !list.isEmpty else {
            statusMessage = "No interval blocks to speak yet."
            return
        }
        let idx = min(max(0, ttsBlockIndex), list.count - 1)
        currentBlockIndex = idx
        syncRingFromCurrentBlock()
        let block = list[idx]
        let text = "\(block.label). Work \(block.workSeconds) seconds. Rest \(block.restSeconds) seconds."
        tts.speak(text)
        statusMessage = "Speaking block \(idx + 1)."
        startRingCountdown()
    }

    func nextHandsFreeStep() {
        let list = sessionBlocks
        guard !list.isEmpty else { return }
        ttsBlockIndex = min(ttsBlockIndex + 1, list.count - 1)
        playHandsFree()
    }

    func pauseHandsFree() {
        tts.stop()
        pauseRingCountdown()
        statusMessage = "TTS paused."
    }

    func applyDictateIntent() {
        guard let session = activeSession else { return }
        let text = dictateBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            statusMessage = "Type or dictate an intent first."
            return
        }
        let lower = text.lowercased()
        let kind: String
        if lower.contains("skip") && lower.contains("rest") {
            kind = "skip_rest"
            skipRest()
        } else {
            kind = "coach_intent"
            if coachQuestion.isEmpty { coachQuestion = text }
        }
        let intent = VoiceIntent(
            id: UUID().uuidString,
            sessionId: session.id,
            transcript: text,
            intentKind: kind,
            createdAt: Date()
        )
        intents.insert(intent, at: 0)
        try? intentStore.save(intents)
        dictateBuffer = ""
        statusMessage = "Intent saved: \(kind)."
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

enum FormRecognizer {
    static func recognize(image: UIImage, session: Session) -> (posture: String, focus: String) {
        let pixels = Int(image.size.width * image.scale * image.size.height * image.scale)
        let focus: String
        if pixels > 2_000_000 {
            focus = "Knees tracking over toes"
        } else if pixels > 800_000 {
            focus = "Hips level, brace core"
        } else {
            focus = "Ribcage stacked over pelvis"
        }
        let posture = "Local mid-set read for \(session.targetBodyArea) (\(Int(image.size.width))×\(Int(image.size.height))). Review before Keep."
        return (posture, focus)
    }
}
