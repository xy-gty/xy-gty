import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import BendCoachDomain

@MainActor
final class AppModel: ObservableObject {
    enum AppTab: Hashable { case home, job, settings }

    @Published var jobs: [JobSession] = []
    @Published var queries: [BendQuery] = []
    @Published var photos: [FieldPhoto] = []
    @Published var drafts: [BendRecognitionDraft] = []
    @Published var markups: [BendMarkup] = []
    @Published var overlays: [DiagramOverlay] = []
    @Published var coachingSteps: [CoachingStep] = []
    @Published var unitPreference = UnitPreference()
    @Published var activeJobID: UUID?
    @Published var selectedTab: AppTab = .home
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var showUnitsIntro = false
    @Published var chatBusy = false
    @Published var recognitionBusy = false
    @Published var diagramBusy = false
    @Published var chatText = ""
    @Published var chatDraftResponse: String?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var editingDraft: BendRecognitionDraft?
    @Published var pendingOverlay: DiagramOverlay?
    @Published var pendingOverlayHints: String?
    @Published var coachingIndex = 0
    @Published var aiUnavailableReason: String?
    @Published var pendingAIAction: (() -> Void)?
    @Published var showCameraPicker = false
    @Published var speechHost = SpeechCaptureHost()
    @Published var rejectedBendTypes: [String] = []

    let storage: BendCoachStorageRoot
    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<BendCoachRoute>
    let coachingTTS = CoachingTTS()

    private var cachedAPIKey: String?
    private let keychain = BendCoachConsentFacade.makeAPIKeyStore()

    var cameraHardwareAvailable: Bool { CameraCaptureAvailability.cameraHardwareAvailable }

    var activeJob: JobSession? {
        guard let id = activeJobID else { return jobs.first }
        return jobs.first(where: { $0.id == id }) ?? jobs.first
    }

    var activePhotos: [FieldPhoto] {
        guard let id = activeJob?.id else { return [] }
        return photos.filter { $0.jobSessionID == id }.sorted { $0.importedAt < $1.importedAt }
    }

    var activeMarkups: [BendMarkup] {
        guard let id = activeJob?.id else { return [] }
        return markups.filter { $0.jobSessionID == id }
    }

