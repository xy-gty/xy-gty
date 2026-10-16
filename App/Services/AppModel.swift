import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import BightstepDomain

@MainActor
final class AppModel: ObservableObject {
    enum AppTab: Hashable { case rope, coach, overlays, settings }

    @Published var sessions: [PracticeSession] = []
    @Published var drafts: [KnotCaptureDraft] = []
    @Published var stages: [KnotStage] = []
    @Published var coachTurns: [CoachTurn] = []
    @Published var overlays: [StepOverlay] = []
    @Published var handsFreePlans: [HandsFreePlan] = []
    @Published var selectedTab: AppTab = .rope
    @Published var path: [BightstepRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var chatBusy = false
    @Published var recognitionBusy = false
    @Published var chatText = ""
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var editingDraft: KnotCaptureDraft?
    @Published var stageEditBuffer = ""
    @Published var pendingOverlay: StepOverlay?
    @Published var activeHandsFreePlan: HandsFreePlan?
    @Published var handsFreeStepIndex = 0
    @Published var aiUnavailableReason: String?
    @Published var pendingAIAction: (() -> Void)?
    @Published var showCameraPicker = false
    @Published var speechHost = SpeechCaptureHost()
    @Published var selectedStageID: UUID?
    @Published var selectedTurnID: UUID?
    @Published var selectedDiameter = "10 mm"
    @Published var practiceSummary = "Bowline practice"

    let storage: BightstepStorageRoot
    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<BightstepRoute>
    let handsFreeTTS = HandsFreeTTS()

    private var cachedAPIKey: String?
    private let keychain = BightstepConsentFacade.makeAPIKeyStore()

    var cameraHardwareAvailable: Bool { CameraCaptureAvailability.cameraHardwareAvailable }

    var selectedStage: KnotStage? {
        guard let id = selectedStageID else { return nil }
        return stages.first(where: { $0.id == id })
    }

    var savedOverlays: [StepOverlay] {
        overlays.filter { $0.status == "saved" }
            .sorted { ($0.savedAt ?? $0.createdAt) > ($1.savedAt ?? $1.createdAt) }
    }

    var diameterChips: [String] {
        let fromStages = stages.compactMap { stage -> String? in
            guard let mm = stage.ropeDiameterMM else { return nil }
            return "\(Int(mm)) mm"
        }
        let defaults = ["8 mm", "10 mm", "11 mm", "12 mm", "14 mm"]
        var seen = Set<String>()
        var out: [String] = []
        for tag in fromStages + defaults where seen.insert(tag).inserted {
            out.append(tag)
        }
        return Array(out.prefix(8))
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Bightstep", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        storage = BightstepStorageRoot(rootDirectory: root)
        try? FileManager.default.createDirectory(at: storage.photosDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: storage.overlaysDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(
            at: root.appendingPathComponent("domain", isDirectory: true),
            withIntermediateDirectories: true
        )
        navigation = BightstepNavigation.makeStore(directory: root)
        consentGate = BightstepConsentFacade.makeGate(storage: storage)
        consentGranted = consentGate.state.granted
        reload()
        Task { await self.loadAPIKeyFromKeychain() }
        refreshAIAvailability()
    }

    private func loadAPIKeyFromKeychain() async {
        if let data = try? await keychain.load(),
           let key = String(data: data, encoding: .utf8),
           !key.isEmpty {
            cachedAPIKey = key
        }
        // Optional Secrets.xcconfig mirror via Info.plist injection is not required; keychain / untracked xcconfig gap is honest.
        if cachedAPIKey == nil, let bundled = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY") as? String,
           !bundled.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !bundled.contains("$(") {
            cachedAPIKey = bundled
        }
        refreshAIAvailability()
    }

    func reload() {
        sessions = (try? storage.practiceSessions.load())?.sessions ?? []
        drafts = (try? storage.knotCaptureDrafts.load())?.drafts ?? []
        stages = (try? storage.knotStages.load())?.stages ?? []
        coachTurns = (try? storage.coachTurns.load())?.turns ?? []
        overlays = (try? storage.stepOverlays.load())?.overlays ?? []
        handsFreePlans = (try? storage.handsFreePlans.load())?.plans ?? []
        consentGranted = consentGate.state.granted
        if let restored = try? navigation.restore(), !restored.isEmpty {
            path = restored
        }
    }

    func persistPath() {
        try? navigation.save(path)
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI unavailable — DeepSeek key not configured (local knot demo still works)."
        } else if !consentGranted {
            aiUnavailableReason = "AI unavailable until you allow DeepSeek sharing."
        } else {
            aiUnavailableReason = nil
        }
    }

    func apiKey() -> String? {
        guard let key = cachedAPIKey, !key.isEmpty else { return nil }
        return key
    }

    func push(_ route: BightstepRoute) {
        path.append(route)
        persistPath()
    }

    func popToRoot() {
        path.removeAll()
        persistPath()
    }

    // MARK: - Capture / import

    func importPhotoData(_ data: Data, sourceKind: String) {
        let name = "knot-\(UUID().uuidString).jpg"
        let url = storage.photosDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            let mm = Double(selectedDiameter.split(separator: " ").first.flatMap { Int($0) } ?? 10)
            var draft = KnotCaptureDraft(
                localFileName: name,
                proposedStageTags: ["Step 3 · rabbit through hole"],
                proposedWrongHauls: ["Loop too small — ease standing part"],
                proposedRopeDiameterMM: mm,
                sourceKind: sourceKind
            )
            recognitionBusy = true
            statusMessage = "Reading knot stage…"
            Task {
                await self.recognizeDraft(&draft)
                self.recognitionBusy = false
                self.statusMessage = nil
                self.editingDraft = draft
                self.stageEditBuffer = draft.proposedStageTags.joined(separator: ", ")
                self.drafts.insert(draft, at: 0)
                try? self.storage.knotCaptureDrafts.save(KnotCaptureDraftCatalog(drafts: self.drafts))
                self.push(.stageReview)
            }
        } catch {
            statusMessage = "Could not save photo: \(error.localizedDescription)"
        }
    }

