import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import RacknoteDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var state = RacknoteState()
    @Published var path: [RacknoteRoute] = []
    @Published var statusMessage: String?
    @Published var statusIsError = false
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var identifyBusy = false
    @Published var coachBusy = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var showCamera = false
    @Published var showVoiceNote = false
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var aiUnavailableReason: String?
    @Published var activeBottleId: String?
    @Published var selectedBinId: String?
    @Published var legalPageName = "privacy"
    @Published var captureSubject = "label"
    @Published var draftCallouts: [String] = []

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<RacknoteRoute>
    let tts = TTSPlayer()
    let speechService = SpeechRecognitionService()
    let voiceRecorder = VoiceNoteRecorder()

    private let cellarStore: CellarStore
    private let supportRoot: URL
    private let photosRoot: URL
    private let audioRoot: URL
    private let keychain = RacknoteStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingAIAction: (() -> Void)?
    private var importGeneration = 0

    var activeBottle: BottleEntry? {
        guard let id = activeBottleId else { return state.bottles.first }
        return state.bottles.first(where: { $0.id == id })
    }

    var activeOCR: LabelOCRResult? {
        guard let id = activeBottle?.id else { return nil }
        return state.labelResults.first(where: { $0.bottleId == id })
    }

    var activeWindow: DrinkingWindow? {
        guard let id = activeBottle?.id else { return nil }
        return state.drinkingWindows.first(where: { $0.bottleId == id })
    }

    var activeRackCard: RackCardAnnotation? {
        guard let id = activeBottle?.id else { return nil }
        return state.rackCards.first(where: { $0.bottleId == id })
    }

    var activeBrief: PullBrief? {
        guard let id = activeBottle?.id else { return nil }
        return state.pullBriefs.first(where: { $0.bottleId == id })
    }

    var bottleTurns: [CoachTurn] {
        guard let id = activeBottle?.id else { return [] }
        return state.coachTurns.filter { $0.bottleId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var bottlesByBin: [String: BottleEntry] {
        Dictionary(uniqueKeysWithValues: state.bottles.map { ($0.binId, $0) })
    }

    var confirmedBottleNotes: [String] {
        state.bottles.filter { $0.status == "confirmed" }.map { bottle in
            let bits = [bottle.producer, bottle.vintage, bottle.varietal, "bin:\(bottle.binId)"]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
            return bits.joined(separator: " ")
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent(RacknoteStores.mediaDirectoryName, isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        photosRoot = root.appendingPathComponent("photos", isDirectory: true)
        audioRoot = root.appendingPathComponent("audio", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: audioRoot, withIntermediateDirectories: true)

        cellarStore = CellarStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: RacknoteNavigation.isValid
        )

        let consentURL = RacknoteStores.storeURL(directory: root, name: RacknoteStores.aiConsentLocal)
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
                Task { try? await RacknoteStores.consentKeychainStore().save(mirrorData) }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        let uiSmokeReset = ProcessInfo.processInfo.arguments.contains("-ui-smoke-reset")
        if uiSmokeReset {
            path = []
            try? navigation.save([])
        } else if let restored = try? navigation.restore(), !restored.isEmpty {
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
        state = (try? cellarStore.load()) ?? RacknoteState()
        CellarComplianceCopy.ensureDefaultRack(state: &state)
        persist()
        consentGranted = consentGate.state.granted
        if activeBottleId == nil {
            activeBottleId = state.bottles.first?.id
        }
        if selectedBinId == nil {
            selectedBinId = state.bins.first?.id
        }
    }

    func persist() {
        try? cellarStore.save(state)
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI not configured — local capture still works."
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

    func push(_ route: RacknoteRoute) {
        path.append(route)
        persistNavigation()
    }

    func popToHome() {
        path.removeAll()
        persistNavigation()
    }

    func setBanner(_ text: String, error: Bool = false) {
        statusMessage = text
        statusIsError = error
    }

    func setTTSEnabled(_ enabled: Bool) {
        state.settings.ttsEnabled = enabled
        persist()
    }

    func setSpeechEnabled(_ enabled: Bool) {
        state.settings.speechInputEnabled = enabled
        persist()
    }

    func setAlwaysShowCompliance(_ enabled: Bool) {
        state.settings.alwaysShowComplianceBanner = true
        if !enabled {
            setBanner("Compliance banners stay on every alcohol-advice surface.", error: false)
        }
        persist()
    }

    func acknowledgeAgeGate() {
        state.settings.ageGateAcknowledged = true
        persist()
    }

    func selectBin(_ bin: CellarBin) {
        selectedBinId = bin.id
        if let bottle = bottlesByBin[bin.id] {
            activeBottleId = bottle.id
        }
    }

    // MARK: - Capture / Import

    func saveImage(_ image: UIImage, source: String) {
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            setBanner("Could not encode photo.", error: true)
            return
        }
        CellarComplianceCopy.ensureDefaultRack(state: &state)
        let binId = selectedBinId ?? state.bins.first?.id ?? "R1-B1"
        selectedBinId = binId
        let id = UUID().uuidString
        let url = photosRoot.appendingPathComponent("\(id).jpg")
        do {
            try data.write(to: url, options: .atomic)
            let bottle = BottleEntry(
                id: id,
                binId: binId,
                createdAt: Date(),
                photoLocalURL: url.path,
                source: source,
                status: "draft",
                disclaimerAck: true,
                ageGateAck: state.settings.ageGateAcknowledged
            )
            state.bottles.insert(bottle, at: 0)
            activeBottleId = id
            persist()
            setBanner(source == "camera" ? "Label/cork/bin-tag captured." : "Cellar still imported.")
            push(.labelResult)
        } catch {
            setBanner("Save failed: \(error.localizedDescription)", error: true)
        }
    }

    func handleCameraImage(_ image: UIImage) {
        showCamera = false
        saveImage(image, source: "camera")
    }

    func handlePhotoImport() {
        guard let item = selectedPhotoItem else { return }
        importGeneration += 1
        let generation = importGeneration
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    setBanner("Could not decode album still.", error: true)
                    return
                }
                guard generation == importGeneration else {
                    setBanner("Late picker result rejected after cancel.")
                    return
                }
                saveImage(image, source: "photos")
            } catch {
                setBanner("Import failed: \(error.localizedDescription)", error: true)
            }
            selectedPhotoItem = nil
        }
    }

    func cancelPhotoImport() {
        importGeneration += 1
        selectedPhotoItem = nil
    }

    // MARK: - Identify / OCR

    func requestIdentify() {
        guard activeBottle != nil else { return }
        runWithConsent { [weak self] in
            Task { await self?.performIdentify() }
        }
    }

    private func performIdentify() async {
        guard let bottle = activeBottle else { return }
        guard let key = apiKey() else {
            setBanner("AI not configured — local capture still works. No canned OCR.", error: true)
            refreshAIAvailability()
            return
        }
        identifyBusy = true
        setBanner("Reading label…")
        defer { identifyBusy = false }
        do {
            let permit = try consentGate.permit()
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                try self.consentGate.validate(permit)
            }
            let descriptor = "local_label_still:\(URL(fileURLWithPath: bottle.photoLocalURL).lastPathComponent)"
            let payload = try await client.identifyLabel(
                bottleId: bottle.id,
                photoDescriptor: descriptor,
                captureSubject: captureSubject,
                confirmedNotes: confirmedBottleNotes,
                question: "Identify wine label fields and suggest bin + drinking window"
            )
            try consentGate.validate(permit)

            if let suggested = payload.suggestedBinLabel,
               state.bins.contains(where: { $0.label == suggested || $0.id == suggested }) {
                if let idx = state.bottles.firstIndex(where: { $0.id == bottle.id }) {
                    state.bottles[idx].binId = suggested
                }
                selectedBinId = suggested
            }

            if let idx = state.bottles.firstIndex(where: { $0.id == bottle.id }) {
                state.bottles[idx].producer = payload.producer
                state.bottles[idx].vintage = payload.vintage
                state.bottles[idx].varietal = payload.varietal
                state.bottles[idx].region = payload.region
                state.bottles[idx].status = "identified"
                state.bottles[idx].disclaimerAck = true
                state.bottles[idx].ageGateAck = true
            }

            let ocr = LabelOCRResult(
                bottleId: bottle.id,
                rawText: payload.rawText,
                structuredFields: [
                    "producer": payload.producer,
                    "vintage": payload.vintage,
                    "varietal": payload.varietal,
                    "region": payload.region,
                ],
                confidence: payload.confidence
            )
            state.labelResults.removeAll { $0.bottleId == bottle.id }
            state.labelResults.append(ocr)

            var window = CellarComplianceCopy.defaultTimeline(for: bottle.id, vintage: payload.vintage)
            if !payload.timelinePoints.isEmpty {
                window.timelinePoints = payload.timelinePoints
            }
            window.status = payload.windowStatus
            state.drinkingWindows.removeAll { $0.bottleId == bottle.id }
            state.drinkingWindows.append(window)

            let updated = state.bottles.first(where: { $0.id == bottle.id }) ?? bottle
            let binLabel = state.bins.first(where: { $0.id == updated.binId })?.label ?? updated.binId
            let brief = CellarComplianceCopy.makePullBriefScript(
                bottle: updated,
                binLabel: binLabel,
                windowStatus: window.status
            )
            state.pullBriefs.removeAll { $0.bottleId == bottle.id }
            state.pullBriefs.append(brief)

            persist()
            setBanner(payload.coachTip)
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func saveBottle() {
        guard let bottle = activeBottle,
              let idx = state.bottles.firstIndex(where: { $0.id == bottle.id }) else { return }
        state.bottles[idx].status = "confirmed"
        state.bottles[idx].disclaimerAck = true
        state.bottles[idx].ageGateAck = true
        state.settings.ageGateAcknowledged = true
        persist()
        setBanner(
            CellarComplianceCopy.ensureDisclaimers("Bottle saved for feedback reuse.")
        )
    }

    func dismissID() {
        setBanner("Result dismissed — confirmed bottles unchanged.")
    }

    func openRackCard() {
        guard let bottle = activeBottle else { return }
        if let existing = activeRackCard {
            draftCallouts = existing.callouts
        } else {
            let bin = state.bins.first(where: { $0.id == bottle.binId })?.label ?? bottle.binId
            draftCallouts = [
                "Pull from \(bin)",
                "\(bottle.producer ?? "Bottle") · \(bottle.vintage ?? "")",
                "Window: \(activeWindow?.status ?? "unknown")",
                RacknoteCompliance.sommelierCertificationDisclaimer,
                RacknoteCompliance.investmentAdviceDisclaimer,
                RacknoteCompliance.ageGateLabel,
            ]
        }
        push(.rackCard)
    }

    func keepRackCard() {
        guard let bottle = activeBottle else { return }
        let card = RackCardAnnotation(
            bottleId: bottle.id,
            callouts: draftCallouts,
            imageLocalURL: bottle.photoLocalURL,
            generatedAt: Date()
        )
        state.rackCards.removeAll { $0.bottleId == bottle.id }
        state.rackCards.append(card)
        persist()
        setBanner(CellarComplianceCopy.ensureDisclaimers("Rack card kept."))
        if path.last == .rackCard {
            path.removeLast()
            persistNavigation()
        }
    }

    func rejectRackCardDraft() {
        draftCallouts = []
        setBanner("Draft callouts discarded — bottle photo kept.")
        if path.last == .rackCard {
            path.removeLast()
            persistNavigation()
        }
    }

    func playPullBrief() {
        guard let brief = activeBrief else {
            setBanner("No pull brief yet — Identify first.", error: true)
            return
        }
        guard state.settings.ttsEnabled else {
            setBanner("TTS disabled in Settings.", error: true)
            return
        }
        if let idx = state.pullBriefs.firstIndex(where: { $0.bottleId == brief.bottleId }) {
            state.pullBriefs[idx].spokenAt = Date()
            persist()
        }
        tts.speak(brief.scriptText)
        push(.pullBrief)
    }

    // MARK: - Coach

    func sendCoachQuestion(sttSource: String? = nil) {
        let text = (sttSource == nil ? coachQuestion : speechTranscript)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let bottle = activeBottle else { return }
        let userTurn = CoachTurn(
            bottleId: bottle.id,
            role: "user",
            text: text,
            sttSource: sttSource,
            createdAt: Date()
        )
        state.coachTurns.append(userTurn)
        persist()
        coachQuestion = ""
        runWithConsent { [weak self] in
            Task { await self?.performCoach(question: text, bottleId: bottle.id) }
        }
    }

    private func performCoach(question: String, bottleId: String) async {
        guard let key = apiKey() else {
            let local = CoachTurn(
                bottleId: bottleId,
                role: "coach",
                text: CellarComplianceCopy.ensureDisclaimers(
                    "AI not configured. Ask drinking-window and pairing questions locally — never treat this as certified tasting or investment advice."
                ),
                sttSource: nil,
                createdAt: Date()
            )
            state.coachTurns.append(local)
            persist()
            setBanner("Local coach tip (no AI key).", error: true)
            return
        }
        coachBusy = true
        defer { coachBusy = false }
        do {
            let permit = try consentGate.permit()
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                try self.consentGate.validate(permit)
            }
            let bottle = state.bottles.first(where: { $0.id == bottleId })
            let summary = [
                bottle?.producer,
                bottle?.vintage,
                bottle?.varietal,
                bottle.map { "bin:\($0.binId)" },
            ].compactMap { $0 }.joined(separator: " ")
            let reply = try await client.coachWindowPairing(
                bottleId: bottleId,
                question: question,
                bottleSummary: summary,
                confirmedNotes: confirmedBottleNotes
            )
            try consentGate.validate(permit)
            state.coachTurns.append(
                CoachTurn(
                    bottleId: bottleId,
                    role: "coach",
                    text: reply.reply,
                    sttSource: nil,
                    createdAt: Date()
                )
            )
            if let dish = reply.pairingDish, !dish.isEmpty {
                state.pairingNotes.append(
                    PairingNote(
                        bottleId: bottleId,
                        dish: dish,
                        rationale: reply.pairingRationale ?? "",
                        informationalOnly: true
                    )
                )
            }
            persist()
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func startSpeechQuestion() {
        guard state.settings.speechInputEnabled else {
            setBanner("Speech input disabled in Settings.", error: true)
            return
        }
        Task {
            let status = await speechService.requestAuthorization()
            guard status == .authorized else {
                setBanner("Speech denied — typed chat still works.", error: true)
                return
            }
            speechService.transcript = ""
            speechService.start()
        }
    }

    func finishSpeechQuestion() {
        speechService.stop()
        speechTranscript = speechService.transcript
        if !speechTranscript.isEmpty {
            sendCoachQuestion(sttSource: "speech")
        }
    }

    // MARK: - Voice notes

    func startVoiceNote() {
        voiceRecorder.start(to: audioRoot)
    }

    func stopVoiceNote() {
        guard let url = voiceRecorder.stop() else { return }
        let note = VoiceNote(
            bottleId: activeBottleId,
            binId: selectedBinId,
            localAudioURL: url.path,
            transcript: nil,
            createdAt: Date()
        )
        state.voiceNotes.insert(note, at: 0)
        persist()
        setBanner("Voice note saved.")
        showVoiceNote = false
    }

    // MARK: - Consent

    func runWithConsent(_ action: @escaping () -> Void) {
        refreshAIAvailability()
        if consentGate.state.granted {
            action()
            return
        }
        pendingAIAction = action
        showConsent = true
    }

    func grantConsentAndContinue() {
        do {
            try consentGate.grant()
            consentGranted = true
            state.settings.consentRevoked = false
            persist()
            showConsent = false
            refreshAIAvailability()
            let pending = pendingAIAction
            pendingAIAction = nil
            pending?()
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func dismissConsent() {
        showConsent = false
        pendingAIAction = nil
        setBanner("Local capture still works without AI.", error: false)
        refreshAIAvailability()
    }

    func revokeAIConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            state.settings.consentRevoked = true
            persist()
            refreshAIAvailability()
            setBanner("AI consent revoked — outbound stopped.", error: true)
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func openLegal(_ page: String) {
        legalPageName = page
        push(.legal)
    }
}