    var activeQueries: [BendQuery] {
        guard let id = activeJob?.id else { return [] }
        return queries.filter { $0.jobSessionID == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var activeSteps: [CoachingStep] {
        guard let id = activeJob?.id else { return [] }
        return coachingSteps.filter { $0.jobSessionID == id }.sorted { $0.orderIndex < $1.orderIndex }
    }

    var unitBadge: String { UnitSystemControl.badge(for: unitPreference.unitSystem) }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("BendCoach", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        storage = BendCoachStorageRoot(rootDirectory: root)
        try? FileManager.default.createDirectory(at: storage.photosDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: storage.diagramsDirectory, withIntermediateDirectories: true)
        navigation = BendCoachNavigation.makeStore(directory: root)
        consentGate = BendCoachConsentFacade.makeGate(storage: storage)
        consentGranted = consentGate.state.granted
        reload()
        Task { await self.loadAPIKeyFromKeychain() }
        refreshAIAvailability()
        if !unitPreference.firstExplanationSeen {
            showUnitsIntro = true
        }
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
        jobs = (try? storage.jobSessions.load())?.sessions ?? []
        queries = (try? storage.bendQueries.load())?.queries ?? []
        photos = (try? storage.photos.load())?.photos ?? []
        drafts = (try? storage.recognitionDrafts.load())?.drafts ?? []
        markups = (try? storage.markups.load())?.markups ?? []
        overlays = (try? storage.diagramOverlays.load())?.overlays ?? []
        coachingSteps = (try? storage.coachingSteps.load())?.steps ?? []
        unitPreference = (try? UnitSystemControl.load(storage: storage)) ?? UnitPreference()
        consentGranted = consentGate.state.granted
        if activeJobID == nil { activeJobID = jobs.first?.id }
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI not configured — demo bend pack (local_only gap)."
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

    func outboundEnabled() -> Bool {
        BendCoachOutboundAIBoundary.snapshot(
            consentGranted: consentGate.state.granted,
            apiKeyPresent: apiKey() != nil
        ).outboundEnabled
    }

    func ensureJob(title: String = "Field bend job") -> JobSession {
        if let job = activeJob { return job }
        var job = JobSession(title: title, unitSystem: unitPreference.unitSystem)
        jobs.insert(job, at: 0)
        activeJobID = job.id
        persistJobs()
        return job
    }

    func startBendJob() {
        let job = ensureJob()
        activeJobID = job.id
        selectedTab = .job
        statusMessage = "Job ready. Ask bend math or capture a field photo."
    }

    func selectJob(_ id: UUID) {
        activeJobID = id
        selectedTab = .job
    }

    func dismissUnitsIntro() {
        do {
            unitPreference = try UnitSystemControl.markFirstExplanationSeen(storage: storage)
            showUnitsIntro = false
        } catch {
            showUnitsIntro = false
        }
    }

    func setUnitSystem(_ system: UnitSystem) {
        do {
            unitPreference = try UnitSystemControl.setUnitSystem(system, storage: storage)
            statusMessage = "Units set to \(UnitSystemControl.badge(for: system))."
        } catch {
            statusMessage = "Could not save units: \(error.localizedDescription)"
        }
    }

    func requestAI(_ action: @escaping () -> Void) {
        refreshAIAvailability()
        if apiKey() == nil {
            statusMessage = aiUnavailableReason
            action()
            return
        }
        if !consentGate.state.granted {
            pendingAIAction = action
            showConsent = true
            return
        }
        action()
    }

    func grantConsent() {
        do {
            try consentGate.grant()
            consentGranted = true
            showConsent = false
            refreshAIAvailability()
            let pending = pendingAIAction
            pendingAIAction = nil
            pending?()
        } catch {
            statusMessage = "Could not save consent: \(error.localizedDescription)"
        }
    }

    func denyConsent() {
        pendingAIAction = nil
        showConsent = false
        refreshAIAvailability()
        statusMessage = "AI sharing declined. Demo bend pack and local jobs remain available."
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "AI consent revoked. Outbound sends stopped."
        } catch {
            statusMessage = "Revoke failed: \(error.localizedDescription)"
        }
    }

    private func makeClient() throws -> DeepSeekClient {
        guard let key = apiKey() else { throw DeepSeekClientError.notConfigured }
        return DeepSeekClient(apiKey: key) { [weak self] in
            guard let self else { throw DeepSeekClientError.notAuthorized }
            let permit = try self.consentGate.permit()
            try self.consentGate.validate(permit)
        }
    }

    // MARK: Chat

    func sendChat() {
        requestAI { [weak self] in
            Task { await self?.sendChatNow() }
        }
    }

    private func sendChatNow() async {
        let job = ensureJob()
        let text = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            statusMessage = "Enter a bend-math question."
            return
        }
        chatBusy = true
        defer { chatBusy = false }
        let feedback = rejectedBendTypes
        if !outboundEnabled() {
            let demo = demoBendResponse(for: text, unit: unitPreference.unitSystem)
            var query = BendQuery(
                jobSessionID: job.id,
                promptText: text,
                responseText: demo,
                unitSystem: unitPreference.unitSystem
            )
            queries.append(query)
            attachQuery(query.id, to: job.id)
            persistQueries()
            chatDraftResponse = demo
            chatText = ""
            statusMessage = aiUnavailableReason ?? "Demo bend pack answer ready."
            return
        }
        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let client = try makeClient()
            let reply = try await client.bendMathChat(
                prompt: text,
                unitSystem: unitPreference.unitSystem,
                priorMarkups: activeMarkups,
                priorFeedback: feedback
            )
            try consentGate.validate(permit)
            var query = BendQuery(
                jobSessionID: job.id,
                promptText: text,
                responseText: reply + "\n\n" + BendCoachIdentity.assistiveDisclaimer,
                unitSystem: unitPreference.unitSystem
            )
            queries.append(query)
            attachQuery(query.id, to: job.id)
            persistQueries()
            chatDraftResponse = query.responseText
            chatText = ""
            statusMessage = "Coach reply saved to job history."
        } catch {
            statusMessage = "Chat failed: \(error.localizedDescription). Input kept."
        }
    }

    private func demoBendResponse(for prompt: String, unit: UnitSystem) -> String {
        let rise = unit == .imperial ? "12 in" : "300 mm"
        let takeUp = unit == .imperial ? "6 5/16 in" : "160 mm"
        return """
        Demo bend pack (AI not configured)
        Question: \(prompt)
        Example 90° stub-up on 3/4 EMT, rise \(rise):
        • Mark take-up ≈ \(takeUp) (assistive)
        • Measure stub, mark bend start, bend to 90°
        \(BendCoachIdentity.assistiveDisclaimer)
        """
    }

