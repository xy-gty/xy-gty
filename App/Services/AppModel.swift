import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import SnagCueDomain

@MainActor
final class AppModel: ObservableObject {
    enum AppTab: Hashable {
        case audits, active, settings
    }

    @Published var audits: [Audit] = []
    @Published var photos: [WalkthroughPhoto] = []
    @Published var snagDrafts: [SnagDraft] = []
    @Published var punchItems: [PunchItem] = []
    @Published var reportDrafts: [ReportDraft] = []
    @Published var fieldPatch: FieldPatchDraft?
    @Published var coach: CoachSession?
    @Published var activeAuditId: String?
    @Published var selectedTab: AppTab = .audits
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var recognitionBusy = false
    @Published var chatBusy = false
    @Published var reportBusy = false
    @Published var chatText = ""
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var newAuditTitle = ""
    @Published var newAuditSite = ""
    @Published var editingDraft: SnagDraft?
    @Published var pendingAIAction: (() -> Void)?
    @Published var aiUnavailableReason: String?
    @Published var lastReportPreviewPath: String?

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<SnagCueRoute>

    private let auditsStore: AtomicCodableStore<[Audit]>
    private let photosStore: AtomicCodableStore<[WalkthroughPhoto]>
    private let draftsStore: AtomicCodableStore<[SnagDraft]>
    private let punchStore: AtomicCodableStore<[PunchItem]>
    private let reportsStore: AtomicCodableStore<[ReportDraft]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let reportsRoot: URL
    private let keychain = KeychainCredentialStore(
        service: SnagCueStores.keychainService,
        account: SnagCueStores.keychainAPIKeyAccount
    )
    private var cachedAPIKey: String?
    private var pendingReportDraft: ReportDraft?

    var activeAudit: Audit? {
        guard let id = activeAuditId else { return audits.first }
        return audits.first(where: { $0.id == id }) ?? audits.first
    }

    var activePhotos: [WalkthroughPhoto] {
        guard let id = activeAudit?.id else { return [] }
        return photos.filter { $0.auditId == id }.sorted { $0.sequence < $1.sequence }
    }

    var activeDrafts: [SnagDraft] {
        guard let id = activeAudit?.id else { return [] }
        return snagDrafts.filter { $0.auditId == id }
    }

