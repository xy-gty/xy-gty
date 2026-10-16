import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import AirspanDomain

@MainActor
final class AppModel: ObservableObject {
    enum AppTab: Hashable { case jobs, coach, diagrams, settings }

    @Published var jobSites: [JobSite] = []
    @Published var drafts: [DuctRunDraft] = []
    @Published var ductRuns: [DuctRun] = []
    @Published var sizingSessions: [SizingSession] = []
    @Published var sizeDiagrams: [SizeDiagram] = []
    @Published var fieldStepPlans: [FieldStepPlan] = []
    @Published var selectedTab: AppTab = .jobs
    @Published var path: [AirspanRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var chatBusy = false
    @Published var recognitionBusy = false
    @Published var chatText = ""
    @Published var cfmKnob: Double = 420
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var editingDraft: DuctRunDraft?
    @Published var sizeEditBuffer = ""
    @Published var pendingDiagram: SizeDiagram?
    @Published var activeFieldPlan: FieldStepPlan?
    @Published var fieldStepIndex = 0
    @Published var aiUnavailableReason: String?
    @Published var pendingAIAction: (() -> Void)?
    @Published var showCameraPicker = false
    @Published var speechHost = SpeechCaptureHost()
    @Published var selectedRunID: UUID?
    @Published var selectedSessionID: UUID?

    let storage: AirspanStorageRoot
    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<AirspanRoute>
    let fieldTTS = FieldStepsTTS()

    private var cachedAPIKey: String?
    private let keychain = AirspanConsentFacade.makeAPIKeyStore()

    var cameraHardwareAvailable: Bool { CameraCaptureAvailability.cameraHardwareAvailable }

    var selectedRun: DuctRun? {
        guard let id = selectedRunID else { return nil }
        return ductRuns.first(where: { $0.id == id })
    }

    var savedDiagrams: [SizeDiagram] {
        sizeDiagrams.filter { $0.status == "saved" }
            .sorted { ($0.savedAt ?? $0.createdAt) > ($1.savedAt ?? $1.createdAt) }
    }

    var sizeChips: [String] {
        let fromRuns = ductRuns.flatMap(\.sizeTags)
        let defaults = ["6\" round", "8\" round", "10×8", "12×10", "14×8"]
        var seen = Set<String>()
        var out: [String] = []
        for tag in fromRuns + defaults where seen.insert(tag).inserted {
            out.append(tag)
        }
        return Array(out.prefix(8))
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Airspan", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        storage = AirspanStorageRoot(rootDirectory: root)
        try? FileManager.default.createDirectory(at: storage.photosDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: storage.diagramsDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(
            at: root.appendingPathComponent("domain", isDirectory: true),
            withIntermediateDirectories: true
        )
        navigation = AirspanNavigation.makeStore(directory: root)
        consentGate = AirspanConsentFacade.makeGate(storage: storage)
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
        refreshAIAvailability()
    }

    func reload() {
        jobSites = (try? storage.jobSites.load())?.sites ?? []
        drafts = (try? storage.ductRunDrafts.load())?.drafts ?? []
        ductRuns = (try? storage.ductRuns.load())?.runs ?? []
        sizingSessions = (try? storage.sizingSessions.load())?.sessions ?? []
        sizeDiagrams = (try? storage.sizeDiagrams.load())?.diagrams ?? []
        fieldStepPlans = (try? storage.fieldStepPlans.load())?.plans ?? []
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
            aiUnavailableReason = "AI unavailable — DeepSeek key not configured (local formula demo still works)."
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

    func push(_ route: AirspanRoute) {
        path.append(route)
        persistPath()
    }

    func popToRoot() {
        path.removeAll()
        persistPath()
    }

    // MARK: - Capture / import

    func importPhotoData(_ data: Data, sourceKind: String) {
        let name = "duct-\(UUID().uuidString).jpg"
        let url = storage.photosDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            var draft = DuctRunDraft(
                localFileName: name,
                proposedSizeTags: ["10×8 rectangular"],
                proposedDiameterInches: nil,
                proposedLengthFeet: 12,
                sourceKind: sourceKind
            )
            recognitionBusy = true
            statusMessage = "Reading duct run…"
            Task {
                await self.recognizeDraft(&draft)
                self.recognitionBusy = false
                self.statusMessage = nil
                self.editingDraft = draft
                self.sizeEditBuffer = draft.proposedSizeTags.joined(separator: ", ")
                self.drafts.insert(draft, at: 0)
                try? self.storage.ductRunDrafts.save(DuctRunDraftCatalog(drafts: self.drafts))
                self.push(.ductRunReview)
            }
        } catch {
            statusMessage = "Could not save photo: \(error.localizedDescription)"
        }
    }

    func importDemoJobPhoto() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 720, height: 540))
        let image = renderer.image { ctx in
            UIColor(red: 0.94, green: 0.98, blue: 1.0, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 720, height: 540))
            UIColor(red: 0.05, green: 0.45, blue: 0.56, alpha: 1).setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 80, y: 360))
            path.addLine(to: CGPoint(x: 280, y: 220))
            path.addLine(to: CGPoint(x: 520, y: 260))
            path.addLine(to: CGPoint(x: 640, y: 160))
            path.lineWidth = 18
            path.stroke()
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .semibold),
                .foregroundColor: UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1)
            ]
            NSString(string: "Demo duct run · 10×8").draw(at: CGPoint(x: 80, y: 420), withAttributes: attrs)
        }
        if let data = image.jpegData(compressionQuality: 0.9) {
            importPhotoData(data, sourceKind: "demo")
        }
    }

    func beginTakePhoto() {
        if cameraHardwareAvailable {
            showCameraPicker = true
        } else {
            // Simulator: synthetic still → same review path
            importDemoJobPhoto()
        }
    }

    func cancelCameraPicker() {
        showCameraPicker = false
    }

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

    private func recognizeDraft(_ draft: inout DuctRunDraft) async {
        guard let key = apiKey(), consentGranted else {
            if draft.proposedSizeTags.isEmpty {
                draft.proposedSizeTags = ["10×8 rectangular"]
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
            let recognized = try await client.recognizeDuctRun(photoURL: url)
            draft.proposedSizeTags = recognized.sizeTags
            draft.proposedDiameterInches = recognized.diameterInches
            draft.proposedLengthFeet = recognized.lengthFeet
        } catch {
            statusMessage = "Recognition fallback (local tags): \(error.localizedDescription)"
        }
    }

    // MARK: - Review

    func useDraft() {
        guard var draft = editingDraft else { return }
        if !sizeEditBuffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.proposedSizeTags = sizeEditBuffer
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        let run = DuctRun(
            id: draft.id,
            jobSiteID: draft.jobSiteID,
            localFileName: draft.localFileName,
            sizeTags: draft.proposedSizeTags,
            diameterInches: draft.proposedDiameterInches,
            lengthFeet: draft.proposedLengthFeet,
            sourceKind: draft.sourceKind,
            confirmedAt: Date()
        )
        ductRuns.insert(run, at: 0)
        drafts.removeAll { $0.id == draft.id }
        try? storage.ductRuns.save(DuctRunCatalog(runs: ductRuns))
        try? storage.ductRunDrafts.save(DuctRunDraftCatalog(drafts: drafts))
        editingDraft = nil
        selectedRunID = run.id
        path.removeAll { $0 == .ductRunReview }
        push(.ductRunDetail)
        statusMessage = "Run saved."
    }

    func rejectDraft() {
        guard let draft = editingDraft else { return }
        drafts.removeAll { $0.id == draft.id }
        try? storage.ductRunDrafts.save(DuctRunDraftCatalog(drafts: drafts))
        editingDraft = nil
        path.removeAll { $0 == .ductRunReview }
        statusMessage = "Draft discarded."
    }

    func beginEditSizes() {
        guard let draft = editingDraft else { return }
        sizeEditBuffer = draft.proposedSizeTags.joined(separator: ", ")
    }

    // MARK: - Coach chat

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
        statusMessage = "Local catalog still works. AI stays off until you allow sharing."
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
            Task { await performLocalDemoSizing(prompt: prompt) }
        } else {
            sendCoachChat()
        }
    }

    private func priorFeedbackLines() -> [String] {
        var lines: [String] = []
        for run in ductRuns.prefix(3) {
            lines.append("confirmed_run:\(run.sizeTags.joined(separator: "/"))")
        }
        for diagram in savedDiagrams.prefix(2) {
            lines.append("saved_diagram:\(diagram.id.uuidString.prefix(8))")
        }
        return lines
    }

    private func performCoachChat(prompt: String) async {
        chatBusy = true
        statusMessage = "Sizing airflow…"
        defer {
            chatBusy = false
            if statusMessage == "Sizing airflow…" { statusMessage = nil }
        }
        guard let key = apiKey() else {
            await performLocalDemoSizing(prompt: prompt)
            return
        }
        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let gate = consentGate
            let client = DeepSeekClient(apiKey: key, assertConsent: {
                _ = try gate.permit()
            })
            let runSummary = selectedRun.map {
                let length = $0.lengthFeet.map { String($0) } ?? "?"
                return "size=\($0.sizeTags.joined(separator: ",")); length=\(length) ft"
            } ?? "none"
            let response = try await client.coachSizing(
                prompt: prompt,
                targetCFM: cfmKnob,
                ductRunSummary: runSummary,
                priorFeedback: priorFeedbackLines()
            )
            let session = SizingSession(
                jobSiteID: selectedRun?.jobSiteID,
                ductRunID: selectedRunID,
                promptText: prompt,
                responseText: response.text,
                cfm: response.cfm ?? cfmKnob,
                friction: response.friction,
                velocity: response.velocity,
                citedFormulas: response.citedFormulas,
                includesSizingDisclaimer: true
            )
            sizingSessions.insert(session, at: 0)
            try? storage.sizingSessions.save(SizingSessionCatalog(sessions: sizingSessions))
            selectedSessionID = session.id
            chatText = ""
        } catch {
            statusMessage = "Coach failed: \(error.localizedDescription)"
            await performLocalDemoSizing(prompt: prompt)
        }
    }

    private func performLocalDemoSizing(prompt: String) async {
        let cfm = cfmKnob
        let areaSqFt = 10.0 * 8.0 / 144.0
        let velocity = cfm / max(areaSqFt, 0.01)
        let friction = 0.08
        let formulas = [
            "Q = V × A (CFM = FPM × ft²)",
            "Friction loss ≈ \(String(format: "%.2f", friction)) in.wg / 100 ft (rule-of-thumb demo)",
            AirspanIdentity.sizingFormulaDisclaimer
        ]
        let text = """
        Local demo sizing (AI outbound off or unavailable).
        Target \(Int(cfm)) CFM through 10×8 → velocity ≈ \(Int(velocity)) FPM.
        Friction demo \(friction) in.wg/100 ft.
        \(AirspanIdentity.sizingFormulaDisclaimer)
        You asked: \(prompt)
        """
        let session = SizingSession(
            jobSiteID: selectedRun?.jobSiteID,
            ductRunID: selectedRunID,
            promptText: prompt,
            responseText: text,
            cfm: cfm,
            friction: friction,
            velocity: velocity,
            citedFormulas: formulas,
            includesSizingDisclaimer: true
        )
        sizingSessions.insert(session, at: 0)
        try? storage.sizingSessions.save(SizingSessionCatalog(sessions: sizingSessions))
        selectedSessionID = session.id
        chatText = ""
        statusMessage = aiUnavailableReason ?? "Local demo sizing saved."
    }

    // MARK: - Size diagram

    func makeSizeDiagram() {
        let name = "diagram-\(UUID().uuidString).png"
        let url = storage.diagramsDirectory.appendingPathComponent(name)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 720, height: 540))
        let image = renderer.image { ctx in
            UIColor(red: 0.94, green: 0.98, blue: 1.0, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 720, height: 540))
            UIColor(red: 0.05, green: 0.45, blue: 0.56, alpha: 1).setStroke()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 120, y: 380))
            path.addLine(to: CGPoint(x: 300, y: 240))
            path.addLine(to: CGPoint(x: 480, y: 300))
            path.addLine(to: CGPoint(x: 600, y: 180))
            path.lineWidth = 14
            path.stroke()
            let chip = sizeChips.first ?? "10×8"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                .foregroundColor: UIColor(red: 0.96, green: 0.62, blue: 0.04, alpha: 1)
            ]
            NSString(string: chip).draw(at: CGPoint(x: 300, y: 420), withAttributes: attrs)
        }
        if let data = image.pngData() {
            try? data.write(to: url, options: .atomic)
        }
        let diagram = SizeDiagram(
            sizingSessionID: selectedSessionID,
            ductRunID: selectedRunID,
            localFileName: name,
            status: "draft"
        )
        pendingDiagram = diagram
        push(.sizeDiagram)
    }

    func savePendingDiagram() {
        guard var diagram = pendingDiagram else { return }
        diagram.status = "saved"
        diagram.savedAt = Date()
        sizeDiagrams.insert(diagram, at: 0)
        try? storage.sizeDiagrams.save(SizeDiagramCatalog(diagrams: sizeDiagrams))
        pendingDiagram = nil
        path.removeAll { $0 == .sizeDiagram }
        statusMessage = "Diagram saved."
        selectedTab = .diagrams
    }

    func discardPendingDiagram() {
        pendingDiagram = nil
        path.removeAll { $0 == .sizeDiagram }
        statusMessage = "Diagram discarded."
    }

    // MARK: - Field steps / TTS

    func openFieldSteps(for diagram: SizeDiagram? = nil, run: DuctRun? = nil) {
        let chip = (run ?? selectedRun)?.sizeTags.first ?? sizeChips.first ?? "10×8"
        let steps = [
            "Confirm \(chip) stock on truck.",
            "Cut \(chip) transition to match the run.",
            "Hang and seal joints; check for leaks.",
            "Verify airflow near \(Int(cfmKnob)) CFM target.",
            AirspanIdentity.sizingFormulaDisclaimer
        ]
        let plan = FieldStepPlan(
            ductRunID: run?.id ?? selectedRunID,
            sizeDiagramID: diagram?.id ?? pendingDiagram?.id,
            steps: steps,
            includesSizingDisclaimer: true
        )
        fieldStepPlans.insert(plan, at: 0)
        try? storage.fieldStepPlans.save(FieldStepPlanCatalog(plans: fieldStepPlans))
        activeFieldPlan = plan
        fieldStepIndex = 0
        push(.fieldSteps)
    }

    func playCurrentFieldStep() {
        guard let plan = activeFieldPlan else { return }
        do {
            try fieldTTS.speak(plan: plan, at: fieldStepIndex)
        } catch {
            statusMessage = "TTS unavailable: \(error.localizedDescription)"
        }
    }

    func pauseFieldSteps() {
        fieldTTS.stop()
    }

    func nextFieldStep() {
        guard let plan = activeFieldPlan else { return }
        if let next = fieldTTS.nextIndex(after: fieldStepIndex, stepCount: plan.steps.count) {
            fieldStepIndex = next
            playCurrentFieldStep()
        } else {
            statusMessage = "End of field steps."
        }
    }

    // MARK: - Speech → chat

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
