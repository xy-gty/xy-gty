import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import BloomkettleDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var state = BloomkettleState()
    @Published var path: [BloomkettleRoute] = []
    @Published var statusMessage: String?
    @Published var statusIsError = false
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var readBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var showCamera = false
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var aiUnavailableReason: String?
    @Published var activeSessionId: String?
    @Published var activeShotId: String?
    @Published var activeNoteId: String?
    @Published var legalPageName = "privacy"
    @Published var shotKind = "beans"
    @Published var grindChips = ["fine", "medium_fine", "medium", "medium_coarse", "coarse"]
    @Published var selectedGrind = "medium"
    @Published var nextPourGrams: Double = 60
    @Published var nextPourSeconds: Double = 30
    @Published var funnelSteps: [PourStep] = []
    @Published var editGramsDraft = ""
    @Published var editSecondsDraft = ""
    @Published var editingStepId: String?
    @Published var lastUserFeedback = ""

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<BloomkettleRoutePayload>
    let speechService = SpeechRecognitionService()

    private let brewStore: BrewStore
    private let supportRoot: URL
    private let mediaRoot: URL
    private let keychain = BloomkettleStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingAIAction: (() -> Void)?
    private var importGeneration = 0

    var activeSession: BrewSession? {
        guard let id = activeSessionId else { return state.sessions.first }
        return state.sessions.first(where: { $0.id == id })
    }

    var activeShot: BrewShot? {
        guard let id = activeShotId else {
            guard let sid = activeSession?.id else { return nil }
            return state.shots.first(where: { $0.sessionId == sid })
        }
        return state.shots.first(where: { $0.id == id })
    }

    var sessionSteps: [PourStep] {
        guard let id = activeSession?.id else { return [] }
        return state.pourSteps.filter { $0.sessionId == id }.sorted { $0.sortIndex < $1.sortIndex }
    }

    var draftSteps: [PourStep] {
        sessionSteps.filter { stepStatus($0) == "draft" }
    }

    var keptSteps: [PourStep] {
        // status is encoded in note prefix when needed; use grind/status via separate tracking
        sessionSteps
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeSession?.id else { return [] }
        return state.coachTurns.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var sessionNotes: [BrewNote] {
        guard let id = activeSession?.id else { return [] }
        return state.brewNotes.filter { $0.sessionId == id }
    }

    var sessionGrind: GrindPick? {
        guard let id = activeSession?.id else { return nil }
        return state.grindPicks.first(where: { $0.sessionId == id })
    }

    var priorPourNotes: [String] {
        sessionSteps.map { step in
            let g = step.targetGrams.map { String(format: "%.0f" , $0) } ?? "?"
            let s = step.targetSeconds.map { String(format: "%.0f" , $0) } ?? "?"
            return "\(step.kind)#\(step.pourIndex) \(g)g/\(s)s"
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("bloomkettle", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        mediaRoot = root.appendingPathComponent("media", isDirectory: true)
        try? FileManager.default.createDirectory(at: mediaRoot, withIntermediateDirectories: true)

        brewStore = BrewStore(directory: root)
        navigation = TypedNavigationStore(
            url: BloomkettleStores.storeURL(directory: root, name: BloomkettleStores.navigationFile),
            isValid: { BloomkettleRoute.allCases.contains($0.route) }
        )

        let consentURL = BloomkettleStores.storeURL(directory: root, name: BloomkettleStores.aiConsentLocal)
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
                Task { try? await BloomkettleStores.consentKeychainStore().save(mirrorData) }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        if ProcessInfo.processInfo.arguments.contains("-uitest-seed") {
            seedUITestSessionIfNeeded()
        }
        if let restored = try? navigation.restore(), !restored.isEmpty {
            path = restored.map(\.route)
            if let sid = restored.compactMap(\.sessionId).last {
                activeSessionId = sid
            }
            if let shot = restored.compactMap(\.shotId).last {
                activeShotId = shot
            }
        }
        syncFunnelFromState()
        Task { await self.loadAPIKeyFromKeychain() }
        refreshAIAvailability()
    }

    private func stepStatus(_ step: PourStep) -> String {
        if step.note.hasPrefix("status:") {
            return String(step.note.dropFirst("status:".count)).split(separator: "|").first.map(String.init) ?? "draft"
        }
        return "draft"
    }

    private func withStatus(_ step: PourStep, status: String) -> PourStep {
        var s = step
        let rest = step.note.replacingOccurrences(of: #"^status:[^|]*\|?"#, with: "", options: .regularExpression)
        s.note = "status:\(status)|\(rest)"
        return s
    }

    private func seedUITestSessionIfNeeded() {
        state = BloomkettleState()
        let sessionId = "uitest-session"
        let shotId = "uitest-shot"
        let image = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 320)).image { ctx in
            UIColor(red: 0.631, green: 0.384, blue: 0.027, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 320, height: 320))
            UIColor(red: 0.925, green: 0.992, blue: 0.961, alpha: 1).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 80, y: 60, width: 160, height: 200))
        }
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        let url = mediaRoot.appendingPathComponent("\(shotId).jpg")
        try? data.write(to: url, options: .atomic)
        let session = BrewSession(
            id: sessionId,
            title: "UITest V60",
            gearNote: "V60",
            complianceSnapshot: BloomkettleCompliance.bannerEN,
            createdAt: Date(),
            updatedAt: Date()
        )
        let shot = BrewShot(
            id: shotId,
            sessionId: sessionId,
            source: "photos",
            subject: "bloom",
            localMediaURL: url.path,
            capturedAt: Date()
        )
        state.sessions = [session]
        state.shots = [shot]
        state.pourSteps = [
            withStatus(PourStep(id: "p1", sessionId: sessionId, kind: "bloom", pourIndex: 0, targetGrams: 40, targetSeconds: 30, sortIndex: 0, note: ""), status: "draft"),
            withStatus(PourStep(id: "p2", sessionId: sessionId, kind: "pour", pourIndex: 1, targetGrams: 60, targetSeconds: 25, sortIndex: 1, note: ""), status: "draft"),
        ]
        state.grindPicks = [GrindPick(id: "g1", sessionId: sessionId, grind: "medium", updatedAt: Date())]
        selectedGrind = "medium"
        nextPourGrams = 60
        nextPourSeconds = 25
        activeSessionId = sessionId
        activeShotId = shotId
        persist()
        syncFunnelFromState()
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
        state = (try? brewStore.load()) ?? BloomkettleState()
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = state.sessions.first?.id
        }
        if let grind = sessionGrind {
            selectedGrind = grind.grind
        }
        syncFunnelFromState()
    }

    func persist() {
        try? brewStore.save(state)
        saveNavigation()
    }

    private func saveNavigation() {
        let payloads = path.map {
            BloomkettleRoutePayload(
                route: $0,
                sessionId: activeSessionId,
                shotId: activeShotId,
                brewNoteId: activeNoteId,
                legalPage: $0 == .legalPages ? legalPageName : nil
            )
        }
        try? navigation.save(payloads)
    }

    func syncFunnelFromState() {
        funnelSteps = sessionSteps
        if let next = sessionSteps.first(where: { stepStatus($0) != "kept" && stepStatus($0) != "discarded" })
            ?? sessionSteps.last {
            nextPourGrams = next.targetGrams ?? nextPourGrams
            nextPourSeconds = next.targetSeconds ?? nextPourSeconds
        }
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI unavailable / local-only — funnel, chips, and notes still work."
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

    func push(_ route: BloomkettleRoute) {
        path.append(route)
        saveNavigation()
    }

    func popToHome() {
        path.removeAll()
        saveNavigation()
    }

    func createSession(title: String = "Brew session") {
        let id = UUID().uuidString
        let session = BrewSession(
            id: id,
            title: title,
            gearNote: "",
            complianceSnapshot: BloomkettleCompliance.bannerEN,
            createdAt: Date(),
            updatedAt: Date()
        )
        state.sessions.insert(session, at: 0)
        activeSessionId = id
        persist()
        push(.captureImport)
    }

    func openSession(_ id: String) {
        activeSessionId = id
        if let shot = state.shots.first(where: { $0.sessionId == id }) {
            activeShotId = shot.id
        }
        if let grind = state.grindPicks.first(where: { $0.sessionId == id }) {
            selectedGrind = grind.grind
        }
        syncFunnelFromState()
        push(.sessionDetail)
    }

    func ingestImage(_ image: UIImage, source: String) {
        guard let sessionId = activeSessionId ?? state.sessions.first?.id else {
            flash("Create a brew session first.", error: true)
            return
        }
        activeSessionId = sessionId
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            flash("Could not encode brew shot.", error: true)
            return
        }
        let shotId = UUID().uuidString
        let url = mediaRoot.appendingPathComponent("\(shotId).jpg")
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            flash("Save failed: \(error.localizedDescription)", error: true)
            return
        }
        let shot = BrewShot(
            id: shotId,
            sessionId: sessionId,
            source: source,
            subject: shotKind,
            localMediaURL: url.path,
            capturedAt: Date()
        )
        state.shots.insert(shot, at: 0)
        activeShotId = shotId
        seedLocalPourDraftsIfNeeded()
        persist()
        syncFunnelFromState()
        if !path.contains(.funnelTimeline) {
            push(.funnelTimeline)
        }
        flash("Brew shot saved.")
    }

    func handlePhotoItemChange() {
        guard let item = selectedPhotoItem else { return }
        importGeneration += 1
        let gen = importGeneration
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    flash("Could not decode album shot.", error: true)
                    return
                }
                guard gen == importGeneration else { return }
                ingestImage(image, source: "photos")
            } catch {
                flash("Import failed: \(error.localizedDescription)", error: true)
            }
        }
    }

    func seedLocalPourDraftsIfNeeded() {
        guard let sessionId = activeSessionId else { return }
        if state.pourSteps.contains(where: { $0.sessionId == sessionId }) { return }
        let drafts = [
            PourStep(id: UUID().uuidString, sessionId: sessionId, kind: "bloom", pourIndex: 0, targetGrams: 40, targetSeconds: 30, sortIndex: 0),
            PourStep(id: UUID().uuidString, sessionId: sessionId, kind: "pour", pourIndex: 1, targetGrams: 60, targetSeconds: 25, sortIndex: 1),
            PourStep(id: UUID().uuidString, sessionId: sessionId, kind: "pour", pourIndex: 2, targetGrams: 80, targetSeconds: 30, sortIndex: 2),
            PourStep(id: UUID().uuidString, sessionId: sessionId, kind: "drawdown", pourIndex: 0, targetGrams: nil, targetSeconds: 45, sortIndex: 3),
        ].map { withStatus($0, status: "draft") }
        state.pourSteps.append(contentsOf: drafts)
        nextPourGrams = 60
        nextPourSeconds = 25
        selectGrind(selectedGrind)
    }

    func selectGrind(_ chip: String) {
        selectedGrind = chip
        guard let sessionId = activeSessionId else { return }
        if let idx = state.grindPicks.firstIndex(where: { $0.sessionId == sessionId }) {
            state.grindPicks[idx].grind = chip
            state.grindPicks[idx].updatedAt = Date()
        } else {
            state.grindPicks.append(GrindPick(id: UUID().uuidString, sessionId: sessionId, grind: chip, updatedAt: Date()))
        }
        persist()
    }

    func applyNextPourCard() {
        guard let sessionId = activeSessionId else { return }
        if let idx = state.pourSteps.firstIndex(where: { $0.sessionId == sessionId && stepStatus($0) == "draft" }) {
            state.pourSteps[idx].targetGrams = nextPourGrams
            state.pourSteps[idx].targetSeconds = nextPourSeconds
        } else {
            let step = withStatus(
                PourStep(
                    id: UUID().uuidString,
                    sessionId: sessionId,
                    kind: "pour",
                    pourIndex: sessionSteps.filter { $0.kind == "pour" }.count + 1,
                    targetGrams: nextPourGrams,
                    targetSeconds: nextPourSeconds,
                    sortIndex: sessionSteps.count
                ),
                status: "draft"
            )
            state.pourSteps.append(step)
        }
        persist()
        syncFunnelFromState()
        flash("Next-pour card updated.")
    }

    // MARK: Consent

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
        flash("Local funnel and notes still work without AI send.")
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

    // MARK: AI coach brew

    func coachThisBrew() {
        requestConsentThen { [weak self] in
            Task { await self?.performCoachBrew() }
        }
    }

    private func performCoachBrew() async {
        guard let sessionId = activeSessionId else { return }
        readBusy = true
        defer { readBusy = false }
        guard let key = apiKey() else {
            flash(aiUnavailableReason ?? "AI key unavailable.", error: true)
            if draftSteps.isEmpty { seedLocalPourDraftsIfNeeded() }
            push(.readingReview)
            return
        }
        do {
            try assertAuthorized()
            let client = DeepSeekClient(apiKey: key, assertAuthorized: { [weak self] in
                try self?.assertAuthorized()
            })
            let shot = activeShot
            let payload = try await client.coachBrew(
                shotDesc: shot.map { "\($0.subject) via \($0.source)" } ?? "brew shot",
                beanGuess: shot?.subject == "beans" ? "beans" : "",
                grindGuess: selectedGrind,
                bloomNote: sessionSteps.first(where: { $0.kind == "bloom" })?.note ?? "",
                pourGuesses: priorPourNotes,
                cremaNote: shot?.subject == "crema" ? "crema present" : "",
                brewQuestion: "Coach this pour-over",
                speechTranscript: speechTranscript,
                priorPourSteps: priorPourNotes,
                userFeedback: lastUserFeedback
            )
            state.pourSteps.removeAll { $0.sessionId == sessionId && stepStatus($0) == "draft" }
            for (idx, draft) in payload.steps.enumerated() {
                let step = withStatus(
                    PourStep(
                        id: UUID().uuidString,
                        sessionId: sessionId,
                        kind: draft.kind,
                        pourIndex: draft.pourIndex,
                        targetGrams: draft.targetGrams,
                        targetSeconds: draft.targetSeconds,
                        sortIndex: idx,
                        note: draft.note
                    ),
                    status: "draft"
                )
                state.pourSteps.append(step)
            }
            if let grind = payload.grind, !grind.isEmpty {
                selectGrind(grind)
            }
            persist()
            syncFunnelFromState()
            push(.readingReview)
            flash("Pour drafts ready — Keep / Discard / Edit.")
        } catch {
            flash(error.localizedDescription, error: true)
            if draftSteps.isEmpty { seedLocalPourDraftsIfNeeded() }
            push(.readingReview)
        }
    }

    func keepStep(_ id: String) {
        guard let idx = state.pourSteps.firstIndex(where: { $0.id == id }) else { return }
        state.pourSteps[idx] = withStatus(state.pourSteps[idx], status: "kept")
        lastUserFeedback = "kept \(state.pourSteps[idx].kind)#\(state.pourSteps[idx].pourIndex)"
        persist()
        syncFunnelFromState()
    }

    func discardStep(_ id: String) {
        guard let idx = state.pourSteps.firstIndex(where: { $0.id == id }) else { return }
        state.pourSteps[idx] = withStatus(state.pourSteps[idx], status: "discarded")
        lastUserFeedback = "discarded \(state.pourSteps[idx].kind)"
        persist()
        syncFunnelFromState()
    }

    func beginEditStep(_ id: String) {
        guard let step = state.pourSteps.first(where: { $0.id == id }) else { return }
        editingStepId = id
        editGramsDraft = step.targetGrams.map { String(format: "%.0f", $0) } ?? ""
        editSecondsDraft = step.targetSeconds.map { String(format: "%.0f", $0) } ?? ""
    }

    func applyEditStep() {
        guard let id = editingStepId,
              let idx = state.pourSteps.firstIndex(where: { $0.id == id }) else { return }
        if let g = Double(editGramsDraft) { state.pourSteps[idx].targetGrams = g }
        if let s = Double(editSecondsDraft) { state.pourSteps[idx].targetSeconds = s }
        state.pourSteps[idx] = withStatus(state.pourSteps[idx], status: "kept")
        lastUserFeedback = "edited step \(id)"
        editingStepId = nil
        persist()
        syncFunnelFromState()
    }

    func keepBrewNote() {
        guard let sessionId = activeSessionId else { return }
        let kept = sessionSteps.filter { stepStatus($0) == "kept" }
        let summary = kept.map { "\($0.kind) \($0.targetGrams.map { String(format: "%.0fg", $0) } ?? "")" }.joined(separator: " → ")
        let note = BrewNote(
            id: UUID().uuidString,
            sessionId: sessionId,
            ratioSummary: "1:\(Int((kept.map { $0.targetGrams ?? 0 }.reduce(0, +) / max(15, 1)).rounded())) approx",
            grindSummary: selectedGrind,
            stepSummary: summary.isEmpty ? "No kept steps yet" : summary,
            status: "confirmed",
            updatedAt: Date()
        )
        state.brewNotes.insert(note, at: 0)
        activeNoteId = note.id
        persist()
        push(.brewNote)
        flash("Brew note kept.")
    }

    func discardBrewNoteDraft() {
        flash("Brew note discarded — not persisted.")
        popToHome()
    }

    // MARK: Coach chat

    func sendCoach() {
        let text = coachQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let sessionId = activeSessionId else { return }
        let userTurn = CoachTurn(
            id: UUID().uuidString,
            sessionId: sessionId,
            role: "user",
            text: text,
            sttSource: !speechTranscript.isEmpty && speechTranscript == text,
            createdAt: Date()
        )
        state.coachTurns.append(userTurn)
        coachQuestion = ""
        persist()
        requestConsentThen { [weak self] in
            Task { await self?.performCoachChat(question: text) }
        }
    }

    private func performCoachChat(question: String) async {
        guard let sessionId = activeSessionId else { return }
        coachBusy = true
        defer { coachBusy = false }
        guard let key = apiKey() else {
            let local = CoachTurn(
                id: UUID().uuidString,
                sessionId: sessionId,
                role: "coach",
                text: "Local-only: AI key unavailable. Next pour \(String(format: "%.0f", nextPourGrams))g / \(String(format: "%.0f", nextPourSeconds))s · grind \(selectedGrind). Configure DeepSeek to continue.",
                createdAt: Date()
            )
            state.coachTurns.append(local)
            persist()
            flash(aiUnavailableReason ?? "AI unavailable.", error: true)
            return
        }
        do {
            try assertAuthorized()
            let client = DeepSeekClient(apiKey: key, assertAuthorized: { [weak self] in
                try self?.assertAuthorized()
            })
            let reply = try await client.coachChat(
                brewQuestion: question,
                speechTranscript: speechTranscript,
                priorPourSteps: priorPourNotes,
                userFeedback: lastUserFeedback,
                grindGuess: selectedGrind
            )
            state.coachTurns.append(
                CoachTurn(
                    id: UUID().uuidString,
                    sessionId: sessionId,
                    role: "coach",
                    text: reply.reply,
                    createdAt: Date()
                )
            )
            if let grams = reply.nextGrams { nextPourGrams = grams }
            if let secs = reply.nextSeconds { nextPourSeconds = secs }
            persist()
            syncFunnelFromState()
        } catch {
            flash(error.localizedDescription, error: true)
        }
    }

    func startSpeechCue() {
        Task {
            let status = await speechService.requestAuthorization()
            guard status == .authorized else {
                flash("Speech permission needed — open Settings.", error: true)
                return
            }
            speechService.start()
            if let err = speechService.lastError {
                flash(err, error: true)
            } else {
                flash("Listening for pour notes…")
            }
        }
    }

    func stopSpeechCue() {
        speechService.stop()
        speechTranscript = speechService.transcript
        if !speechTranscript.isEmpty {
            coachQuestion = speechTranscript
        }
    }

    func openLegal(_ page: String) {
        legalPageName = page
        push(.legalPages)
    }

    func openSettings() {
        push(.settings)
    }
}
