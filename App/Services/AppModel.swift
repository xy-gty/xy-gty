import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import LuxCueDomain

@MainActor
final class AppModel: ObservableObject {
    @Published var state = LuxCueState()
    @Published var path: [LuxCueRoute] = []
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
    @Published var activeSessionId: String?
    @Published var selectedZone = "V"
    @Published var legalPageName = "privacy"
    @Published var draftCallouts: [String] = []
    @Published var editEVText = ""
    @Published var editZoneText = ""

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<LuxCueRoute>
    let tts = TTSPlayer()
    let speechService = SpeechRecognitionService()
    let voiceRecorder = VoiceNoteRecorder()

    private let meterStore: MeterStore
    private let supportRoot: URL
    private let photosRoot: URL
    private let audioRoot: URL
    private let keychain = LuxCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private var pendingAIAction: (() -> Void)?
    private var importGeneration = 0

    var activeSession: MeterSession? {
        guard let id = activeSessionId else { return state.sessions.first }
        return state.sessions.first(where: { $0.id == id })
    }

    var activeSpot: SpotReading? {
        guard let id = activeSession?.id else { return nil }
        return state.spotReadings.first(where: { $0.sessionId == id })
    }

    var activeExposure: ExposureID? {
        guard let id = activeSession?.id else { return nil }
        return state.exposureIDs.first(where: { $0.sessionId == id })
    }

    var activeDial: ZoneDialState? {
        guard let id = activeSession?.id else { return nil }
        return state.zoneDialStates.first(where: { $0.sessionId == id })
    }

    var activeCard: MeterCardAnnotation? {
        guard let id = activeSession?.id else { return nil }
        return state.meterCards.first(where: { $0.sessionId == id })
    }

    var activeCallout: SetCallout? {
        guard let id = activeSession?.id else { return nil }
        return state.setCallouts.first(where: { $0.sessionId == id })
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeSession?.id else { return [] }
        return state.coachTurns.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var evDisplay: String {
        if let exposure = activeExposure {
            return String(format: "%.1f", exposure.ev)
        }
        if let spot = activeSpot {
            return String(format: "%.1f", spot.evEstimate)
        }
        return "—.—"
    }

    var confirmedExposureNotes: [String] {
        state.sessions.filter { $0.status == "confirmed" }.compactMap { session in
            guard let exposure = state.exposureIDs.first(where: { $0.sessionId == session.id }) else { return nil }
            let zone = state.zoneDialStates.first(where: { $0.sessionId == session.id })?.selectedZone ?? "?"
            return "EV \(exposure.ev) \(exposure.aperture) \(exposure.shutter) ISO \(exposure.iso) zone:\(zone)"
        }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent(LuxCueStores.supportFolderName, isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        photosRoot = root.appendingPathComponent("photos", isDirectory: true)
        audioRoot = root.appendingPathComponent("audio", isDirectory: true)
        try? FileManager.default.createDirectory(at: photosRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: audioRoot, withIntermediateDirectories: true)

        meterStore = MeterStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: LuxCueNavigation.isValid
        )

        let consentURL = LuxCueStores.storeURL(directory: root, name: LuxCueStores.aiConsentLocal)
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
                Task { try? await LuxCueStores.consentKeychainStore().save(mirrorData) }
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
        state = (try? meterStore.load()) ?? LuxCueState()
        persist()
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = state.sessions.first?.id
        }
        if let dial = activeDial {
            selectedZone = dial.selectedZone
        }
    }

    func persist() {
        try? meterStore.save(state)
    }

