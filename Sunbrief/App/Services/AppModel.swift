import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import SunbriefDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var shots: [ScoutShot] = []
    @Published var cards: [SceneCard] = []
    @Published var plans: [ScoutPlan] = []
    @Published var windows: [TimingWindow] = []
    @Published var overlays: [OverlayMark] = []
    @Published var messages: [CoachMessage] = []
    @Published var turns: [CoachTurn] = []
    @Published var notes: [ShootNote] = []
    @Published var briefings: [BriefingClip] = []

    @Published var activeCardId: String?
    @Published var path: [SunbriefRoute] = []
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingSceneDraft: SceneCard?
    @Published var pendingTurn: CoachTurn?
    @Published var editingLabels = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var userFeedback = ""
    @Published var overlayDraftText = ""
    @Published var aiUnavailableReason: String?
    @Published var selectedWindowId: String?
    @Published var briefingIndex = 0
    @Published var pendingShotId: String?

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<SunbriefRoute>
    let tts = BriefingPlayer()
    let speechService = SpeechRecognitionService()

    private let shotsStore: AtomicCodableStore<[ScoutShot]>
    private let cardsStore: AtomicCodableStore<[SceneCard]>
    private let plansStore: AtomicCodableStore<[ScoutPlan]>
    private let windowsStore: AtomicCodableStore<[TimingWindow]>
    private let overlaysStore: AtomicCodableStore<[OverlayMark]>
    private let messagesStore: AtomicCodableStore<[CoachMessage]>
    private let turnsStore: AtomicCodableStore<[CoachTurn]>
    private let notesStore: AtomicCodableStore<[ShootNote]>
    private let briefingsStore: AtomicCodableStore<[BriefingClip]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = SunbriefStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingCoachAction: (() -> Void)?
    private var pendingOverlayPoint: CGPoint?

    var activeCard: SceneCard? {
        guard let id = activeCardId else { return cards.first }
        return cards.first(where: { $0.id == id }) ?? cards.first
    }

    var activePlan: ScoutPlan? {
        guard let cardId = activeCard?.id else { return nil }
        return plans.first(where: { $0.cardId == cardId })
    }

    var activeShot: ScoutShot? {
        guard let shotId = activeCard?.shotId ?? pendingShotId else { return nil }
        return shots.first(where: { $0.id == shotId })
    }

    var cardWindows: [TimingWindow] {
        guard let plan = activePlan else { return defaultDayWindows() }
        let ids = Set(plan.windowIds)
        let bound = windows.filter { ids.contains($0.id) }
        return bound.isEmpty ? defaultDayWindows() : bound.sorted { $0.startsAt < $1.startsAt }
    }

    var cardOverlays: [OverlayMark] {
        guard let cardId = activeCard?.id else { return [] }
        return overlays.filter { $0.cardId == cardId }
    }

    var cardTurns: [CoachTurn] {
        guard let cardId = activeCard?.id else { return [] }
        return turns.filter { $0.cardId == cardId }.sorted { $0.createdAt < $1.createdAt }
    }

    var cardMessages: [CoachMessage] {
        guard let cardId = activeCard?.id else { return [] }
        return messages.filter { $0.cardId == cardId }.sorted { $0.createdAt < $1.createdAt }
    }

    var planBriefings: [BriefingClip] {
        guard let planId = activePlan?.id else { return [] }
        return briefings.filter { $0.planId == planId }.sorted { $0.order < $1.order }
    }

    var planNotes: [ShootNote] {
        guard let planId = activePlan?.id else { return [] }
        return notes.filter { $0.planId == planId }.sorted { $0.createdAt < $1.createdAt }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Sunbrief", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        shotsStore = SunbriefStores.scoutShotStore(directory: root)
        cardsStore = SunbriefStores.sceneCardStore(directory: root)
        plansStore = SunbriefStores.scoutPlanStore(directory: root)
        windowsStore = SunbriefStores.timingWindowStore(directory: root)
        overlaysStore = SunbriefStores.overlayMarkStore(directory: root)
        messagesStore = SunbriefStores.coachMessageStore(directory: root)
        turnsStore = SunbriefStores.coachTurnStore(directory: root)
        notesStore = SunbriefStores.shootNoteStore(directory: root)
        briefingsStore = SunbriefStores.briefingClipStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = SunbriefStores.storeURL(directory: root, name: SunbriefStores.aiConsentLocal)
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
                    try? await SunbriefStores.consentKeychainStore().save(mirrorData)
                }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        seedDefaultWindowsIfNeeded()
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
        shots = (try? shotsStore.load()) ?? []
        cards = (try? cardsStore.load()) ?? []
        plans = (try? plansStore.load()) ?? []
        windows = (try? windowsStore.load()) ?? []
        overlays = (try? overlaysStore.load()) ?? []
        messages = (try? messagesStore.load()) ?? []
        turns = (try? turnsStore.load()) ?? []
        notes = (try? notesStore.load()) ?? []
        briefings = (try? briefingsStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeCardId == nil {
            activeCardId = cards.first?.id
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

    func push(_ route: SunbriefRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
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
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            statusMessage = "Image encode failed."
            return
        }
        let id = UUID().uuidString
        let name = "\(id).jpg"
        let url = importsRoot.appendingPathComponent(name)
        try data.write(to: url, options: .atomic)
        let shot = ScoutShot(
            id: id,
            relativePath: "imports/\(name)",
            source: source,
            capturedAt: Date()
        )
        shots.insert(shot, at: 0)
        try shotsStore.save(shots)
        pendingShotId = id
        let labels = SceneRecognizer.labels(for: image)
        pendingSceneDraft = SceneCard(
            id: UUID().uuidString,
            shotId: id,
            placeLabel: labels.place,
            lightQuality: labels.light,
            facingHint: labels.facing,
            status: "draft",
            updatedAt: Date()
        )
        editingLabels = "\(labels.place) · \(labels.light) · \(labels.facing)"
        statusMessage = "Scene draft ready — review labels."
        push(.sceneReview)
    }

    func imageURL(for shot: ScoutShot) -> URL {
        supportRoot.appendingPathComponent(shot.relativePath)
    }

    func loadShotImage(_ shot: ScoutShot) -> UIImage? {
        UIImage(contentsOfFile: imageURL(for: shot).path)
    }

    // MARK: - Scene review

    func keepSceneDraft() {
        guard var draft = pendingSceneDraft else { return }
        applyEditedLabels(to: &draft)
        draft.status = "confirmed"
        draft.updatedAt = Date()
        cards.insert(draft, at: 0)
        try? cardsStore.save(cards)
        activeCardId = draft.id
        let dayWindows = ensureDayWindows()
        let plan = ScoutPlan(
            id: UUID().uuidString,
            cardId: draft.id,
            title: "\(draft.placeLabel) scout",
            windowIds: dayWindows.map(\.id),
            notes: "",
            updatedAt: Date()
        )
        plans.insert(plan, at: 0)
        try? plansStore.save(plans)
        seedBriefings(for: plan, card: draft)
        pendingSceneDraft = nil
        pendingShotId = nil
        statusMessage = "Scout card kept."
        path = [.scoutCardDetail]
        persistNavigation()
    }

    func discardSceneDraft() {
        if let shotId = pendingSceneDraft?.shotId ?? pendingShotId {
            shots.removeAll { $0.id == shotId }
            try? shotsStore.save(shots)
        }
        pendingSceneDraft = nil
        pendingShotId = nil
        statusMessage = "Draft discarded — nothing saved."
        popToHome()
    }

    private func applyEditedLabels(to card: inout SceneCard) {
        let parts = editingLabels.split(separator: "·").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if parts.count >= 1, !parts[0].isEmpty { card.placeLabel = parts[0] }
        if parts.count >= 2, !parts[1].isEmpty { card.lightQuality = parts[1] }
        if parts.count >= 3, !parts[2].isEmpty { card.facingHint = parts[2] }
    }

    // MARK: - Timing windows / sky-arc

    func defaultDayWindows(reference: Date = Date()) -> [TimingWindow] {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: reference)
        func at(_ hour: Int, _ minute: Int = 0) -> Date {
            cal.date(byAdding: .minute, value: hour * 60 + minute, to: startOfDay) ?? reference
        }
        return [
            TimingWindow(id: "win-sunrise", kind: "sunrise", startsAt: at(6, 10), endsAt: at(6, 40), label: "Sunrise"),
            TimingWindow(id: "win-golden-am", kind: "golden", startsAt: at(6, 40), endsAt: at(7, 30), label: "Golden AM"),
            TimingWindow(id: "win-blue", kind: "blue", startsAt: at(18, 40), endsAt: at(19, 20), label: "Blue hour"),
            TimingWindow(id: "win-golden-pm", kind: "golden", startsAt: at(17, 50), endsAt: at(18, 40), label: "Golden PM"),
            TimingWindow(id: "win-moon", kind: "moon", startsAt: at(20, 10), endsAt: at(21, 0), label: "Moonrise"),
        ]
    }

    func seedDefaultWindowsIfNeeded() {
        if windows.isEmpty {
            windows = defaultDayWindows()
            try? windowsStore.save(windows)
        }
    }

    func ensureDayWindows() -> [TimingWindow] {
        seedDefaultWindowsIfNeeded()
        return windows.sorted { $0.startsAt < $1.startsAt }
    }

    func selectWindow(_ window: TimingWindow) {
        selectedWindowId = window.id
        guard var plan = activePlan else { return }
        if !plan.windowIds.contains(window.id) {
            plan.windowIds.append(window.id)
        }
        plan.updatedAt = Date()
        if let idx = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[idx] = plan
            try? plansStore.save(plans)
        }
        statusMessage = "Bound \(window.label) to plan."
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
                    cardId: activeCard?.id ?? "",
                    role: "coach",
                    text: local.text,
                    createdAt: Date(),
                    status: "draft"
                )
            )
            try? messagesStore.save(messages)
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
        statusMessage = "AI send blocked — local scouting still available."
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
        guard let card = activeCard, let key = apiKey() else {
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
            let priorFeedback = cardTurns.filter { $0.role == "user" }.map(\.text)
            let reply = try await client.coachTiming(
                sceneLabels: "\(card.placeLabel); \(card.lightQuality); \(card.facingHint)",
                shotMeta: activeShot.map { "\($0.source) \($0.capturedAt)" } ?? "",
                planWindows: cardWindows.map(\.label),
                userChatText: coachQuestion.isEmpty ? "When is the best golden-hour window?" : coachQuestion,
                voiceTranscript: speechTranscript,
                overlayNotes: cardOverlays.map(\.text),
                priorFeedback: priorFeedback + (userFeedback.isEmpty ? [] : [userFeedback]),
                cardId: card.id
            )
            pendingTurn = reply
            messages.append(
                CoachMessage(
                    id: UUID().uuidString,
                    cardId: card.id,
                    role: "coach",
                    text: reply.text,
                    createdAt: Date(),
                    status: "draft"
                )
            )
            try? messagesStore.save(messages)
            push(.turnReview)
        } catch {
            statusMessage = "Coach failed: \(error.localizedDescription)"
            let local = localCoachReply()
            pendingTurn = local
            push(.turnReview)
        }
    }

    private func localCoachReply() -> CoachTurn {
        let card = activeCard
        let window = cardWindows.first(where: { $0.kind == "golden" }) ?? cardWindows.first
        let text: String
        if let window, let card {
            text = "Local timing (AI key gap): for \(card.placeLabel) (\(card.facingHint)), prefer \(window.label) \(Self.timeRange(window)). Soft side-light favors \(card.lightQuality)."
        } else {
            text = "Local timing tip: stand west-facing for golden PM; keep ridge silhouette for moonrise. Configure DeepSeek key for live coach."
        }
        return CoachTurn(
            id: UUID().uuidString,
            cardId: card?.id ?? "",
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
                    cardId: turn.cardId,
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
                    cardId: turn.cardId,
                    role: "user",
                    text: userFeedback,
                    createdAt: Date()
                )
            )
        }
        try? turnsStore.save(turns)
        messages.removeAll { $0.cardId == turn.cardId && $0.status == "draft" }
        try? messagesStore.save(messages)
        pendingTurn = nil
        coachQuestion = ""
        userFeedback = ""
        statusMessage = "Coach turn kept."
        if path.last == .turnReview { _ = path.popLast() }
        persistNavigation()
    }

    func discardPendingTurn() {
        if let cardId = pendingTurn?.cardId {
            messages.removeAll { $0.cardId == cardId && $0.status == "draft" }
            try? messagesStore.save(messages)
        }
        pendingTurn = nil
        statusMessage = "Draft discarded — no CoachTurn written."
        if path.last == .turnReview { _ = path.popLast() }
        persistNavigation()
    }

    // MARK: - Overlay

    func beginOverlayTap(at normalized: CGPoint) {
        pendingOverlayPoint = normalized
        if overlayDraftText.isEmpty {
            overlayDraftText = "Golden rim light"
        }
    }

    func saveOverlayMark() {
        guard let card = activeCard, let shot = activeShot, let point = pendingOverlayPoint else {
            statusMessage = "Tap the photo to place a soft mark first."
            return
        }
        let mark = OverlayMark(
            id: UUID().uuidString,
            cardId: card.id,
            shotId: shot.id,
            xNorm: Double(point.x),
            yNorm: Double(point.y),
            text: overlayDraftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "Soft golden light" : overlayDraftText
        )
        overlays.append(mark)
        try? overlaysStore.save(overlays)
        pendingOverlayPoint = nil
        overlayDraftText = ""
        statusMessage = "Overlay mark saved."
    }

    func discardOverlayDraft() {
        pendingOverlayPoint = nil
        overlayDraftText = ""
        statusMessage = "Overlay draft discarded."
    }

    // MARK: - Briefing TTS

    private func seedBriefings(for plan: ScoutPlan, card: SceneCard) {
        let clips = [
            BriefingClip(
                id: UUID().uuidString,
                planId: plan.id,
                stopLabel: "Approach",
                spokenText: "Next stop: approach \(card.placeLabel). Watch \(card.facingHint) for \(card.lightQuality).",
                order: 0
            ),
            BriefingClip(
                id: UUID().uuidString,
                planId: plan.id,
                stopLabel: "Golden window",
                spokenText: "Hold for golden hour on the ridge. Soft side-light, not a measuring overlay.",
                order: 1
            ),
            BriefingClip(
                id: UUID().uuidString,
                planId: plan.id,
                stopLabel: "Exit frame",
                spokenText: "After blue hour, pack and note moonrise if the ridge stays clear.",
                order: 2
            ),
        ]
        briefings.append(contentsOf: clips)
        try? briefingsStore.save(briefings)
    }

    func playBriefing() {
        let clips = planBriefings
        guard !clips.isEmpty else {
            statusMessage = "No briefing yet — keep a scout card first."
            return
        }
        let idx = min(max(briefingIndex, 0), clips.count - 1)
        tts.speak(clips[idx].spokenText)
        statusMessage = "Playing: \(clips[idx].stopLabel)"
    }

    func pauseBriefing() {
        tts.stop()
    }

    func nextBriefing() {
        let clips = planBriefings
        guard !clips.isEmpty else { return }
        briefingIndex = (briefingIndex + 1) % clips.count
        playBriefing()
    }

    // MARK: - Dictate

    func startDictation() async {
        speechBusy = true
        defer { speechBusy = false }
        do {
            let text = try await speechService.transcribeOnce()
            speechTranscript = text
            statusMessage = "Transcript ready — Save note to keep."
        } catch {
            statusMessage = "Speech unavailable: \(error.localizedDescription). Simulator may need device mic."
        }
    }

    func saveShootNote() {
        guard let plan = activePlan else {
            statusMessage = "Keep a scout card before saving notes."
            return
        }
        let text = speechTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            statusMessage = "Empty transcript — nothing saved."
            return
        }
        let note = ShootNote(
            id: UUID().uuidString,
            planId: plan.id,
            transcript: text,
            createdAt: Date()
        )
        notes.insert(note, at: 0)
        try? notesStore.save(notes)
        if var plan = activePlan {
            plan.notes = [plan.notes, text].filter { !$0.isEmpty }.joined(separator: "\n")
            plan.updatedAt = Date()
            if let idx = plans.firstIndex(where: { $0.id == plan.id }) {
                plans[idx] = plan
                try? plansStore.save(plans)
            }
        }
        statusMessage = "Shoot note saved."
    }

    func cancelDictation() {
        speechTranscript = ""
        speechService.cancel()
        statusMessage = "Dictation cancelled — nothing written."
    }

    static func timeRange(_ window: TimingWindow) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: window.startsAt))–\(f.string(from: window.endsAt))"
    }
}

