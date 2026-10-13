import Foundation
import SwiftUI
import PhotosUI
import AppRuntimeCore
import DocBriefDomain

@MainActor
final class AppModel: ObservableObject {
    enum AppTab: Hashable {
        case briefs, active, settings
    }

    @Published var briefs: [Brief] = []
    @Published var photos: [DocumentPhoto] = []
    @Published var fields: [ExtractedField] = []
    @Published var recognitionDrafts: [RecognitionDraft] = []
    @Published var actionItems: [ActionItem] = []
    @Published var summaryCards: [SummaryCardDraft] = []
    @Published var activeBriefID: UUID?
    @Published var selectedTab: AppTab = .briefs
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var recognitionBusy = false
    @Published var chatBusy = false
    @Published var summaryBusy = false
    @Published var chatText = ""
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var newBriefTitle = ""
    @Published var editingDraft: RecognitionDraft?
    @Published var pendingActionDraft: ActionItem?
    @Published var pendingSummary: SummaryCardDraft?
    @Published var briefingSession: BriefingSession?
    @Published var aiUnavailableReason: String?
    @Published var pendingAIAction: (() -> Void)?

    let storage: DocBriefStorageRoot
    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<DocBriefRoute>
    let briefingTTS = BriefingTTS()

    private var cachedAPIKey: String?
    private let keychain = DocBriefConsentFacade.makeAPIKeyStore()

    var activeBrief: Brief? {
        guard let id = activeBriefID else { return briefs.first }
        return briefs.first(where: { $0.id == id }) ?? briefs.first
    }

    var activePhotos: [DocumentPhoto] {
        guard let id = activeBrief?.id else { return [] }
        return photos.filter { $0.briefID == id }.sorted { $0.importedAt < $1.importedAt }
    }

    var activeFields: [ExtractedField] {
        guard let id = activeBrief?.id else { return [] }
        return fields.filter { $0.briefID == id && $0.confirmed }
    }

    var activeActions: [ActionItem] {
        guard let id = activeBrief?.id else { return [] }
        return actionItems.filter { $0.briefID == id && $0.confirmed }
    }

    var activeDraft: RecognitionDraft? {
        guard let id = activeBrief?.id else { return nil }
        return recognitionDrafts.first(where: { $0.briefID == id }) ?? editingDraft
    }