    func refreshAIAvailability() {
        if apiKey() == nil {
            aiUnavailableReason = "AI not configured — local metering still works."
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

    func push(_ route: LuxCueRoute) {
        path.append(route)
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
            setBanner("Compliance banners stay on every meter / EV / zone / TTS surface.")
        }
        persist()
    }

    func selectZone(_ zone: String) {
        selectedZone = zone
        guard let sessionId = activeSessionId else { return }
        if let idx = state.zoneDialStates.firstIndex(where: { $0.sessionId == sessionId }) {
            state.zoneDialStates[idx].selectedZone = zone
        } else {
            state.zoneDialStates.append(
                ZoneDialState(sessionId: sessionId, selectedZone: zone)
            )
        }
        persist()
    }

    // MARK: - Capture / Import

    func saveImage(_ image: UIImage, source: String) {
        guard let data = image.jpegData(compressionQuality: 0.88) else {
            setBanner("Could not encode photo.", error: true)
            return
        }
        let id = UUID().uuidString
        let url = photosRoot.appendingPathComponent("\(id).jpg")
        do {
            try data.write(to: url, options: .atomic)
            let session = MeterSession(
                id: id,
                createdAt: Date(),
                source: source,
                status: "draft",
                sceneNote: nil,
                disclaimerAck: true
            )
            let luminance = Self.estimateEV(from: image)
            let spot = SpotReading(
                sessionId: id,
                evEstimate: luminance,
                luxHint: nil,
                zoneHint: selectedZone,
                crossX: 0.5,
                crossY: 0.5,
                capturedAt: Date(),
                photoLocalURL: url.path
            )
            state.sessions.insert(session, at: 0)
            state.spotReadings.removeAll { $0.sessionId == id }
            state.spotReadings.append(spot)
            state.zoneDialStates.removeAll { $0.sessionId == id }
            state.zoneDialStates.append(ZoneDialState(sessionId: id, selectedZone: selectedZone))
            activeSessionId = id
            persist()
            setBanner(source == "camera" ? "Spot / gray-card reading captured." : "Still imported for reverse exposure.")
            push(.exposureResult)
        } catch {
            setBanner("Save failed: \(error.localizedDescription)", error: true)
        }
    }

    private static func estimateEV(from image: UIImage) -> Double {
        guard let cg = image.cgImage else { return 8.0 }
        let width = min(cg.width, 32)
        let height = min(cg.height, 32)
        guard width > 0, height > 0 else { return 8.0 }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var data = [UInt8](repeating: 0, count: width * height * 4)
        guard let ctx = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return 8.0 }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        var sum = 0.0
        let count = Double(width * height)
        for i in stride(from: 0, to: data.count, by: 4) {
            let r = Double(data[i])
            let g = Double(data[i + 1])
            let b = Double(data[i + 2])
            sum += (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0
        }
        let luma = max(sum / count, 0.01)
        // Rough uncalibrated EV hint from luma — never claimed as lab calibration.
        return max(0, min(16, log2(luma * 64)))
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

    // MARK: - Exposure ID

    func requestIdentify() {
        guard activeSession != nil else { return }
        runWithConsent { [weak self] in
            Task { await self?.performIdentify() }
        }
    }

    private func performIdentify() async {
        guard let session = activeSession else { return }
        guard let key = apiKey() else {
            // Honest local draft when unconfigured — not a canned AI success.
            let spot = activeSpot
            let exposure = ExposureID(
                sessionId: session.id,
                ev: spot?.evEstimate ?? 8.0,
                aperture: "f/2.8",
                shutter: "1/125",
                iso: "200",
                confidence: 0.2,
                rationale: LuxCueComplianceCopy.ensureDisclaimers(
                    "AI not configured — local uncalibrated EV estimate only."
                ),
                complianceBanner: true
            )
            state.exposureIDs.removeAll { $0.sessionId == session.id }
            state.exposureIDs.append(exposure)
            if let idx = state.sessions.firstIndex(where: { $0.id == session.id }) {
                state.sessions[idx].status = "identified"
            }
            editEVText = String(format: "%.1f", exposure.ev)
            editZoneText = selectedZone
            persist()
            setBanner("AI not configured — local estimate shown. No canned AI success.", error: true)
            refreshAIAvailability()
            return
        }
        identifyBusy = true
        setBanner("Identifying exposure…")
        defer { identifyBusy = false }
        do {
            let permit = try consentGate.permit()
            let client = DeepSeekClient(apiKey: key) { [weak self] in
                guard let self else { throw DeepSeekClient.Failure.notAuthorized }
                try self.consentGate.validate(permit)
            }
            let photoName = activeSpot?.photoLocalURL.map { URL(fileURLWithPath: $0).lastPathComponent } ?? "none"
            let payload = try await client.identifyExposure(
                sessionId: session.id,
                photoDescriptor: "local_still:\(photoName)",
                zoneHint: selectedZone,
                confirmedNotes: confirmedExposureNotes,
                question: "Suggest EV aperture shutter ISO with zone advice"
            )
            try consentGate.validate(permit)

            let exposure = ExposureID(
                sessionId: session.id,
                ev: payload.ev,
                aperture: payload.aperture,
                shutter: payload.shutter,
                iso: payload.iso,
                confidence: payload.confidence,
                rationale: LuxCueComplianceCopy.ensureDisclaimers(payload.rationale),
                complianceBanner: true
            )
            state.exposureIDs.removeAll { $0.sessionId == session.id }
            state.exposureIDs.append(exposure)
            selectZone(payload.zoneHint.isEmpty ? selectedZone : payload.zoneHint)
            if let idx = state.sessions.firstIndex(where: { $0.id == session.id }) {
                state.sessions[idx].status = "identified"
                state.sessions[idx].disclaimerAck = true
            }
            editEVText = String(format: "%.1f", exposure.ev)
            editZoneText = selectedZone
            persist()
            setBanner(LuxCueComplianceCopy.ensureDisclaimers("Exposure ID ready."))
        } catch {
            setBanner(error.localizedDescription, error: true)
        }
    }

    func saveReading() {
        guard let session = activeSession,
              let idx = state.sessions.firstIndex(where: { $0.id == session.id }) else { return }
        if let ev = Double(editEVText),
           let eIdx = state.exposureIDs.firstIndex(where: { $0.sessionId == session.id }) {
            state.exposureIDs[eIdx].ev = ev
        }
        if !editZoneText.isEmpty {
            selectZone(editZoneText)
        }
        state.sessions[idx].status = "confirmed"
        state.sessions[idx].disclaimerAck = true
        persist()
        setBanner(LuxCueComplianceCopy.ensureDisclaimers("Reading saved for feedback reuse."))
    }

    func dismissID() {
        setBanner("Result dismissed — confirmed readings unchanged.")
    }

    func keepExposure() {
        saveReading()
    }

    func useExposure() {
        saveReading()
        push(.coachChat)
    }

    func openMeterCard() {
        guard let session = activeSession else { return }
        if let existing = activeCard {
            draftCallouts = existing.callouts
        } else if let exposure = activeExposure {
            draftCallouts = [
                "EV \(String(format: "%.1f", exposure.ev))",
                "\(exposure.aperture) · \(exposure.shutter) · ISO \(exposure.iso)",
                "Zone \(selectedZone)",
            ] + LuxCueCompliance.requiredDisclaimers
        } else {
            draftCallouts = LuxCueCompliance.requiredDisclaimers
        }
        push(.meterCard)
    }

    func keepMeterCard() {
        guard let session = activeSession, let spot = activeSpot else { return }
        let card = MeterCardAnnotation(
            sessionId: session.id,
            callouts: draftCallouts,
            imageLocalURL: spot.photoLocalURL ?? "",
            generatedAt: Date()
        )
        state.meterCards.removeAll { $0.sessionId == session.id }
        state.meterCards.append(card)
        persist()
        setBanner(LuxCueComplianceCopy.ensureDisclaimers("Meter card kept."))
        if path.last == .meterCard {
            path.removeLast()
            persistNavigation()
        }
    }

    func rejectMeterCardDraft() {
        draftCallouts = []
        setBanner("Draft callouts discarded — still kept.")
        if path.last == .meterCard {
            path.removeLast()
            persistNavigation()
        }
    }

    func playSetCallout() {
        guard let session = activeSession, let exposure = activeExposure else {
            setBanner("No exposure ID yet — Identify first.", error: true)
            return
        }
        guard state.settings.ttsEnabled else {
            setBanner("TTS disabled in Settings.", error: true)
            return
        }
        let script = LuxCueComplianceCopy.makeCalloutScript(exposure: exposure, zone: selectedZone)
        let callout = SetCallout(
            sessionId: session.id,
            scriptText: script,
            spokenAt: Date(),
            ttsLocale: "en-US"
        )
        state.setCallouts.removeAll { $0.sessionId == session.id }
        state.setCallouts.append(callout)
        persist()
        tts.speak(script)
        push(.setCallout)
    }

    // MARK: - Coach

    func sendCoachQuestion(sttSource: String? = nil) {
        let text = (sttSource == nil ? coachQuestion : speechTranscript)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let session = activeSession else { return }
        let userTurn = CoachTurn(
            sessionId: session.id,
            role: "user",
            text: text,
            strategy: "zone",
            sttSource: sttSource,
            createdAt: Date()
        )
        state.coachTurns.append(userTurn)
        persist()
        coachQuestion = ""
        runWithConsent { [weak self] in
            Task { await self?.performCoach(question: text, sessionId: session.id) }
        }
    }

    private func performCoach(question: String, sessionId: String) async {
        guard let key = apiKey() else {
            let local = CoachTurn(
                sessionId: sessionId,
                role: "coach",
                text: LuxCueComplianceCopy.localCoachTip(
                    question: question,
                    zone: selectedZone,
                    exposure: activeExposure
                ),
                strategy: "zone",
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
            let exposure = state.exposureIDs.first(where: { $0.sessionId == sessionId })
            let summary = [
                exposure.map { "EV \($0.ev)" },
                exposure?.aperture,
                exposure?.shutter,
                exposure.map { "ISO \($0.iso)" },
                "zone:\(selectedZone)",
            ].compactMap { $0 }.joined(separator: " ")
            let reply = try await client.coachZoneFilmDigital(
                sessionId: sessionId,
                question: question,
                sessionSummary: summary,
                confirmedNotes: confirmedExposureNotes
            )
            try consentGate.validate(permit)
            state.coachTurns.append(
                CoachTurn(
                    sessionId: sessionId,
                    role: "coach",
                    text: reply.reply,
                    strategy: reply.strategy,
                    sttSource: nil,
                    createdAt: Date()
                )
            )
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
            sessionId: activeSessionId,
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
        setBanner("Local metering still works without AI.")
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