    func startMic() {
        let jobID = ensureJob().id
        Task {
            await speechHost.start(jobSessionID: jobID)
            if let err = speechHost.lastError, speechHost.partialTranscript.isEmpty {
                statusMessage = err
            } else {
                statusMessage = "Listening for bend-math question…"
            }
        }
    }

    func stopMicIntoChat() {
        speechHost.stop()
        var text = speechHost.consumeForChat()
        if text.isEmpty {
            text = "90° stub-up on 3/4 EMT, 12 inch rise"
            statusMessage = "No speech heard — editable demo transcript ready."
        } else {
            statusMessage = "Transcript filled. Edit before send."
        }
        chatText = text
    }

    // MARK: Photos

    func importPhoto() async {
        let job = ensureJob()
        recognitionBusy = true
        defer { recognitionBusy = false }
        do {
            let fileName = "\(UUID().uuidString).jpg"
            let pair = BendCoachPhotoImportFacade.makeSession(storage: storage, fileName: fileName)
            let result = try await pair.session.importSelection {
                guard let item = selectedPhotoItem else { return nil }
                return try await item.loadTransferable(type: Data.self)
            }
            switch result {
            case .imported(let url):
                let photo = try BendCoachPhotoImportFacade.recordImportedPhoto(
                    storage: storage,
                    jobSessionID: job.id,
                    destination: url,
                    sourceKind: BendCoachPhotoImportFacade.librarySourceKind
                )
                photos.append(photo)
                attachPhoto(photo.id, to: job.id)
                selectedPhotoItem = nil
                statusMessage = "Photo imported."
                runRecognition(for: photo)
            case .cancelled:
                statusMessage = "Import cancelled."
            case .superseded:
                statusMessage = "Late import superseded."
            }
        } catch {
            statusMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    func beginTakePhoto() {
        _ = ensureJob()
        if cameraHardwareAvailable {
            showCameraPicker = true
        } else {
            Task { await importSyntheticCameraCapture() }
        }
    }

    func cancelCameraPicker() {
        showCameraPicker = false
        statusMessage = "Camera capture cancelled."
    }

    func handleCameraImageData(_ data: Data) async {
        showCameraPicker = false
        await persistCameraJPEG(data, sourceKind: BendCoachPhotoImportFacade.cameraSourceKind)
    }

    func importSyntheticCameraCapture() async {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 720, height: 960))
        let image = renderer.image { ctx in
            UIColor(red: 0.10, green: 0.14, blue: 0.20, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 720, height: 960))
            let title = "BendCoach AI\nSimulator field capture"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor(red: 0.91, green: 0.64, blue: 0.09, alpha: 1)
            ]
            title.draw(in: CGRect(x: 40, y: 360, width: 640, height: 160), withAttributes: attrs)
        }
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            statusMessage = "Simulator camera stub failed."
            return
        }
        await persistCameraJPEG(data, sourceKind: "camera_simulator")
        statusMessage = "Simulator: synthetic camera capture saved (device camera 真机待测)."
    }

    private func persistCameraJPEG(_ data: Data, sourceKind: String) async {
        let job = ensureJob()
        recognitionBusy = true
        defer { recognitionBusy = false }
        do {
            let fileName = "\(UUID().uuidString).jpg"
            let dest = storage.photosDirectory.appendingPathComponent(fileName)
            try data.write(to: dest, options: .atomic)
            let photo = FieldPhoto(jobSessionID: job.id, localFileName: fileName, sourceKind: sourceKind)
            photos.append(photo)
            try storage.photos.save(FieldPhotoCatalog(photos: photos))
            attachPhoto(photo.id, to: job.id)
            runRecognition(for: photo)
        } catch {
            statusMessage = "Camera save failed: \(error.localizedDescription)"
        }
    }

    func runRecognition(for photo: FieldPhoto? = nil) {
        requestAI { [weak self] in
            Task { await self?.recognizeNow(photo: photo) }
        }
    }

    private func recognizeNow(photo: FieldPhoto?) async {
        let job = ensureJob()
        guard let photo = photo ?? activePhotos.last else {
            statusMessage = "Add a photo before recognizing."
            return
        }
        recognitionBusy = true
        defer { recognitionBusy = false }
        if !outboundEnabled() {
            let draft = BendRecognitionDraft(
                jobSessionID: job.id,
                fieldPhotoID: photo.id,
                proposedBendType: rejectedBendTypes.contains("offset") ? "stub90" : "offset",
                markupHints: [
                    "Mark take-up (assistive demo)",
                    unitPreference.unitSystem == .imperial ? "Rise 12 in" : "Rise 300 mm"
                ]
            )
            upsertDraft(draft)
            editingDraft = draft
            statusMessage = aiUnavailableReason ?? "Local recognition draft ready."
            return
        }
        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let client = try makeClient()
            let draft = try await client.recognizeBend(
                photoURL: storage.photoFileURL(for: photo),
                jobSessionID: job.id,
                photoID: photo.id,
                unitSystem: unitPreference.unitSystem
            )
            try consentGate.validate(permit)
            upsertDraft(draft)
            editingDraft = draft
            statusMessage = "Recognition draft ready. Review before saving."
        } catch {
            statusMessage = "Recognition failed: \(error.localizedDescription). Photo kept."
        }
    }

    func saveRecognitionDraft() {
        guard var draft = editingDraft else { return }
        let markup = BendMarkup(
            jobSessionID: draft.jobSessionID,
            fieldPhotoID: draft.fieldPhotoID,
            bendType: draft.proposedBendType,
            keyDimensions: Dictionary(uniqueKeysWithValues: draft.markupHints.enumerated().map { ("hint_\($0.offset)", $0.element) }),
            unitSystem: unitPreference.unitSystem
        )
        markups.append(markup)
        if let idx = jobs.firstIndex(where: { $0.id == draft.jobSessionID }) {
            jobs[idx].bendMarkupIDs.append(markup.id)
            jobs[idx].updatedAt = Date()
            persistJobs()
        }
        persistMarkups()
        drafts.removeAll { $0.id == draft.id }
        persistDrafts()
        editingDraft = nil
        statusMessage = "Marks saved."
    }

    func rejectRecognitionDraft() {
        if let draft = editingDraft {
            rejectedBendTypes.append(draft.proposedBendType)
            drafts.removeAll { $0.id == draft.id }
            persistDrafts()
        }
        editingDraft = nil
        statusMessage = "Draft discarded (Not this)."
    }

    func updateDraftBendType(_ type: String) {
        guard var draft = editingDraft else { return }
        draft.proposedBendType = type
        editingDraft = draft
    }

    func updateDraftHint(at index: Int, text: String) {
        guard var draft = editingDraft, draft.markupHints.indices.contains(index) else { return }
        draft.markupHints[index] = text
        editingDraft = draft
    }

    // MARK: Diagram

    func generateDiagram() {
        requestAI { [weak self] in
            Task { await self?.generateDiagramNow() }
        }
    }

    private func generateDiagramNow() async {
        let job = ensureJob()
        guard let markup = activeMarkups.last else {
            statusMessage = "Save bend marks before generating a diagram."
            return
        }
        diagramBusy = true
        defer { diagramBusy = false }
        var hints: String
        if outboundEnabled() {
            do {
                let permit = try consentGate.permit()
                try consentGate.validate(permit)
                let client = try makeClient()
                hints = try await client.diagramHints(markup: markup)
                try consentGate.validate(permit)
            } catch {
                statusMessage = "Diagram AI failed: \(error.localizedDescription)"
                return
            }
        } else {
            hints = """
            Local diagram template (AI not configured)
            Bend: \(markup.bendType)
            Take-up / shrink marks are assistive only.
            \(BendCoachIdentity.assistiveDisclaimer)
            """
        }
        let fileName = "\(UUID().uuidString).txt"
        let url = storage.diagramsDirectory.appendingPathComponent(fileName)
        try? hints.write(to: url, atomically: true, encoding: .utf8)
        let overlay = DiagramOverlay(
            jobSessionID: job.id,
            bendMarkupID: markup.id,
            localFileName: fileName,
            status: "draft"
        )
        pendingOverlay = overlay
        pendingOverlayHints = hints
        statusMessage = "Diagram draft ready. Use or Discard."
    }

    func useDiagram() {
        guard var overlay = pendingOverlay else { return }
        overlay.status = "confirmed"
        overlays.append(overlay)
        if let idx = jobs.firstIndex(where: { $0.id == overlay.jobSessionID }) {
            jobs[idx].diagramOverlayIDs.append(overlay.id)
            jobs[idx].updatedAt = Date()
            persistJobs()
        }
        persistOverlays()
        pendingOverlay = nil
        pendingOverlayHints = nil
        statusMessage = "Diagram saved."
    }

    func discardDiagram() {
        pendingOverlay = nil
        pendingOverlayHints = nil
        statusMessage = "Diagram discarded."
    }

    // MARK: Coaching

    func prepareCoaching() {
        requestAI { [weak self] in
            Task { await self?.prepareCoachingNow() }
        }
    }

    private func prepareCoachingNow() async {
        let job = ensureJob()
        let markup = activeMarkups.last
        let context = activeQueries.last?.promptText ?? markup?.bendType ?? "general bend"
        diagramBusy = true
        defer { diagramBusy = false }
        var steps: [CoachingStep]
        if outboundEnabled() {
            do {
                let permit = try consentGate.permit()
                try consentGate.validate(permit)
                let client = try makeClient()
                steps = try await client.coachingSteps(jobSessionID: job.id, markup: markup, context: context)
                try consentGate.validate(permit)
            } catch {
                statusMessage = "Coaching AI failed: \(error.localizedDescription)"
                return
            }
        } else {
            steps = [
                CoachingStep(jobSessionID: job.id, orderIndex: 0, utterance: "Measure the rise and mark the stub length. \(BendCoachIdentity.assistiveDisclaimer)"),
                CoachingStep(jobSessionID: job.id, orderIndex: 1, utterance: "Mark take-up from the bender shoe chart — assistive demo value only."),
                CoachingStep(jobSessionID: job.id, orderIndex: 2, utterance: "Align the mark, bend smoothly to ninety degrees, then check plumb.")
            ]
        }
        coachingSteps.removeAll { $0.jobSessionID == job.id }
        coachingSteps.append(contentsOf: steps)
        if let idx = jobs.firstIndex(where: { $0.id == job.id }) {
            jobs[idx].coachingStepIDs = steps.map(\.id)
            jobs[idx].updatedAt = Date()
            persistJobs()
        }
        persistSteps()
        coachingIndex = 0
        statusMessage = "Coaching steps ready."
    }

    func playCurrentStep() {
        let steps = activeSteps
        guard steps.indices.contains(coachingIndex) else {
            statusMessage = "No coaching steps. Tap Start coaching first."
            return
        }
        do {
            try coachingTTS.speakOrderedSteps(steps, at: coachingIndex)
            statusMessage = "Playing step \(coachingIndex + 1)."
        } catch {
            statusMessage = "TTS failed: \(error.localizedDescription)"
        }
    }

    func pauseCoaching() {
        coachingTTS.stop()
        statusMessage = "Coaching paused."
    }

    func nextCoachingStep() {
        if let next = coachingTTS.nextIndex(after: coachingIndex, stepCount: activeSteps.count) {
            coachingIndex = next
            playCurrentStep()
        } else {
            statusMessage = "End of coaching steps."
        }
    }

    // MARK: Persist helpers

    private func upsertDraft(_ draft: BendRecognitionDraft) {
        if let idx = drafts.firstIndex(where: { $0.id == draft.id }) {
            drafts[idx] = draft
        } else {
            drafts.append(draft)
        }
        persistDrafts()
    }

    private func attachQuery(_ id: UUID, to jobID: UUID) {
        if let idx = jobs.firstIndex(where: { $0.id == jobID }) {
            jobs[idx].bendQueryIDs.append(id)
            jobs[idx].updatedAt = Date()
            persistJobs()
        }
    }

    private func attachPhoto(_ id: UUID, to jobID: UUID) {
        if let idx = jobs.firstIndex(where: { $0.id == jobID }) {
            jobs[idx].fieldPhotoIDs.append(id)
            jobs[idx].updatedAt = Date()
            persistJobs()
        }
    }

    private func persistJobs() { try? storage.jobSessions.save(JobSessionCatalog(sessions: jobs)) }
    private func persistQueries() { try? storage.bendQueries.save(BendQueryCatalog(queries: queries)) }
    private func persistDrafts() { try? storage.recognitionDrafts.save(BendRecognitionDraftCatalog(drafts: drafts)) }
    private func persistMarkups() { try? storage.markups.save(BendMarkupCatalog(markups: markups)) }
    private func persistOverlays() { try? storage.diagramOverlays.save(DiagramOverlayCatalog(overlays: overlays)) }
    private func persistSteps() { try? storage.coachingSteps.save(CoachingStepCatalog(steps: coachingSteps)) }
}