    func importDemoKnotPhoto() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 720, height: 960))
        let image = renderer.image { ctx in
            UIColor(red: 1, green: 0.984, blue: 0.922, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 720, height: 960))
            UIColor(red: 0.706, green: 0.325, blue: 0.035, alpha: 1).setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 180, y: 120))
            path.addCurve(to: CGPoint(x: 360, y: 420), controlPoint1: CGPoint(x: 80, y: 260), controlPoint2: CGPoint(x: 240, y: 360))
            path.addCurve(to: CGPoint(x: 520, y: 700), controlPoint1: CGPoint(x: 480, y: 480), controlPoint2: CGPoint(x: 420, y: 620))
            path.addCurve(to: CGPoint(x: 280, y: 820), controlPoint1: CGPoint(x: 620, y: 780), controlPoint2: CGPoint(x: 360, y: 860))
            path.lineWidth = 28
            path.lineCapStyle = .round
            path.stroke()
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .semibold),
                .foregroundColor: UIColor(red: 0.11, green: 0.10, blue: 0.09, alpha: 1)
            ]
            NSString(string: "Demo bowline · Step 3").draw(at: CGPoint(x: 80, y: 60), withAttributes: attrs)
        }
        if let data = image.jpegData(compressionQuality: 0.9) {
            importPhotoData(data, sourceKind: "demo")
        }
    }

    func beginTakePhoto() {
        if cameraHardwareAvailable {
            showCameraPicker = true
        } else {
            importDemoKnotPhoto()
        }
    }

    func cancelCameraPicker() { showCameraPicker = false }

    func handleCameraImageData(_ data: Data) {
        showCameraPicker = false
        importPhotoData(data, sourceKind: "camera")
    }

    func handlePickedPhoto() {
        guard let item = selectedPhotoItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                self.importPhotoData(data, sourceKind: "photo_library")
            } else {
                self.statusMessage = "Could not load selected photo."
            }
            self.selectedPhotoItem = nil
        }
    }

    private func recognizeDraft(_ draft: inout KnotCaptureDraft) async {
        guard let key = apiKey(), consentGranted else {
            if draft.proposedStageTags.isEmpty {
                draft.proposedStageTags = ["Step 3 · rabbit through hole"]
            }
            return
        }
        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let gate = consentGate
            let client = DeepSeekClient(apiKey: key, assertConsent: {
                _ = try gate.permit()
            })
            let url = storage.photoFileURL(for: draft)
            let recognized = try await client.recognizeKnotStage(photoURL: url)
            draft.proposedStageTags = recognized.stageTags
            draft.proposedWrongHauls = recognized.wrongHauls
            if let mm = recognized.ropeDiameterMM {
                draft.proposedRopeDiameterMM = mm
            }
        } catch {
            statusMessage = "Recognition fallback (local tags): \(error.localizedDescription)"
        }
    }

    // MARK: - Review

    func keepStage() {
        guard var draft = editingDraft else { return }
        if !stageEditBuffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.proposedStageTags = stageEditBuffer
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        let stage = KnotStage(
            id: draft.id,
            practiceSessionID: draft.practiceSessionID,
            localFileName: draft.localFileName,
            stageTags: draft.proposedStageTags,
            wrongHauls: draft.proposedWrongHauls,
            ropeDiameterMM: draft.proposedRopeDiameterMM,
            sourceKind: draft.sourceKind,
            includesCoachingDisclaimer: true,
            confirmedAt: Date()
        )
        stages.insert(stage, at: 0)
        drafts.removeAll { $0.id == draft.id }
        try? storage.knotStages.save(KnotStageCatalog(stages: stages))
        try? storage.knotCaptureDrafts.save(KnotCaptureDraftCatalog(drafts: drafts))
        editingDraft = nil
        selectedStageID = stage.id
        path.removeAll { $0 == .stageReview }
        push(.knotStageDetail)
        statusMessage = "Stage kept."
    }

    func rejectDraft() {
        guard let draft = editingDraft else { return }
        drafts.removeAll { $0.id == draft.id }
        try? storage.knotCaptureDrafts.save(KnotCaptureDraftCatalog(drafts: drafts))
        editingDraft = nil
        path.removeAll { $0 == .stageReview }
        statusMessage = "Draft discarded."
    }

    func beginEditStage() {
        guard let draft = editingDraft else { return }
        stageEditBuffer = draft.proposedStageTags.joined(separator: ", ")
    }

    // MARK: - Consent

    func requireConsentThen(_ action: @escaping () -> Void) {
        refreshAIAvailability()
        if consentGranted {
            action()
            return
        }
        pendingAIAction = action
        showConsent = true
    }

    func grantConsentFromSheet() {
        do {
            try consentGate.grant()
            consentGranted = true
            showConsent = false
            refreshAIAvailability()
            let action = pendingAIAction
            pendingAIAction = nil
            action?()
        } catch {
            statusMessage = "Could not save consent: \(error.localizedDescription)"
        }
    }

    func declineConsentFromSheet() {
        showConsent = false
        pendingAIAction = nil
        statusMessage = "Local rope carousel still works. AI stays off until you allow sharing."
        refreshAIAvailability()
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "AI sharing revoked. Outbound requests stop immediately."
        } catch {
            statusMessage = "Could not revoke: \(error.localizedDescription)"
        }
    }

    // MARK: - Coach

    func sendCoachChat() {
        let prompt = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        requireConsentThen { [weak self] in
            Task { await self?.performCoachChat(prompt: prompt) }
        }
    }

    func sendCoachChatLocalDemoIfNeeded() {
        let prompt = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        if apiKey() == nil || !consentGranted {
            Task { await performLocalDemoCoach(prompt: prompt) }
        } else {
            sendCoachChat()
        }
    }

    private func priorFeedbackLines() -> [String] {
        var lines: [String] = []
        for stage in stages.prefix(3) {
            lines.append("confirmed_stage:\(stage.stageTags.joined(separator: "/"))")
        }
        for overlay in savedOverlays.prefix(2) {
            lines.append("saved_overlay:\(overlay.annotationNotes.joined(separator: ";"))")
        }
        return lines
    }

    private func performCoachChat(prompt: String) async {
        chatBusy = true
        statusMessage = "Planning next haul…"
        defer {
            chatBusy = false
            if statusMessage == "Planning next haul…" { statusMessage = nil }
        }
        guard let key = apiKey() else {
            await performLocalDemoCoach(prompt: prompt)
            return
        }
        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let gate = consentGate
            let client = DeepSeekClient(apiKey: key, assertConsent: {
                _ = try gate.permit()
            })
            let stageSummary = selectedStage.map {
                "tags=\($0.stageTags.joined(separator: ",")); wrong=\($0.wrongHauls.joined(separator: ",")); diameter=\($0.ropeDiameterMM.map { String(Int($0)) } ?? "?") mm"
            } ?? "none"
            let response = try await client.coachNextHaul(
                prompt: prompt,
                stageSummary: stageSummary,
                practiceSummary: practiceSummary,
                priorFeedback: priorFeedbackLines()
            )
            let turn = CoachTurn(
                practiceSessionID: selectedStage?.practiceSessionID,
                knotStageID: selectedStageID,
                promptText: prompt,
                responseText: response.text,
                haulContext: response.nextHaul,
                speechTranscript: "",
                includesCoachingDisclaimer: true
            )
            coachTurns.insert(turn, at: 0)
            try? storage.coachTurns.save(CoachTurnCatalog(turns: coachTurns))
            selectedTurnID = turn.id
            chatText = ""
        } catch {
            statusMessage = "Coach failed: \(error.localizedDescription)"
            await performLocalDemoCoach(prompt: prompt)
        }
    }

    private func performLocalDemoCoach(prompt: String) async {
        let next = "Pull working end to set the knot"
        let text = """
        Local demo next-haul (AI outbound off or unavailable).
        Next haul: \(next).
        Safety: ease the standing part if the loop is tight.
        \(BightstepIdentity.coachingDisclaimer)
        You asked: \(prompt)
        """
        let turn = CoachTurn(
            practiceSessionID: selectedStage?.practiceSessionID,
            knotStageID: selectedStageID,
            promptText: prompt,
            responseText: text,
            haulContext: next,
            includesCoachingDisclaimer: true
        )
        coachTurns.insert(turn, at: 0)
        try? storage.coachTurns.save(CoachTurnCatalog(turns: coachTurns))
        selectedTurnID = turn.id
        chatText = ""
        statusMessage = aiUnavailableReason ?? "Local demo coach turn saved."
    }

    // MARK: - Overlay

    func makeStepOverlay() {
        let name = "overlay-\(UUID().uuidString).png"
        let url = storage.overlaysDirectory.appendingPathComponent(name)
        let notes = ["1 Mark bite", "2 Rabbit through hole", "3 Tree around standing part"]
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 720, height: 960))
        let image = renderer.image { ctx in
            UIColor(red: 1, green: 0.984, blue: 0.922, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 720, height: 960))
            UIColor(red: 0.055, green: 0.647, blue: 0.914, alpha: 1).setFill()
            for (i, note) in notes.enumerated() {
                let y = CGFloat(180 + i * 180)
                UIBezierPath(ovalIn: CGRect(x: 80, y: y, width: 48, height: 48)).fill()
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                    .foregroundColor: UIColor(red: 0.11, green: 0.10, blue: 0.09, alpha: 1)
                ]
                NSString(string: note).draw(at: CGPoint(x: 150, y: y + 8), withAttributes: attrs)
            }
        }
        if let data = image.pngData() {
            try? data.write(to: url, options: .atomic)
        }
        let overlay = StepOverlay(
            practiceSessionID: selectedStage?.practiceSessionID,
            knotStageID: selectedStageID,
            coachTurnID: selectedTurnID,
            localFileName: name,
            annotationNotes: notes,
            status: "draft"
        )
        pendingOverlay = overlay
        push(.stepOverlay)
    }

    func savePendingOverlay() {
        guard var overlay = pendingOverlay else { return }
        overlay.status = "saved"
        overlay.savedAt = Date()
        overlays.insert(overlay, at: 0)
        try? storage.stepOverlays.save(StepOverlayCatalog(overlays: overlays))
        pendingOverlay = nil
        path.removeAll { $0 == .stepOverlay }
        statusMessage = "Overlay saved."
        selectedTab = .overlays
    }

    func discardPendingOverlay() {
        pendingOverlay = nil
        path.removeAll { $0 == .stepOverlay }
        statusMessage = "Overlay discarded."
    }

    // MARK: - Hands-free TTS

    func openHandsFree(for overlay: StepOverlay? = nil, stage: KnotStage? = nil) {
        let steps = [
            "Ease the standing part, then pull.",
            "Form the rabbit hole with the working end.",
            "Pass the rabbit through and around the tree.",
            "Pull working end to set the bowline.",
            BightstepIdentity.coachingDisclaimer
        ]
        let plan = HandsFreePlan(
            knotStageID: stage?.id ?? selectedStageID,
            stepOverlayID: overlay?.id ?? pendingOverlay?.id,
            steps: steps,
            includesCoachingDisclaimer: true
        )
        handsFreePlans.insert(plan, at: 0)
        try? storage.handsFreePlans.save(HandsFreePlanCatalog(plans: handsFreePlans))
        activeHandsFreePlan = plan
        handsFreeStepIndex = 0
        push(.handsFreeCoach)
    }

    func playCurrentHandsFreeStep() {
        guard let plan = activeHandsFreePlan else { return }
        do {
            try handsFreeTTS.speak(plan: plan, at: handsFreeStepIndex)
        } catch {
            statusMessage = "TTS unavailable: \(error.localizedDescription)"
        }
    }

    func pauseHandsFree() { handsFreeTTS.stop() }

    func nextHandsFreeStep() {
        guard let plan = activeHandsFreePlan else { return }
        if let next = handsFreeTTS.nextIndex(after: handsFreeStepIndex, stepCount: plan.steps.count) {
            handsFreeStepIndex = next
            playCurrentHandsFreeStep()
        } else {
            statusMessage = "End of hands-free steps."
        }
    }

    // MARK: - Speech

    func startMicIntoChat() {
        push(.speechCapture)
        Task { await speechHost.start() }
    }

    func stopMicAndFillChat() {
        let text = speechHost.consumeTranscript()
        if !text.isEmpty {
            chatText = chatText.isEmpty ? text : chatText + " " + text
        }
        path.removeAll { $0 == .speechCapture }
        selectedTab = .coach
    }
}
