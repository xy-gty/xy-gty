import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import HemlineDomain

@MainActor
final class AppModel: ObservableObject {
    enum AppTab: Hashable { case closet, stylist, looks, settings }

    @Published var closetItems: [ClosetItem] = []
    @Published var drafts: [GarmentDraft] = []
    @Published var outfitPlans: [OutfitPlan] = []
    @Published var boards: [FlatLayBoard] = []
    @Published var briefings: [MorningBriefing] = []
    @Published var weatherContexts: [WeatherOccasionContext] = []
    @Published var selectedTab: AppTab = .closet
    @Published var path: [HemlineRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var chatBusy = false
    @Published var recognitionBusy = false
    @Published var chatText = ""
    @Published var weatherText = "62°F · light rain"
    @Published var occasionText = "Office Tuesday"
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var editingDraft: GarmentDraft?
    @Published var pendingPlan: OutfitPlan?
    @Published var pendingBoard: FlatLayBoard?
    @Published var activeBriefing: MorningBriefing?
    @Published var briefingIndex = 0
    @Published var aiUnavailableReason: String?
    @Published var pendingAIAction: (() -> Void)?
    @Published var showCameraPicker = false
    @Published var speechHost = SpeechCaptureHost()
    @Published var selectedItemID: UUID?
    @Published var tagEditBuffer = ""

    let storage: HemlineStorageRoot
    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<HemlineRoute>
    let briefingTTS = MorningBriefingTTS()

    private var cachedAPIKey: String?
    private let keychain = HemlineConsentFacade.makeAPIKeyStore()

    var cameraHardwareAvailable: Bool { CameraCaptureAvailability.cameraHardwareAvailable }

    var selectedItem: ClosetItem? {
        guard let id = selectedItemID else { return nil }
        return closetItems.first(where: { $0.id == id })
    }

    var savedLooks: [FlatLayBoard] {
        boards.filter { $0.status == "saved" }.sorted { ($0.savedAt ?? $0.createdAt) > ($1.savedAt ?? $1.createdAt) }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Hemline", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        storage = HemlineStorageRoot(rootDirectory: root)
        try? FileManager.default.createDirectory(at: storage.photosDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: storage.boardsDirectory, withIntermediateDirectories: true)
        navigation = HemlineNavigation.makeStore(directory: root)
        consentGate = HemlineConsentFacade.makeGate(storage: storage)
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
        // Optional Secrets.xcconfig compile-time key via Info.plist injection is not used;
        // Keychain / runtime configure only.
        refreshAIAvailability()
    }

    func reload() {
        closetItems = (try? storage.closetItems.load())?.items ?? []
        drafts = (try? storage.garmentDrafts.load())?.drafts ?? []
        outfitPlans = (try? storage.outfitPlans.load())?.plans ?? []
        boards = (try? storage.flatLayBoards.load())?.boards ?? []
        briefings = (try? storage.morningBriefings.load())?.briefings ?? []
        weatherContexts = (try? storage.weatherOccasions.load())?.contexts ?? []
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
            aiUnavailableReason = "AI unavailable — DeepSeek key not configured (local catalog still works)."
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

    // MARK: - Navigation helpers

    func push(_ route: HemlineRoute) {
        path.append(route)
        persistPath()
    }

    func popToRoot() {
        path.removeAll()
        persistPath()
    }

    // MARK: - Capture / import

    func importPhotoData(_ data: Data, sourceKind: String) {
        let name = "garment-\(UUID().uuidString).jpg"
        let url = storage.photosDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            var draft = GarmentDraft(
                localFileName: name,
                proposedCategory: "Tops",
                proposedColorTone: "Cool tone",
                proposedSeasonHint: "Spring",
                proposedTags: ["Tops", "Cool tone", "Spring"],
                sourceKind: sourceKind
            )
            recognitionBusy = true
            statusMessage = "Reading your piece…"
            Task {
                await self.recognizeDraft(&draft)
                self.recognitionBusy = false
                self.statusMessage = nil
                self.editingDraft = draft
                self.drafts.insert(draft, at: 0)
                try? self.storage.garmentDrafts.save(GarmentDraftCatalog(drafts: self.drafts))
                self.push(.garmentReview)
            }
        } catch {
            statusMessage = "Could not save photo: \(error.localizedDescription)"
        }
    }

    func importDemoPiece() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 640, height: 800))
        let image = renderer.image { ctx in
            UIColor(red: 0.18, green: 0.28, blue: 0.42, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 640, height: 800))
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .semibold),
                .foregroundColor: UIColor(white: 0.96, alpha: 1)
            ]
            NSString(string: "Navy linen shirt").draw(at: CGPoint(x: 48, y: 360), withAttributes: attrs)
        }
        if let data = image.jpegData(compressionQuality: 0.9) {
            importPhotoData(data, sourceKind: "demo")
        }
    }

    private func recognizeDraft(_ draft: inout GarmentDraft) async {
        guard let key = apiKey(), consentGranted else {
            // Local rule tags when outbound closed — honest offline path.
            draft.proposedCategory = draft.proposedCategory.isEmpty ? "Tops" : draft.proposedCategory
            return
        }
        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClientError.notAuthorized }
                _ = try self.consentGate.permit()
            }
            let url = storage.photoFileURL(for: draft)
            let recognized = try await client.recognizeGarment(photoURL: url)
            draft.proposedCategory = recognized.category
            draft.proposedColorTone = recognized.colorTone
            draft.proposedSeasonHint = recognized.seasonHint
            draft.proposedTags = recognized.tags
        } catch {
            statusMessage = "Recognition fallback (local tags): \(error.localizedDescription)"
        }
    }

    func keepDraft() {
        guard var draft = editingDraft else { return }
        if !tagEditBuffer.isEmpty {
            draft.proposedTags = tagEditBuffer.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }.filter { !$0.isEmpty }
            if let first = draft.proposedTags.first { draft.proposedCategory = first }
        }
        let item = ClosetItem(
            localFileName: draft.localFileName,
            category: draft.proposedCategory,
            colorTone: draft.proposedColorTone,
            seasonHint: draft.proposedSeasonHint,
            tags: draft.proposedTags,
            sourceKind: draft.sourceKind
        )
        closetItems.insert(item, at: 0)
        drafts.removeAll { $0.id == draft.id }
        try? storage.closetItems.save(ClosetItemCatalog(items: closetItems))
        try? storage.garmentDrafts.save(GarmentDraftCatalog(drafts: drafts))
        editingDraft = nil
        tagEditBuffer = ""
        selectedItemID = item.id
        path = [.closetItemDetail]
        persistPath()
        statusMessage = "Kept in closet."
    }

    func rejectDraft() {
        guard let draft = editingDraft else { return }
        drafts.removeAll { $0.id == draft.id }
        try? storage.garmentDrafts.save(GarmentDraftCatalog(drafts: drafts))
        let url = storage.photoFileURL(for: draft)
        try? FileManager.default.removeItem(at: url)
        editingDraft = nil
        tagEditBuffer = ""
        popToRoot()
        statusMessage = "Discarded draft — closet unchanged."
    }

    func beginEditTags() {
        guard let draft = editingDraft else { return }
        tagEditBuffer = draft.proposedTags.joined(separator: ", ")
    }

    // MARK: - Stylist chat

    func requestStylistPlan() {
        let prompt = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty || !weatherText.isEmpty || !occasionText.isEmpty else {
            statusMessage = "Add weather, occasion, or a question first."
            return
        }
        runWithConsent { [weak self] in
            await self?.performStylistPlan(prompt: prompt)
        }
    }

    private func performStylistPlan(prompt: String) async {
        chatBusy = true
        statusMessage = "Planning a look…"
        defer {
            chatBusy = false
            if statusMessage == "Planning a look…" { statusMessage = nil }
        }
        let weather = WeatherOccasionContext(weatherSummary: weatherText, occasion: occasionText)
        weatherContexts.insert(weather, at: 0)
        try? storage.weatherOccasions.save(WeatherOccasionCatalog(contexts: weatherContexts))

        let closetSummary = closetItems.prefix(12).map {
            "\($0.category)/\($0.colorTone)/\($0.seasonHint)"
        }.joined(separator: "; ")
        let priorFeedback = outfitPlans.prefix(5).compactMap { plan -> String? in
            plan.responseText.isEmpty ? nil : "prior:\(plan.promptText) => \(plan.responseText.prefix(80))"
        }
        let savedLookHints = savedLooks.prefix(3).map { "saved_look:\($0.id.uuidString.prefix(8))" }

        var plan = OutfitPlan(
            promptText: prompt.isEmpty ? "\(occasionText) · \(weatherText)" : prompt,
            weatherOccasionID: weather.id,
            closetItemIDs: closetItems.prefix(6).map(\.id),
            includesStyleDisclaimer: true
        )

        if let key = apiKey(), consentGranted {
            do {
                let permit = try consentGate.permit()
                try consentGate.validate(permit)
                let client = DeepSeekClient(apiKey: key) { [weak self] in
                    guard let self else { throw DeepSeekClientError.notAuthorized }
                    _ = try self.consentGate.permit()
                }
                plan.responseText = try await client.stylistChat(
                    prompt: plan.promptText,
                    weather: weatherText,
                    occasion: occasionText,
                    closetSummary: closetSummary,
                    priorFeedback: priorFeedback + savedLookHints
                )
            } catch {
                plan.responseText = localDemoLook(for: plan.promptText) + "\n\n(AI unavailable: \(error.localizedDescription))"
                statusMessage = aiUnavailableReason ?? error.localizedDescription
            }
        } else {
            plan.responseText = localDemoLook(for: plan.promptText) + "\n\n(AI unavailable — local demo look.)"
            statusMessage = aiUnavailableReason
        }

        outfitPlans.insert(plan, at: 0)
        try? storage.outfitPlans.save(OutfitPlanCatalog(plans: outfitPlans))
        pendingPlan = plan
        chatText = ""
    }

    private func localDemoLook(for prompt: String) -> String {
        let piece = closetItems.first.map { "\($0.category) · \($0.colorTone)" } ?? "Navy linen shirt"
        return """
        Suggested look for \(prompt.isEmpty ? occasionText : prompt):
        • \(piece)
        • Charcoal trousers
        • Loafers
        \(HemlineIdentity.styleSuggestionDisclaimer)
        """
    }

    func makeFlatLay(from plan: OutfitPlan?) {
        let source = plan ?? pendingPlan
        guard let source else {
            statusMessage = "Ask the stylist for a plan first."
            return
        }
        let name = "board-\(UUID().uuidString).png"
        let url = storage.boardsDirectory.appendingPathComponent(name)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 720, height: 960))
        let image = renderer.image { ctx in
            UIColor(red: 0.16, green: 0.18, blue: 0.20, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 720, height: 960))
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor(red: 0.96, green: 0.94, blue: 0.92, alpha: 1)
            ]
            NSString(string: "Hemline look").draw(at: CGPoint(x: 40, y: 48), withAttributes: titleAttrs)
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .regular),
                .foregroundColor: UIColor(red: 0.83, green: 0.78, blue: 0.72, alpha: 1)
            ]
            NSString(string: source.responseText).draw(
                in: CGRect(x: 40, y: 120, width: 640, height: 700),
                withAttributes: bodyAttrs
            )
        }
        if let data = image.pngData() {
            try? data.write(to: url, options: .atomic)
        }
        let board = FlatLayBoard(
            outfitPlanID: source.id,
            closetItemIDs: source.closetItemIDs,
            localFileName: name,
            status: "draft"
        )
        pendingBoard = board
        push(.flatLayBoard)
    }

    func saveLook() {
        guard var board = pendingBoard else { return }
        board.status = "saved"
        board.savedAt = Date()
        boards.insert(board, at: 0)
        try? storage.flatLayBoards.save(FlatLayBoardCatalog(boards: boards))
        pendingBoard = nil
        selectedTab = .looks
        popToRoot()
        statusMessage = "Look saved."
    }

    func discardLook() {
        if let board = pendingBoard {
            let url = storage.boardFileURL(for: board)
            try? FileManager.default.removeItem(at: url)
        }
        pendingBoard = nil
        popToRoot()
        statusMessage = "Discarded look — nothing saved."
    }

    // MARK: - Morning briefing

    func prepareMorningBriefing() {
        runWithConsent { [weak self] in
            await self?.performMorningBriefing()
        }
    }

    private func performMorningBriefing() async {
        statusMessage = "Building morning briefing…"
        let plan = pendingPlan ?? outfitPlans.first
        var utterances: [String]
        if let key = apiKey(), consentGranted, let plan {
            do {
                let permit = try consentGate.permit()
                try consentGate.validate(permit)
                let client = DeepSeekClient(apiKey: key) { [weak self] in
                    guard let self else { throw DeepSeekClientError.notAuthorized }
                    _ = try self.consentGate.permit()
                }
                utterances = try await client.morningBriefingUtterances(plan: plan)
            } catch {
                utterances = localBriefingUtterances(plan: plan)
                statusMessage = "Local briefing (\(error.localizedDescription))"
            }
        } else {
            utterances = localBriefingUtterances(plan: plan)
            statusMessage = aiUnavailableReason ?? "Local briefing ready."
        }
        let briefing = MorningBriefing(
            outfitPlanID: plan?.id,
            utterances: utterances,
            weatherOccasionID: plan?.weatherOccasionID,
            includesStyleDisclaimer: true
        )
        briefings.insert(briefing, at: 0)
        try? storage.morningBriefings.save(MorningBriefingCatalog(briefings: briefings))
        activeBriefing = briefing
        briefingIndex = 0
        push(.morningBriefing)
        if statusMessage == "Building morning briefing…" { statusMessage = nil }
    }

    private func localBriefingUtterances(plan: OutfitPlan?) -> [String] {
        let look = plan?.responseText.split(separator: "\n").first.map(String.init)
            ?? "Navy linen shirt with charcoal trousers"
        return [
            "Good morning — Hemline briefing for \(occasionText).",
            "Weather note: \(weatherText).",
            "Today's look: \(look).",
            HemlineIdentity.styleSuggestionDisclaimer
        ]
    }

    func playBriefing() {
        guard let briefing = activeBriefing else { return }
        do {
            try briefingTTS.speak(briefing: briefing, at: briefingIndex)
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func pauseBriefing() {
        briefingTTS.stop()
    }

    func nextBriefingStep() {
        guard let briefing = activeBriefing else { return }
        if let next = briefingTTS.nextIndex(after: briefingIndex, utteranceCount: briefing.utterances.count) {
            briefingIndex = next
            playBriefing()
        } else {
            statusMessage = "End of briefing."
        }
    }

    // MARK: - Speech

    func startSpeechCapture() {
        Task {
            await speechHost.start()
            if !path.contains(.speechCapture) {
                push(.speechCapture)
            }
        }
    }

    func finishSpeechCapture() {
        let text = speechHost.consumeTranscript()
        if !text.isEmpty {
            chatText = text
        }
        path.removeAll { $0 == .speechCapture }
        persistPath()
        selectedTab = .stylist
        if !path.contains(.stylistChat) {
            push(.stylistChat)
        }
    }

    // MARK: - Consent

    func runWithConsent(_ action: @escaping () async -> Void) {
        refreshAIAvailability()
        if consentGranted {
            Task { await action() }
            return
        }
        pendingAIAction = { Task { await action() } }
        showConsent = true
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
        showConsent = false
        pendingAIAction = nil
        statusMessage = "Kept local-only. Catalog and browsing still work."
        refreshAIAvailability()
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "AI sharing revoked — outbound stopped."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func image(for item: ClosetItem) -> UIImage? {
        UIImage(contentsOfFile: storage.photoFileURL(for: item).path)
    }

    func image(for draft: GarmentDraft) -> UIImage? {
        UIImage(contentsOfFile: storage.photoFileURL(for: draft).path)
    }

    func image(for board: FlatLayBoard) -> UIImage? {
        UIImage(contentsOfFile: storage.boardFileURL(for: board).path)
    }
}