    var activeSummary: SummaryCardDraft? {
        guard let brief = activeBrief, let sid = brief.summaryCardDraftID else {
            return pendingSummary
        }
        return summaryCards.first(where: { $0.id == sid }) ?? pendingSummary
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("DocBrief", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        storage = DocBriefStorageRoot(rootDirectory: root)
        try? FileManager.default.createDirectory(at: storage.photosDirectory, withIntermediateDirectories: true)
        navigation = DocBriefNavigation.makeStore(directory: root)
        consentGate = DocBriefConsentFacade.makeGate(storage: storage)
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
        briefs = (try? storage.briefs.load())?.briefs ?? []
        photos = (try? storage.photos.load())?.photos ?? []
        fields = (try? storage.fields.load())?.fields ?? []
        recognitionDrafts = (try? storage.recognitionDrafts.load())?.drafts ?? []
        actionItems = (try? storage.actionItems.load())?.items ?? []
        summaryCards = (try? storage.summaryCards.load())?.drafts ?? []
        consentGranted = consentGate.state.granted
        if activeBriefID == nil {
            activeBriefID = briefs.first?.id
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

    func outboundEnabled() -> Bool {
        DocBriefOutboundAIBoundary.snapshot(
            consentGranted: consentGate.state.granted,
            apiKeyPresent: apiKey() != nil
        ).outboundEnabled
    }

    func createBrief() {
        let title = newBriefTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            statusMessage = "Enter a brief title."
            return
        }
        var brief = Brief(title: title)
        briefs.insert(brief, at: 0)
        activeBriefID = brief.id
        persistBriefs()
        newBriefTitle = ""
        statusMessage = "Brief created. Add photos."
        selectedTab = .active
    }

    func selectBrief(_ id: UUID) {
        activeBriefID = id
        selectedTab = .active
    }

    func importPhoto() async {
        guard let brief = activeBrief else {
            statusMessage = "Create a brief first."
            return
        }
        recognitionBusy = true
        defer { recognitionBusy = false }
        do {
            let fileName = "\(UUID().uuidString).jpg"
            let pair = DocBriefPhotoImportFacade.makeSession(storage: storage, fileName: fileName)
            let result = try await pair.session.importSelection {
                guard let item = selectedPhotoItem else { return nil }
                return try await item.loadTransferable(type: Data.self)
            }
            switch result {
            case .imported(let url):
                let photo = try DocBriefPhotoImportFacade.recordImportedPhoto(
                    storage: storage,
                    briefID: brief.id,
                    destination: url
                )
                photos.append(photo)
                if let idx = briefs.firstIndex(where: { $0.id == brief.id }) {
                    briefs[idx].documentPhotoIDs.append(photo.id)
                    briefs[idx].updatedAt = Date()
                    persistBriefs()
                }
                statusMessage = "Photo imported."
                selectedPhotoItem = nil
            case .cancelled:
                statusMessage = "Import cancelled."
            case .superseded:
                statusMessage = "Late import superseded."
            }
        } catch {
            statusMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    func requestAI(_ action: @escaping () -> Void) {
        refreshAIAvailability()
        if apiKey() == nil {
            statusMessage = aiUnavailableReason
            action() // still allow local fallback paths that check outboundEnabled
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
        statusMessage = "AI sharing declined. Local import, manual fields, and TTS remain available."
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

    func runRecognition() {
        requestAI { [weak self] in
            Task { await self?.recognizeNow() }
        }
    }

    private func recognizeNow() async {
        guard let brief = activeBrief, let photo = activePhotos.last else {
            statusMessage = "Add a photo before recognizing."
            return
        }
        recognitionBusy = true
        defer { recognitionBusy = false }

        if !outboundEnabled() {
            let draft = RecognitionDraft(
                briefID: brief.id,
                documentPhotoID: photo.id,
                proposedType: heuristicType(for: brief.title),
                proposedFields: [
                    ExtractedField(briefID: brief.id, key: "title_hint", value: brief.title),
                    ExtractedField(briefID: brief.id, key: "note", value: "Local heuristic — AI unavailable")
                ]
            )
            upsertDraft(draft)
            editingDraft = draft
            statusMessage = aiUnavailableReason ?? "AI unavailable; local draft ready for review."
            return
        }

        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let client = try makeClient()
            let photoURL = storage.photoFileURL(for: photo)
            let draft = try await client.recognizeDocument(
                photoURL: photoURL,
                briefID: brief.id,
                photoID: photo.id,
                priorType: brief.recognizedType
            )
            try consentGate.validate(permit)
            upsertDraft(draft)
            editingDraft = draft
            statusMessage = "Recognition draft ready. Review before saving."
        } catch {
            statusMessage = "Recognition failed: \(error.localizedDescription). Photo kept."
        }
    }

    private func heuristicType(for title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("receipt") || lower.contains("发票") { return "receipt" }
        if lower.contains("board") || lower.contains("白板") { return "whiteboard" }
        return "document"
    }

    func saveRecognitionDraft() {
        guard var draft = editingDraft ?? activeDraft else { return }
        guard let briefIdx = briefs.firstIndex(where: { $0.id == draft.briefID }) else { return }
        briefs[briefIdx].recognizedType = draft.proposedType
        briefs[briefIdx].updatedAt = Date()
        var confirmed: [ExtractedField] = []
        for var field in draft.proposedFields {
            field.confirmed = true
            confirmed.append(field)
            if let existing = fields.firstIndex(where: { $0.id == field.id }) {
                fields[existing] = field
            } else {
                fields.append(field)
            }
            if !briefs[briefIdx].extractedFieldIDs.contains(field.id) {
                briefs[briefIdx].extractedFieldIDs.append(field.id)
            }
        }
        persistFields()
        persistBriefs()
        recognitionDrafts.removeAll { $0.id == draft.id }
        persistDrafts()
        editingDraft = nil
        statusMessage = "Fields saved."
    }

    func rejectRecognitionDraft() {
        guard let draft = editingDraft ?? activeDraft else { return }
        recognitionDrafts.removeAll { $0.id == draft.id }
        persistDrafts()
        editingDraft = nil
        statusMessage = "Draft discarded."
    }

    func updateEditingField(id: UUID, key: String, value: String) {
        guard var draft = editingDraft else { return }
        if let idx = draft.proposedFields.firstIndex(where: { $0.id == id }) {
            draft.proposedFields[idx].key = key
            draft.proposedFields[idx].value = value
            editingDraft = draft
        }
    }

    func addManualField(key: String, value: String) {
        guard let brief = activeBrief else { return }
        let field = ExtractedField(briefID: brief.id, key: key, value: value, confirmed: true)
        fields.append(field)
        if let idx = briefs.firstIndex(where: { $0.id == brief.id }) {
            briefs[idx].extractedFieldIDs.append(field.id)
            briefs[idx].updatedAt = Date()
            persistBriefs()
        }
        persistFields()
        statusMessage = "Field added."
    }

    func runChatExtract() {
        requestAI { [weak self] in
            Task { await self?.chatExtractNow() }
        }
    }

    private func chatExtractNow() async {
        guard let brief = activeBrief else { return }
        let text = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            statusMessage = "Enter a chat message."
            return
        }
        chatBusy = true
        defer { chatBusy = false }

        let priorFeedback = activeActions.flatMap(\.feedbackNotes)
        if !outboundEnabled() {
            let item = ActionItem(
                briefID: brief.id,
                text: "Follow up: \(text)",
                deadline: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                confirmed: false,
                source: "local_heuristic",
                feedbackNotes: []
            )
            pendingActionDraft = item
            statusMessage = aiUnavailableReason ?? "AI unavailable; local action draft ready."
            return
        }

        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let client = try makeClient()
            let item = try await client.extractActions(
                chatText: text,
                fields: activeFields,
                priorActions: activeActions,
                priorFeedback: priorFeedback,
                recognizedType: brief.recognizedType,
                briefID: brief.id
            )
            try consentGate.validate(permit)
            pendingActionDraft = item
            statusMessage = "Action draft ready. Save or reject."
        } catch {
            statusMessage = "Chat extract failed: \(error.localizedDescription)"
        }
    }

    func saveActionDraft(feedback: String? = nil) {
        guard var item = pendingActionDraft, let brief = activeBrief else { return }
        item.confirmed = true
        if let feedback, !feedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            item.feedbackNotes.append(feedback.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        actionItems.append(item)
        if let idx = briefs.firstIndex(where: { $0.id == brief.id }) {
            briefs[idx].actionItemIDs.append(item.id)
            briefs[idx].updatedAt = Date()
            persistBriefs()
        }
        persistActions()
        pendingActionDraft = nil
        chatText = ""
        statusMessage = "Action saved."
    }

    func rejectActionDraft(feedback: String? = nil) {
        if var item = pendingActionDraft, let feedback,
           !feedback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Keep feedback on a discarded draft only in memory for next call context via status
            statusMessage = "Draft rejected. Feedback noted for next extract: \(feedback)"
            // Attach feedback to last confirmed action if present so second call reuses it
            if let lastIdx = actionItems.lastIndex(where: { $0.briefID == item.briefID && $0.confirmed }) {
                actionItems[lastIdx].feedbackNotes.append(feedback.trimmingCharacters(in: .whitespacesAndNewlines))
                persistActions()
            }
        } else {
            statusMessage = "Action draft discarded."
        }
        pendingActionDraft = nil
    }

    func runSummaryCard() {
        requestAI { [weak self] in
            Task { await self?.summaryNow() }
        }
    }

    private func summaryNow() async {
        guard let brief = activeBrief else { return }
        summaryBusy = true
        defer { summaryBusy = false }

        if !outboundEnabled() {
            statusMessage = aiUnavailableReason ?? "Summary card needs configured AI key."
            pendingSummary = nil
            return
        }

        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let client = try makeClient()
            let draft = try await client.makeSummaryCard(
                brief: brief,
                fields: activeFields,
                actions: activeActions
            )
            try consentGate.validate(permit)
            pendingSummary = draft
            statusMessage = "Summary card preview ready."
        } catch {
            statusMessage = "Summary failed: \(error.localizedDescription)"
        }
    }

    func useSummaryCard() {
        guard var draft = pendingSummary, let brief = activeBrief else { return }
        draft.includesDisclaimer = true
        if !draft.body.contains("not financial") {
            draft.body += "\n\n\(DocBriefIdentity.nonCertificationDisclaimer)"
        }
        summaryCards.append(draft)
        if let idx = briefs.firstIndex(where: { $0.id == brief.id }) {
            briefs[idx].summaryCardDraftID = draft.id
            briefs[idx].updatedAt = Date()
            persistBriefs()
        }
        persistSummaries()
        pendingSummary = draft
        statusMessage = "Summary card saved."
    }

    func discardSummaryCard() {
        pendingSummary = nil
        statusMessage = "Summary card discarded."
    }

    func startBriefing() {
        guard let brief = activeBrief else { return }
        var lines: [String] = []
        lines.append("Brief: \(brief.title).")
        if let type = brief.recognizedType {
            lines.append("Recognized type: \(type).")
        }
        for field in activeFields {
            lines.append("Field \(field.key): \(field.value).")
        }
        for action in activeActions {
            var line = "Action: \(action.text)."
            if let deadline = action.deadline {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                line += " Due \(formatter.string(from: deadline))."
            }
            lines.append(line)
        }
        if lines.count == 1 {
            lines.append("No confirmed fields or actions yet.")
        }
        lines.append(DocBriefIdentity.nonCertificationDisclaimer)
        briefingSession = BriefingSession(briefID: brief.id, utterableLines: lines)
        statusMessage = "Briefing ready."
    }

    func playBriefingStep() {
        if briefingSession == nil {
            startBriefing()
        }
        guard let session = briefingSession else { return }
        do {
            try briefingTTS.speakCurrentStep(of: session)
            briefingSession = session
        } catch {
            statusMessage = "TTS failed: \(error.localizedDescription)"
        }
    }

    func nextBriefingStep() {
        guard var session = briefingSession else { return }
        briefingTTS.stop()
        if briefingTTS.advance(&session) {
            briefingSession = session
            playBriefingStep()
        } else {
            statusMessage = "End of briefing."
        }
    }

    func pauseBriefing() {
        briefingTTS.stop()
        statusMessage = "Briefing paused."
    }

    private func makeClient() throws -> DeepSeekClient {
        guard let key = apiKey() else { throw DeepSeekClientError.notConfigured }
        return DeepSeekClient(apiKey: key) { [weak self] in
            guard let self else { throw DeepSeekClientError.notAuthorized }
            let permit = try self.consentGate.permit()
            try self.consentGate.validate(permit)
        }
    }

    private func upsertDraft(_ draft: RecognitionDraft) {
        if let idx = recognitionDrafts.firstIndex(where: { $0.id == draft.id }) {
            recognitionDrafts[idx] = draft
        } else {
            recognitionDrafts.removeAll { $0.briefID == draft.briefID }
            recognitionDrafts.append(draft)
        }
        persistDrafts()
    }

    private func persistBriefs() {
        try? storage.briefs.save(BriefCatalog(briefs: briefs))
    }
    private func persistFields() {
        try? storage.fields.save(ExtractedFieldCatalog(fields: fields))
    }
    private func persistDrafts() {
        try? storage.recognitionDrafts.save(RecognitionDraftCatalog(drafts: recognitionDrafts))
    }
    private func persistActions() {
        try? storage.actionItems.save(ActionItemCatalog(items: actionItems))
    }
    private func persistSummaries() {
        try? storage.summaryCards.save(SummaryCardDraftCatalog(drafts: summaryCards))
    }

    func photoURL(for photo: DocumentPhoto) -> URL {
        storage.photoFileURL(for: photo)
    }
}