enum SceneRecognizer {
    static func labels(for image: UIImage) -> (place: String, light: String, facing: String) {
        let size = image.size
        let aspect = size.width / max(size.height, 1)
        let place: String
        if aspect > 1.35 {
            place = "Wide ridge"
        } else if aspect < 0.85 {
            place = "Tall canyon wall"
        } else {
            place = "Mountain meadow"
        }
        var brightness: CGFloat = 0.55
        if let cg = image.cgImage {
            // Cheap heuristic: sample mid pixel average via thumbnail
            let thumb = UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8)).image { _ in
                image.draw(in: CGRect(x: 0, y: 0, width: 8, height: 8))
            }
            if let data = thumb.cgImage?.dataProvider?.data {
                let ptr = CFDataGetBytePtr(data)
                if let ptr {
                    brightness = CGFloat(ptr[0] + ptr[1] + ptr[2]) / (3.0 * 255.0)
                }
            }
            _ = cg
        }
        let light: String
        if brightness > 0.72 {
            light = "Hard noon wash"
        } else if brightness > 0.45 {
            light = "Warm side-light"
        } else {
            light = "Blue-hour hush"
        }
        let facing = brightness > 0.55 ? "West-facing rim" : "East ridge silhouette"
        return (place, light, facing)
    }
}