    var activePunchItems: [PunchItem] {
        guard let id = activeAudit?.id else { return [] }
        return punchItems.filter { $0.auditId == id }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("SnagCue", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        reportsRoot = root.appendingPathComponent("reports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: reportsRoot, withIntermediateDirectories: true)

        auditsStore = AtomicCodableStore(url: root.appendingPathComponent("\(SnagCueStores.audits).json"))
        photosStore = AtomicCodableStore(url: root.appendingPathComponent("\(SnagCueStores.walkthroughPhotos).json"))
        draftsStore = AtomicCodableStore(url: root.appendingPathComponent("\(SnagCueStores.snagDrafts).json"))
        punchStore = AtomicCodableStore(url: root.appendingPathComponent("\(SnagCueStores.punchItems).json"))
        reportsStore = AtomicCodableStore(url: root.appendingPathComponent("\(SnagCueStores.reportDrafts).json"))
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = root.appendingPathComponent("\(SnagCueStores.aiConsentLocal).json")
        consentGate = AIConsentGate(
            provider: AIConsentContract.provider,
            disclosureVersion: AIConsentContract.disclosureVersion,
            load: {
                guard FileManager.default.fileExists(atPath: consentURL.path) else { return nil }
                return try JSONDecoder().decode(AIConsentGate.State.self, from: Data(contentsOf: consentURL))
            },
            persist: { state in
                let data = try JSONEncoder().encode(state)
                try data.write(to: consentURL, options: .atomic)
            }
        )
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
        audits = (try? auditsStore.load()) ?? []
        photos = (try? photosStore.load()) ?? []
        snagDrafts = (try? draftsStore.load()) ?? []
        punchItems = (try? punchStore.load()) ?? []
        reportDrafts = (try? reportsStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeAuditId == nil {
            activeAuditId = audits.first?.id
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

    func createAudit() {
        let title = newAuditTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            statusMessage = "Enter an audit title."
            return
        }
        let audit = Audit(
            id: UUID().uuidString,
            title: title,
            siteLabel: newAuditSite.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        audits.insert(audit, at: 0)
        activeAuditId = audit.id
        persistAudits()
        newAuditTitle = ""
        newAuditSite = ""
        statusMessage = "Audit created. Add walkthrough photos."
    }

    func selectAudit(_ id: String) {
        activeAuditId = id
        selectedTab = .active
    }

    func importPhoto() async {
        guard let audit = activeAudit else {
            statusMessage = "Create an audit first."
            return
        }
        recognitionBusy = true
        defer { recognitionBusy = false }
        do {
            let dest = importsRoot.appendingPathComponent("\(UUID().uuidString).jpg")
            let session = PhotoImportSession(destination: dest)
            let result = try await session.importSelection {
                guard let item = selectedPhotoItem else { return nil }
                return try await item.loadTransferable(type: Data.self)
            }
            switch result {
            case .imported(let url):
                let relative = url.lastPathComponent
                let photo = WalkthroughPhoto(
                    id: UUID().uuidString,
                    auditId: audit.id,
                    relativePath: relative,
                    sequence: activePhotos.count + 1
                )
                photos.append(photo)
                persistPhotos()
                statusMessage = "Photo imported. Detect snags or add manually."
            case .cancelled:
                statusMessage = "Import cancelled."
            case .superseded:
                statusMessage = "Import superseded."
            }
        } catch {
            statusMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    func photoURL(for photo: WalkthroughPhoto) -> URL {
        importsRoot.appendingPathComponent(photo.relativePath)
    }

    func requestAI(action: @escaping () -> Void) {
        refreshAIAvailability()
        if consentGate.state.granted {
            action()
        } else {
            pendingAIAction = action
            showConsent = true
        }
    }

    func grantConsent() {
        do {
            try consentGate.grant()
            consentGranted = true
            showConsent = false
            refreshAIAvailability()
            let action = pendingAIAction
            pendingAIAction = nil
            action?()
        } catch {
            statusMessage = "Consent persist failed: \(error.localizedDescription)"
        }
    }

    func denyConsent() {
        showConsent = false
        pendingAIAction = nil
        statusMessage = "AI not authorized. Local audit tools remain available."
        refreshAIAvailability()
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            statusMessage = "AI access revoked. Outbound sends stopped."
            refreshAIAvailability()
        } catch {
            statusMessage = "Revoke failed: \(error.localizedDescription)"
        }
    }

    func detectSnags() {
        guard let audit = activeAudit else { return }
        requestAI { [weak self] in
            Task { @MainActor in
                await self?.runDetectSnags(audit: audit)
            }
        }
    }

    private func runDetectSnags(audit: Audit) async {
        recognitionBusy = true
        defer { recognitionBusy = false }
        refreshAIAvailability()
        if apiKey() == nil {
            // Honest local heuristic placeholder — not a canned AI success.
            let drafts = activePhotos.prefix(3).enumerated().map { idx, photo in
                SnagDraft(
                    id: UUID().uuidString,
                    auditId: audit.id,
                    photoId: photo.id,
                    label: "Possible surface defect \(idx + 1)",
                    approxLocationHint: "Near photo \(photo.sequence)",
                    severityGuess: idx == 0 ? "high" : "medium",
                    notesHint: "Local heuristic only — AI key not configured."
                )
            }
            snagDrafts.removeAll { $0.auditId == audit.id }
            snagDrafts.append(contentsOf: drafts)
            persistDrafts()
            statusMessage = aiUnavailableReason ?? "AI unavailable."
            return
        }
        do {
            let client = DeepSeekClient(apiKey: apiKey()!)
            let labels = activePunchItems.map(\.title)
            let drafts = try await client.detectSnags(
                photos: activePhotos.map { photoURL(for: $0) },
                priorLabels: labels,
                auditId: audit.id
            )
            snagDrafts.removeAll { $0.auditId == audit.id }
            snagDrafts.append(contentsOf: drafts)
            persistDrafts()
            statusMessage = "Snag drafts ready for review."
        } catch {
            statusMessage = "Snag detection failed: \(error.localizedDescription)"
        }
    }

    func saveDraft(_ draft: SnagDraft) {
        let item = PunchItem(
            id: UUID().uuidString,
            auditId: draft.auditId,
            title: draft.label,
            location: draft.approxLocationHint,
            severity: draft.severityGuess,
            notes: draft.notesHint,
            photoRefs: [draft.photoId]
        )
        punchItems.append(item)
        snagDrafts.removeAll { $0.id == draft.id }
        persistPunch()
        persistDrafts()
        statusMessage = "Saved punch item."
    }

    func rejectDraft(_ draft: SnagDraft) {
        snagDrafts.removeAll { $0.id == draft.id }
        persistDrafts()
        statusMessage = "Discarded snag draft."
    }

    func beginEditDraft(_ draft: SnagDraft) {
        editingDraft = draft
    }

    func applyEditedDraft() {
        guard var draft = editingDraft else { return }
        if let idx = snagDrafts.firstIndex(where: { $0.id == draft.id }) {
            snagDrafts[idx] = draft
            persistDrafts()
        }
        editingDraft = nil
        statusMessage = "Draft updated — Save to punch list when ready."
    }

    func addManualSnag() {
        guard let audit = activeAudit else { return }
        let draft = SnagDraft(
            id: UUID().uuidString,
            auditId: audit.id,
            photoId: activePhotos.first?.id ?? "",
            label: "Manual snag",
            approxLocationHint: "",
            severityGuess: "medium",
            notesHint: ""
        )
        snagDrafts.insert(draft, at: 0)
        editingDraft = draft
        persistDrafts()
    }

    func askAIForFields(punchItemId: String) {
        requestAI { [weak self] in
            Task { @MainActor in
                await self?.runFieldFill(punchItemId: punchItemId)
            }
        }
    }

    private func runFieldFill(punchItemId: String) async {
        guard let item = punchItems.first(where: { $0.id == punchItemId }) else { return }
        chatBusy = true
        defer { chatBusy = false }
        refreshAIAvailability()
        if apiKey() == nil {
            fieldPatch = FieldPatchDraft(
                id: UUID().uuidString,
                punchItemId: item.id,
                location: item.location.isEmpty ? "Zone A" : item.location,
                severity: item.severity,
                assignee: item.assignee.isEmpty ? "GC" : item.assignee,
                dueDate: item.dueDate.isEmpty ? "TBD" : item.dueDate,
                notes: item.notes,
                rationale: "Local suggestion only — AI key not configured. Review before Save."
            )
            statusMessage = aiUnavailableReason ?? "AI unavailable."
            return
        }
        do {
            let client = DeepSeekClient(apiKey: apiKey()!)
            let patch = try await client.suggestFieldPatch(
                item: item,
                chatText: chatText,
                priorFeedback: item.feedbackNotes
            )
            fieldPatch = patch
            statusMessage = "Field suggestions ready — Save or Not this."
        } catch {
            statusMessage = "Chat fill failed: \(error.localizedDescription)"
        }
    }

    func saveFieldPatch() {
        guard let patch = fieldPatch,
              let idx = punchItems.firstIndex(where: { $0.id == patch.punchItemId }) else { return }
        if let location = patch.location { punchItems[idx].location = location }
        if let severity = patch.severity { punchItems[idx].severity = severity }
        if let assignee = patch.assignee { punchItems[idx].assignee = assignee }
        if let dueDate = patch.dueDate { punchItems[idx].dueDate = dueDate }
        if let notes = patch.notes { punchItems[idx].notes = notes }
        if !chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            punchItems[idx].feedbackNotes.append(chatText)
        }
        persistPunch()
        fieldPatch = nil
        chatText = ""
        statusMessage = "Punch fields saved."
    }

    func rejectFieldPatch() {
        if !chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let patch = fieldPatch,
           let idx = punchItems.firstIndex(where: { $0.id == patch.punchItemId }) {
            punchItems[idx].feedbackNotes.append("Rejected: \(chatText)")
            persistPunch()
        }
        fieldPatch = nil
        statusMessage = "Field suggestions discarded."
    }

    func generateAnnotatedReport() {
        guard let audit = activeAudit else { return }
        requestAI { [weak self] in
            Task { @MainActor in
                await self?.runReport(audit: audit)
            }
        }
    }

    private func runReport(audit: Audit) async {
        reportBusy = true
        defer { reportBusy = false }
        refreshAIAvailability()
        guard apiKey() != nil else {
            lastReportPreviewPath = nil
            statusMessage = "Annotated report unavailable: DeepSeek key not configured."
            return
        }
        do {
            let client = DeepSeekClient(apiKey: apiKey()!)
            let items = activePunchItems
            let caption = try await client.annotateCaption(items: items)
            // Compose a local annotated preview using punch labels over the first photo.
            let out = reportsRoot.appendingPathComponent("\(UUID().uuidString).jpg")
            if let first = activePhotos.first,
               let data = try? Data(contentsOf: photoURL(for: first)),
               let image = UIImage(data: data) {
                let annotated = annotate(image: image, labels: items.map(\.title))
                if let jpeg = annotated.jpegData(compressionQuality: 0.85) {
                    try jpeg.write(to: out, options: .atomic)
                    lastReportPreviewPath = out.path
                    let draft = ReportDraft(
                        id: UUID().uuidString,
                        auditId: audit.id,
                        punchItemIds: items.map(\.id),
                        imageRelativePath: out.lastPathComponent,
                        caption: caption
                    )
                    // Not persisted until Use.
                    statusMessage = "Report preview ready — Use or Discard. \(caption)"
                    pendingReportDraft = draft
                    return
                }
            }
            statusMessage = "Report needs at least one walkthrough photo."
        } catch {
            statusMessage = "Report generation failed: \(error.localizedDescription)"
        }
    }

    func useReportDraft() {
        guard let draft = pendingReportDraft else {
            statusMessage = "No report preview to keep."
            return
        }
        reportDrafts.append(draft)
        persistReports()
        pendingReportDraft = nil
        statusMessage = "Annotated report saved."
    }

    func discardReportDraft() {
        if let path = lastReportPreviewPath {
            try? FileManager.default.removeItem(atPath: path)
        }
        lastReportPreviewPath = nil
        pendingReportDraft = nil
        statusMessage = "Report preview discarded."
    }

    func startCoach() {
        guard let audit = activeAudit, !activePunchItems.isEmpty else {
            statusMessage = "Add punch items before Read aloud."
            return
        }
        coach = CoachSession(auditId: audit.id, stepIndex: 0, isPlaying: true)
        ChecklistTTS.shared.speak(textForCoachStep())
        statusMessage = "Reading checklist."
    }

    func pauseCoach() {
        ChecklistTTS.shared.stop()
        if var session = coach {
            session.isPlaying = false
            coach = session
        }
    }

    func nextCoachStep() {
        guard var session = coach else { return }
        let count = activePunchItems.count
        guard count > 0 else { return }
        session.stepIndex = min(session.stepIndex + 1, count - 1)
        session.isPlaying = true
        coach = session
        ChecklistTTS.shared.speak(textForCoachStep())
    }

    func replayCoachStep() {
        guard coach != nil else { return }
        ChecklistTTS.shared.speak(textForCoachStep())
    }

    func textForCoachStep() -> String {
        let items = activePunchItems
        guard let session = coach, items.indices.contains(session.stepIndex) else {
            return "No punch items."
        }
        let item = items[session.stepIndex]
        return "Item \(session.stepIndex + 1). Location \(item.location.isEmpty ? "unspecified" : item.location). \(item.title). Severity \(item.severity)."
    }

    private func annotate(image: UIImage, labels: [String]) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            image.draw(at: .zero)
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byTruncatingTail
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: max(18, image.size.width / 28)),
                .foregroundColor: UIColor.systemYellow,
                .paragraphStyle: paragraph,
                .backgroundColor: UIColor.black.withAlphaComponent(0.55)
            ]
            for (idx, label) in labels.prefix(6).enumerated() {
                let y = CGFloat(40 + idx * 48)
                let rect = CGRect(x: 24, y: y, width: image.size.width - 48, height: 40)
                ("• " + label as NSString).draw(in: rect, withAttributes: attrs)
            }
            let disclaimer = "Guidance only — not a building-code certification"
            let dAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: max(14, image.size.width / 40)),
                .foregroundColor: UIColor.white,
                .backgroundColor: UIColor.darkGray.withAlphaComponent(0.7)
            ]
            (disclaimer as NSString).draw(
                at: CGPoint(x: 24, y: image.size.height - 60),
                withAttributes: dAttrs
            )
        }
    }

    private func persistAudits() {
        do { try auditsStore.save(audits) } catch {
            statusMessage = "Could not save audits: \(error.localizedDescription)"
        }
    }

    private func persistPhotos() {
        do { try photosStore.save(photos) } catch {
            statusMessage = "Could not save photos: \(error.localizedDescription)"
        }
    }

    private func persistDrafts() {
        do { try draftsStore.save(snagDrafts) } catch {
            statusMessage = "Could not save drafts: \(error.localizedDescription)"
        }
    }

    private func persistPunch() {
        do { try punchStore.save(punchItems) } catch {
            statusMessage = "Could not save punch items: \(error.localizedDescription)"
        }
    }

    private func persistReports() {
        do { try reportsStore.save(reportDrafts) } catch {
            statusMessage = "Could not save reports: \(error.localizedDescription)"
        }
    }
}
