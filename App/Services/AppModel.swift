import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import FinishCueDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var state = FinishCueState()
    @Published var path: [FinishCueRoute] = []
    @Published var statusMessage: String?
    @Published var statusIsError = false
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var readBusy = false
    @Published var coachBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var showCamera = false
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var aiUnavailableReason: String?
    @Published var activeHeatId: String?
    @Published var activeStripId: String?
    @Published var activeCardId: String?
    @Published var legalPageName = "privacy"
    @Published var scrubPosition: Double = 0.35
    @Published var laneMarks: [Int] = [1, 2, 3, 4]
    @Published var timeChips: [String] = []
    @Published var editLaneDraft = ""
    @Published var editTimeDraft = ""
    @Published var editingReadId: String?
    @Published var lastUserFeedback = ""

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<FinishCueRoutePayload>
    let tts = TTSPlayer()
    let speechService = SpeechRecognitionService()
    let voiceRecorder = VoiceNoteRecorder()

    private let heatStore: HeatStore
    private let supportRoot: URL
    private let mediaRoot: URL
    private let keychain = FinishCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingAIAction: (() -> Void)?
    private var importGeneration = 0

    var activeHeat: HeatPack? {
        guard let id = activeHeatId else { return state.heatPacks.first }
        return state.heatPacks.first(where: { $0.id == id })
    }

    var activeStrip: FinishStrip? {
        guard let id = activeStripId else {
            guard let heatId = activeHeat?.id else { return nil }
            return state.finishStrips.first(where: { $0.heatPackId == heatId })
        }
        return state.finishStrips.first(where: { $0.id == id })
    }

    var heatReads: [LaneRead] {
        guard let id = activeHeat?.id else { return [] }
        return state.laneReads.filter { $0.heatPackId == id }.sorted { $0.laneNumber < $1.laneNumber }
    }

    var draftReads: [LaneRead] {
        heatReads.filter { $0.status == "draft" }
    }

    var confirmedReads: [LaneRead] {
        heatReads.filter { $0.status == "confirmed" }
    }

    var heatTurns: [CoachTurn] {
        guard let id = activeHeat?.id else { return [] }
        return state.coachTurns.filter { $0.heatPackId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var heatCards: [FinishCard] {
        guard let id = activeHeat?.id else { return [] }
        return state.finishCards.filter { $0.heatPackId == id }
    }

    var heatCallouts: [CalloutCue] {
        guard let id = activeHeat?.id else { return [] }
        return state.calloutCues.filter { $0.heatPackId == id }.sorted { $0.sortIndex < $1.sortIndex }
    }

    var priorLaneReadNotes: [String] {
        confirmedReads.map { "L\($0.laneNumber) \($0.athleteLabel) \($0.timeRead)" }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("finishcue", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        mediaRoot = root.appendingPathComponent("media", isDirectory: true)
        try? FileManager.default.createDirectory(at: mediaRoot, withIntermediateDirectories: true)

        heatStore = HeatStore(directory: root)
        navigation = TypedNavigationStore(
            url: FinishCueStores.storeURL(directory: root, name: FinishCueStores.navigationFile),
            isValid: { FinishCueRoute.allCases.contains($0.route) }
        )

        let consentURL = FinishCueStores.storeURL(directory: root, name: FinishCueStores.aiConsentLocal)
        consentGate = AIConsentContract.makeGate(
            load: {
                guard FileManager.default.fileExists(atPath: consentURL.path) else { return nil }
                return try JSONDecoder().decode(AIConsentGate.State.self, from: Data(contentsOf: consentURL))
            },
            persist: { gateState in
                let data = try JSONEncoder().encode(gateState)
                try data.write(to: consentURL, options: .atomic)
                let mirror = AIConsentRecord(
                    provider: AIConsentContract.provider,
                    disclosureVersion: gateState.disclosureVersion,
                    grantedAt: Date(),
                    revokedAt: gateState.granted ? nil : Date()
                )
                let mirrorData = try JSONEncoder().encode(mirror)
                Task { try? await FinishCueStores.consentKeychainStore().save(mirrorData) }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        if ProcessInfo.processInfo.arguments.contains("-uitest-seed") {
            seedUITestHeatIfNeeded()
        }
        if let restored = try? navigation.restore(), !restored.isEmpty {
            path = restored.map(\.route)
            if let heat = restored.compactMap(\.heatPackId).last {
                activeHeatId = heat
            }
            if let strip = restored.compactMap(\.finishStripId).last {
                activeStripId = strip
            }
        }
        Task { await self.loadAPIKeyFromKeychain() }
        refreshAIAvailability()
    }

    private func seedUITestHeatIfNeeded() {
        state = FinishCueState()
        let heatId = "uitest-heat"
        let stripId = "uitest-strip"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 640, height: 120)).image { ctx in
            UIColor(red: 0.745, green: 0.094, blue: 0.365, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 640, height: 120))
            UIColor(red: 0.925, green: 0.996, blue: 1.0, alpha: 1).setFill()
            for i in 0..<8 {
                ctx.fill(CGRect(x: CGFloat(i) * 80 + 10, y: 20, width: 60, height: 80))
            }
        }
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        let url = mediaRoot.appendingPathComponent("\(stripId).jpg")
        try? data.write(to: url, options: .atomic)
        let pack = HeatPack(
            id: heatId,
            title: "UITest Heat A",
            venueNote: "practice",
            complianceSnapshot: FinishCueCompliance.bannerEN,
            createdAt: Date(),
            updatedAt: Date()
        )
        let strip = FinishStrip(
            id: stripId,
            heatPackId: heatId,
            source: "photos",
            localMediaURL: url.path,
            capturedAt: Date()
        )
        state.heatPacks = [pack]
        state.finishStrips = [strip]
        state.laneReads = [
            LaneRead(id: "r1", heatPackId: heatId, finishStripId: stripId, laneNumber: 3, athleteLabel: "A. Lee", timeRead: "12.34", status: "draft", updatedAt: Date())
        ]
        timeChips = ["12.34", "12.51"]
        activeHeatId = heatId
        activeStripId = stripId
        persist()
    }

    private func loadAPIKeyFromKeychain() async {
        if let data = try? await keychain.load(),
           let key = String(data: data, encoding: .utf8),
           !key.isEmpty {
            cachedAPIKey = key
        } else if let env = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"], !env.isEmpty {
            cachedAPIKey = env
        } else if let bundled = Bundle.main.object(forInfoDictionaryKey: "DEEPSEEK_API_KEY") as? String, !bundled.isEmpty {
            cachedAPIKey = bundled
        }
        refreshAIAvailability()
    }

    func reload() {
        state = (try? heatStore.load()) ?? FinishCueState()
        consentGranted = consentGate.state.granted
        if activeHeatId == nil {
            activeHeatId = state.heatPacks.first?.id
        }
    }

    func persist() {
        try? heatStore.save(state)
        saveNavigation()
    }

    private func saveNavigation() {
        let payloads = path.map {
            FinishCueRoutePayload(
                route: $0,
                heatPackId: activeHeatId,
                finishStripId: activeStripId,
                finishCardId: activeCardId,
                legalPage: $0 == .legalPages ? legalPageName : nil
            )
        }
        try? navigation.save(payloads)
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI unavailable / local-only — scrub, annotate, and TTS still work."
        } else if !consentGate.state.granted {
            aiUnavailableReason = "AI unavailable until you allow data sharing."
        } else {
            aiUnavailableReason = nil
        }
    }

    func apiKey() -> String? {
        if let cachedAPIKey, !cachedAPIKey.isEmpty { return cachedAPIKey }
        return nil
    }

    func flash(_ message: String, error: Bool = false) {
        statusMessage = message
        statusIsError = error
    }

    func push(_ route: FinishCueRoute) {
        path.append(route)
        saveNavigation()
    }

    func popToHome() {
        path.removeAll()
        saveNavigation()
    }

    // MARK: - Heat packs

    func createHeatPack(title: String = "Heat pack") {
        let id = UUID().uuidString
        let pack = HeatPack(
            id: id,
            title: title,
            venueNote: "",
            complianceSnapshot: FinishCueCompliance.bannerEN,
            createdAt: Date(),
            updatedAt: Date()
        )
        state.heatPacks.insert(pack, at: 0)
        activeHeatId = id
        persist()
        push(.captureImport)
    }

    func openHeat(_ id: String) {
        activeHeatId = id
        if let strip = state.finishStrips.first(where: { $0.heatPackId == id }) {
            activeStripId = strip.id
        }
        push(.heatDetail)
    }

    // MARK: - Capture / import

    func ingestImage(_ image: UIImage, source: String) {
        guard let heatId = activeHeatId ?? state.heatPacks.first?.id else {
            flash("Create a heat pack first.", error: true)
            return
        }
        activeHeatId = heatId
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            flash("Could not encode finish strip.", error: true)
            return
        }
        let stripId = UUID().uuidString
        let url = mediaRoot.appendingPathComponent("\(stripId).jpg")
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            flash("Save failed: \(error.localizedDescription)", error: true)
            return
        }
        let strip = FinishStrip(
            id: stripId,
            heatPackId: heatId,
            source: source,
            localMediaURL: url.path,
            capturedAt: Date()
        )
        state.finishStrips.insert(strip, at: 0)
        activeStripId = stripId
        if laneMarks.isEmpty { laneMarks = [1, 2, 3, 4] }
        if timeChips.isEmpty { timeChips = [] }
        persist()
        if !path.contains(.slitScrubber) {
            push(.slitScrubber)
        }
        flash("Finish strip saved.")
    }

    func handlePhotoItemChange() {
        guard let item = selectedPhotoItem else { return }
        importGeneration += 1
        let gen = importGeneration
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    flash("Could not decode album strip.", error: true)
                    return
                }
                guard gen == importGeneration else { return }
                ingestImage(image, source: "photos")
            } catch {
                flash("Import failed: \(error.localizedDescription)", error: true)
            }
        }
    }

    func addTimeChip(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        timeChips.append(trimmed)
        seedDraftFromLocalChips()
    }

    func toggleLaneMark(_ lane: Int) {
        if let idx = laneMarks.firstIndex(of: lane) {
            laneMarks.remove(at: idx)
        } else {
            laneMarks.append(lane)
            laneMarks.sort()
        }
        seedDraftFromLocalChips()
    }

    func seedDraftFromLocalChips() {
        guard let heatId = activeHeatId, let stripId = activeStripId else { return }
        // Keep existing confirmed; refresh drafts from local UI seeds
        state.laneReads.removeAll { $0.heatPackId == heatId && $0.status == "draft" }
        for (idx, lane) in laneMarks.enumerated() {
            let time = idx < timeChips.count ? timeChips[idx] : ""
            let read = LaneRead(
                id: UUID().uuidString,
                heatPackId: heatId,
                finishStripId: stripId,
                laneNumber: lane,
                athleteLabel: "",
                timeRead: time,
                status: "draft",
                updatedAt: Date()
            )
            state.laneReads.append(read)
        }
        persist()
    }

    // MARK: - Consent

    func requestConsentThen(_ action: @escaping () -> Void) {
        if consentGate.state.granted {
            action()
            return
        }
        pendingAIAction = action
        showConsent = true
    }

    func dismissConsent() {
        showConsent = false
        pendingAIAction = nil
        flash("Local tools still work without AI send.", error: false)
    }

    func grantConsentAndContinue() {
        do {
            try consentGate.grant()
            consentGranted = true
            showConsent = false
            refreshAIAvailability()
            let action = pendingAIAction
            pendingAIAction = nil
            action?()
        } catch {
            flash("Consent save failed: \(error.localizedDescription)", error: true)
        }
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            state.settings.consentRevoked = true
            persist()
            refreshAIAvailability()
            flash("AI data sharing revoked. Outbound blocked.")
        } catch {
            flash("Revoke failed: \(error.localizedDescription)", error: true)
        }
    }

    private func assertAuthorized() throws {
        _ = try consentGate.permit()
    }

    // MARK: - AI read times

    func readTimes() {
        requestConsentThen { [weak self] in
            Task { await self?.performReadTimes() }
        }
    }

    private func performReadTimes() async {
        guard let key = apiKey() else {
            flash(aiUnavailableReason ?? "AI key unavailable.", error: true)
            // Local-only drafts already seeded
            push(.readingReview)
            return
        }
        guard let strip = activeStrip else {
            flash("No finish strip to read.", error: true)
            return
        }
        readBusy = true
        defer { readBusy = false }
        do {
            try assertAuthorized()
            let client = DeepSeekClient(apiKey: key, assertAuthorized: { [weak self] in
                try self?.assertAuthorized()
            })
            let desc = "slit scrub \(String(format: "%.2f", scrubPosition)) lanes \(laneMarks)"
            let payload = try await client.readTimes(
                stripDesc: desc,
                laneGuesses: laneMarks,
                athleteLabels: draftReads.map(\.athleteLabel),
                rawTimeReads: timeChips,
                priorLaneReads: priorLaneReadNotes,
                userFeedback: lastUserFeedback,
                speechTranscript: speechTranscript
            )
            guard let heatId = activeHeatId else { return }
            state.laneReads.removeAll { $0.heatPackId == heatId && $0.status == "draft" }
            for draft in payload.drafts {
                let read = LaneRead(
                    id: UUID().uuidString,
                    heatPackId: heatId,
                    finishStripId: strip.id,
                    laneNumber: draft.laneNumber,
                    athleteLabel: draft.athleteLabel,
                    timeRead: draft.timeRead,
                    status: "draft",
                    updatedAt: Date()
                )
                state.laneReads.append(read)
            }
            persist()
            push(.readingReview)
            flash("Lane drafts ready — Keep / Discard / Edit.")
        } catch {
            flash(error.localizedDescription, error: true)
            if draftReads.isEmpty { seedDraftFromLocalChips() }
            push(.readingReview)
        }
    }

    func keepRead(_ id: String) {
        guard let idx = state.laneReads.firstIndex(where: { $0.id == id }) else { return }
        state.laneReads[idx].status = "confirmed"
        state.laneReads[idx].updatedAt = Date()
        lastUserFeedback = "kept L\(state.laneReads[idx].laneNumber)"
        persist()
    }

    func discardRead(_ id: String) {
        guard let idx = state.laneReads.firstIndex(where: { $0.id == id }) else { return }
        state.laneReads[idx].status = "discarded"
        state.laneReads[idx].updatedAt = Date()
        lastUserFeedback = "discarded L\(state.laneReads[idx].laneNumber)"
        persist()
    }

    func beginEditRead(_ id: String) {
        guard let read = state.laneReads.first(where: { $0.id == id }) else { return }
        editingReadId = id
        editLaneDraft = "\(read.laneNumber)"
        editTimeDraft = read.timeRead
    }

    func applyEditRead() {
        guard let id = editingReadId,
              let idx = state.laneReads.firstIndex(where: { $0.id == id }) else { return }
        if let lane = Int(editLaneDraft) { state.laneReads[idx].laneNumber = lane }
        state.laneReads[idx].timeRead = editTimeDraft
        state.laneReads[idx].status = "confirmed"
        state.laneReads[idx].updatedAt = Date()
        lastUserFeedback = "edited L\(state.laneReads[idx].laneNumber) → \(editTimeDraft)"
        editingReadId = nil
        persist()
    }

    // MARK: - Coach chat

    func sendCoach() {
        let text = coachQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let heatId = activeHeatId else { return }
        let userTurn = CoachTurn(
            id: UUID().uuidString,
            heatPackId: heatId,
            role: "user",
            text: text,
            sttSource: !speechTranscript.isEmpty && speechTranscript == text,
            createdAt: Date()
        )
        state.coachTurns.append(userTurn)
        coachQuestion = ""
        persist()
        requestConsentThen { [weak self] in
            Task { await self?.performCoach(question: text) }
        }
    }

    private func performCoach(question: String) async {
        guard let heatId = activeHeatId else { return }
        guard let key = apiKey() else {
            let local = CoachTurn(
                id: UUID().uuidString,
                heatPackId: heatId,
                role: "coach",
                text: "Local-only: AI key unavailable. Confirmed lanes: \(priorLaneReadNotes.joined(separator: "; ")). Ask again after configuring DeepSeek.",
                createdAt: Date()
            )
            state.coachTurns.append(local)
            persist()
            flash(aiUnavailableReason ?? "AI unavailable.", error: true)
            return
        }
        coachBusy = true
        defer { coachBusy = false }
        do {
            try assertAuthorized()
            let client = DeepSeekClient(apiKey: key, assertAuthorized: { [weak self] in
                try self?.assertAuthorized()
            })
            let reply = try await client.coachHeat(
                heatQuestion: question,
                speechTranscript: speechTranscript,
                priorLaneReads: priorLaneReadNotes,
                userFeedback: lastUserFeedback
            )
            var text = reply.reply
            if !reply.heatOrderNote.isEmpty {
                text += "\nHeat order: \(reply.heatOrderNote)"
            }
            state.coachTurns.append(
                CoachTurn(id: UUID().uuidString, heatPackId: heatId, role: "coach", text: text, createdAt: Date())
            )
            if reply.heatOrderNote.lowercased().contains("start") || question.lowercased().contains("start") {
                ensureCallouts()
            }
            persist()
        } catch {
            state.coachTurns.append(
                CoachTurn(
                    id: UUID().uuidString,
                    heatPackId: heatId,
                    role: "coach",
                    text: "Coach blocked: \(error.localizedDescription)",
                    createdAt: Date()
                )
            )
            persist()
            flash(error.localizedDescription, error: true)
        }
    }

    func applySpeechToCoach() {
        let t = speechService.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        speechTranscript = t
        coachQuestion = t
        speechService.stop()
    }

    // MARK: - Finish card

    func buildFinishCardDraft() {
        guard let heatId = activeHeatId, let stripId = activeStripId else { return }
        let card = FinishCard(
            id: UUID().uuidString,
            heatPackId: heatId,
            finishStripId: stripId,
            laneNumbers: confirmedReads.map(\.laneNumber),
            timeChips: confirmedReads.map(\.timeRead),
            stripCropURL: activeStrip?.localMediaURL,
            status: "draft",
            updatedAt: Date()
        )
        state.finishCards.removeAll { $0.heatPackId == heatId && $0.status == "draft" }
        state.finishCards.insert(card, at: 0)
        activeCardId = card.id
        persist()
        push(.finishCard)
    }

    func keepCard() {
        guard let id = activeCardId,
              let idx = state.finishCards.firstIndex(where: { $0.id == id }) else { return }
        state.finishCards[idx].status = "confirmed"
        state.finishCards[idx].updatedAt = Date()
        persist()
        ensureCallouts()
        push(.calloutDeck)
        flash("Finish card kept.")
    }

    func discardCard() {
        guard let id = activeCardId,
              let idx = state.finishCards.firstIndex(where: { $0.id == id }) else { return }
        state.finishCards[idx].status = "discarded"
        state.finishCards[idx].updatedAt = Date()
        persist()
        flash("Card discarded.")
        popToHome()
    }

    // MARK: - Callouts / TTS

    func ensureCallouts() {
        guard let heatId = activeHeatId else { return }
        if heatCallouts.isEmpty {
            var cues: [CalloutCue] = [
                CalloutCue(id: UUID().uuidString, heatPackId: heatId, cueKind: "start", text: "On your marks. Set. Go.", sortIndex: 0)
            ]
            for (i, read) in confirmedReads.enumerated() {
                cues.append(
                    CalloutCue(
                        id: UUID().uuidString,
                        heatPackId: heatId,
                        cueKind: "time",
                        text: "Lane \(read.laneNumber), \(read.timeRead) seconds",
                        sortIndex: i + 1
                    )
                )
            }
            state.calloutCues.append(contentsOf: cues)
            persist()
        }
    }

    func playCallout(_ cue: CalloutCue) {
        tts.speak(cue.text)
        if let idx = state.calloutCues.firstIndex(where: { $0.id == cue.id }) {
            state.calloutCues[idx].spokenAt = Date()
            persist()
        }
    }

    func playStart() {
        ensureCallouts()
        if let start = heatCallouts.first(where: { $0.cueKind == "start" }) {
            playCallout(start)
        } else {
            tts.speak("On your marks. Set. Go.")
        }
    }

    func playTimes() {
        ensureCallouts()
        let times = heatCallouts.filter { $0.cueKind == "time" }
        if times.isEmpty {
            tts.speak("No confirmed times yet.")
            return
        }
        tts.speak(times.map(\.text).joined(separator: ". "))
        for cue in times {
            if let idx = state.calloutCues.firstIndex(where: { $0.id == cue.id }) {
                state.calloutCues[idx].spokenAt = Date()
            }
        }
        persist()
    }

    func openLegal(_ page: String) {
        legalPageName = page
        push(.legalPages)
    }
}
