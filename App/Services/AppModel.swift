import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import PitchCueDomain

@MainActor
final class AppModel: ObservableObject {
    enum AppTab: Hashable {
        case practice, sessions, settings
    }

    @Published var sessions: [PracticeSession] = []
    @Published var photos: [SheetPhoto] = []
    @Published var plans: [PracticePlan] = []
    @Published var turns: [CoachTurn] = []
    @Published var beds: [AudioBed] = []
    @Published var pitchSamples: [PitchSample] = []

    @Published var activeSessionId: String?
    @Published var selectedTab: AppTab = .practice
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var coachBusy = false
    @Published var importBusy = false
    @Published var speechBusy = false
    @Published var instrumentLabel = "Instrument"
    @Published var userGoal = ""
    @Published var coachQuestion = ""
    @Published var speechTranscript = ""
    @Published var userFeedback = ""
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var pendingPlan: PracticePlan?
    @Published var pendingTurn: CoachTurn?
    @Published var editingStepsText = ""
    @Published var aiUnavailableReason: String?
    @Published var path: [PitchCueRoute] = []
    @Published var currentStepIndex = 0
    @Published var cameraImage: UIImage?

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<PitchCueRoute>
    let tts = TTSCoach()
    var audioBed = AudioBedEngine()
    let pitchDetector = PitchDetector()

    private let sessionsStore: AtomicCodableStore<[PracticeSession]>
    private let photosStore: AtomicCodableStore<[SheetPhoto]>
    private let plansStore: AtomicCodableStore<[PracticePlan]>
    private let turnsStore: AtomicCodableStore<[CoachTurn]>
    private let bedsStore: AtomicCodableStore<[AudioBed]>
    private let pitchStore: AtomicCodableStore<[PitchSample]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let keychain = PitchCueStores.apiKeyStore()
    private var cachedAPIKey: String?
    private let speechService = SpeechRecognitionService()
    private var pendingCoachAction: (() -> Void)?

    var activeSession: PracticeSession? {
        guard let id = activeSessionId else { return sessions.first }
        return sessions.first(where: { $0.id == id }) ?? sessions.first
    }

    var activePhoto: SheetPhoto? {
        guard let id = activeSession?.id else { return nil }
        return photos.first(where: { $0.sessionId == id })
    }

    var confirmedPlan: PracticePlan? {
        guard let id = activeSession?.id else { return nil }
        return plans.first(where: { $0.sessionId == id && $0.status == "confirmed" })
    }

    var sessionTurns: [CoachTurn] {
        guard let id = activeSession?.id else { return [] }
        return turns.filter { $0.sessionId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var planSteps: [String] {
        confirmedPlan?.steps ?? pendingPlan?.steps ?? []
    }

    var currentStepTitle: String {
        let steps = planSteps
        guard !steps.isEmpty else { return "No plan step" }
        let idx = min(max(currentStepIndex, 0), steps.count - 1)
        return Self.parseStep(steps[idx]).title
    }

    var currentStepTip: String {
        let steps = planSteps
        guard !steps.isEmpty else { return "" }
        let idx = min(max(currentStepIndex, 0), steps.count - 1)
        return Self.parseStep(steps[idx]).tip
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("PitchCue", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)

        sessionsStore = PitchCueStores.practiceSessionStore(directory: root)
        photosStore = PitchCueStores.sheetPhotoStore(directory: root)
        plansStore = PitchCueStores.practicePlanStore(directory: root)
        turnsStore = PitchCueStores.coachTurnStore(directory: root)
        bedsStore = PitchCueStores.audioBedStore(directory: root)
        pitchStore = PitchCueStores.pitchSampleStore(directory: root)
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = PitchCueStores.storeURL(directory: root, name: PitchCueStores.aiConsentLocal)
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
                    try? await PitchCueStores.consentKeychainStore().save(mirrorData)
                }
            }
        )
        consentGranted = consentGate.state.granted
        reload()
        if let restored = try? navigation.restore(), !restored.isEmpty {
            path = restored
        }
        Task { await self.loadAPIKeyFromKeychain() }
        refreshAIAvailability()
    }

    static func parseStep(_ raw: String) -> (title: String, duration: Int, tip: String) {
        let parts = raw.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)
        let title = parts.first ?? raw
        let duration = parts.count > 1 ? Int(parts[1]) ?? 60 : 60
        let tip = parts.count > 2 ? parts[2] : ""
        return (title, duration, tip)
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
        sessions = (try? sessionsStore.load()) ?? []
        photos = (try? photosStore.load()) ?? []
        plans = (try? plansStore.load()) ?? []
        turns = (try? turnsStore.load()) ?? []
        beds = (try? bedsStore.load()) ?? []
        pitchSamples = (try? pitchStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeSessionId == nil {
            activeSessionId = sessions.first?.id
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
        // Optional Secrets.xcconfig injection via Info.plist key presence only.
        return nil
    }

    func persistNavigation() {
        try? navigation.save(path)
    }

    func push(_ route: PitchCueRoute) {
        path.append(route)
        persistNavigation()
    }

    func createSession(title: String = "Practice session") {
        let session = PracticeSession(
            id: UUID().uuidString,
            title: title,
            instrumentLabel: instrumentLabel,
            updatedAt: Date(),
            freeAccessOpen: true
        )
        sessions.insert(session, at: 0)
        activeSessionId = session.id
        persistSessions()
        statusMessage = "Session created. Capture or import a sheet photo."
        push(.captureImport)
    }

    func selectSession(_ id: String) {
        activeSessionId = id
        selectedTab = .sessions
        push(.sessionDetail)
    }

    func importPhotoFromLibrary() async {
        guard let session = activeSession else {
            statusMessage = "Create a practice session first."
            return
        }
        importBusy = true
        defer { importBusy = false }
        do {
            let dest = importsRoot.appendingPathComponent("\(UUID().uuidString).jpg")
            let sessionImport = PhotoImportSession(destination: dest)
            let result = try await sessionImport.importSelection {
                guard let item = selectedPhotoItem else { return nil }
                return try await item.loadTransferable(type: Data.self)
            }
            switch result {
            case .imported(let url):
                let photo = SheetPhoto(
                    id: UUID().uuidString,
                    sessionId: session.id,
                    relativePath: url.lastPathComponent,
                    source: "library"
                )
                photos.removeAll { $0.sessionId == session.id }
                photos.append(photo)
                persistPhotos()
                touchSession(session.id)
                statusMessage = "Sheet imported. Ask the coach for a warm-up plan."
                push(.coachChat)
            case .cancelled:
                statusMessage = "Import cancelled."
            case .superseded:
                statusMessage = "Import superseded by a newer selection."
            }
        } catch {
            statusMessage = "Import failed: \(error.localizedDescription). Retry or pick another photo."
        }
    }

    func importCameraImage(_ image: UIImage) {
        guard let session = activeSession else {
            statusMessage = "Create a practice session first."
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            statusMessage = "Camera capture could not be encoded."
            return
        }
        let dest = importsRoot.appendingPathComponent("\(UUID().uuidString).jpg")
        do {
            try data.write(to: dest, options: .atomic)
            let photo = SheetPhoto(
                id: UUID().uuidString,
                sessionId: session.id,
                relativePath: dest.lastPathComponent,
                source: "camera"
            )
            photos.removeAll { $0.sessionId == session.id }
            photos.append(photo)
            persistPhotos()
            touchSession(session.id)
            statusMessage = "Sheet captured. Ask the coach for a warm-up plan."
            push(.coachChat)
        } catch {
            statusMessage = "Camera save failed: \(error.localizedDescription)"
        }
    }

    func photoFileURL(for photo: SheetPhoto) -> URL {
        importsRoot.appendingPathComponent(photo.relativePath)
    }

    func requestCoach() {
        guard activeSession != nil else {
            statusMessage = "Create a session first."
            return
        }
        if apiKey() == nil {
            statusMessage = aiUnavailableReason ?? "DeepSeek key not configured."
            // Local empty draft so user can still Edit a manual plan.
            seedLocalDraftIfNeeded()
            return
        }
        if !consentGate.state.granted {
            pendingCoachAction = { [weak self] in Task { await self?.runCoach() } }
            showConsent = true
            return
        }
        Task { await runCoach() }
    }

    private func seedLocalDraftIfNeeded() {
        guard let session = activeSession else { return }
        let draft = PracticePlan(
            id: UUID().uuidString,
            sessionId: session.id,
            steps: [
                "Long tones|90|Breathe slowly and center pitch",
                "Scale ladder|120|Even fingers, light tongue",
                "Excerpt loop|180|Isolate the hard bar",
            ],
            status: "draft",
            updatedAt: Date()
        )
        pendingPlan = draft
        editingStepsText = draft.steps.joined(separator: "\n")
        pendingTurn = CoachTurn(
            id: UUID().uuidString,
            sessionId: session.id,
            role: "coach",
            text: "AI is not configured — review this local draft, Edit, then Keep to practice offline.",
            feedbackMark: nil,
            createdAt: Date()
        )
        push(.planReview)
    }

    func grantConsentAndContinue() {
        do {
            try consentGate.grant()
            consentGranted = true
            showConsent = false
            refreshAIAvailability()
            let action = pendingCoachAction
            pendingCoachAction = nil
            action?()
        } catch {
            statusMessage = "Consent save failed: \(error.localizedDescription)"
        }
    }

    func dismissConsent() {
        showConsent = false
        pendingCoachAction = nil
        statusMessage = "AI send cancelled — consent not granted. Local practice still available."
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "AI consent revoked. Outbound coaching stopped."
        } catch {
            statusMessage = "Revoke failed: \(error.localizedDescription)"
        }
    }

    private func runCoach() async {
        guard let session = activeSession, let key = apiKey() else {
            statusMessage = aiUnavailableReason ?? "AI unavailable."
            seedLocalDraftIfNeeded()
            return
        }
        coachBusy = true
        defer { coachBusy = false }
        do {
            let permit = try consentGate.permit()
            try consentGate.validate(permit)
            let client = DeepSeekClient(apiKey: key) {
                try self.consentGate.permit()
                try self.consentGate.validate(permit)
            }
            let photoDesc: String
            if let photo = activePhoto {
                let url = photoFileURL(for: photo)
                if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                   let size = attrs[.size] as? NSNumber {
                    photoDesc = "file=\(photo.relativePath);bytes=\(size);source=\(photo.source)"
                } else {
                    photoDesc = "file=\(photo.relativePath);source=\(photo.source)"
                }
            } else {
                photoDesc = "no_photo"
            }
            let prior = confirmedPlan?.steps ?? []
            let userTurn = CoachTurn(
                id: UUID().uuidString,
                sessionId: session.id,
                role: "user",
                text: coachQuestion.isEmpty ? userGoal : coachQuestion,
                feedbackMark: userFeedback.isEmpty ? nil : userFeedback,
                createdAt: Date()
            )
            turns.append(userTurn)
            persistTurns()

            let result = try await client.coachPractice(
                sheetPhotoDesc: photoDesc,
                instrumentLabel: session.instrumentLabel,
                userGoal: userGoal,
                speechTranscript: speechTranscript,
                priorPlanSteps: prior,
                coachQuestion: coachQuestion,
                userFeedback: userFeedback,
                sessionId: session.id
            )
            pendingPlan = result.plan
            pendingTurn = result.turn
            editingStepsText = result.plan.steps.joined(separator: "\n")
            push(.planReview)
            statusMessage = "Coach draft ready — Keep, Discard, or Edit."
        } catch {
            statusMessage = "Coach failed: \(error.localizedDescription)"
        }
    }

    func keepPlanDraft() {
        guard let session = activeSession, var plan = pendingPlan else { return }
        let edited = editingStepsText
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if !edited.isEmpty {
            plan.steps = edited
        }
        plan.status = "confirmed"
        plan.updatedAt = Date()
        plans.removeAll { $0.sessionId == session.id }
        plans.append(plan)
        if let turn = pendingTurn {
            turns.append(turn)
            persistTurns()
        }
        persistPlans()
        pendingPlan = nil
        pendingTurn = nil
        currentStepIndex = 0
        touchSession(session.id)
        statusMessage = "Plan kept."
        push(.practiceFloor)
    }

    func discardPlanDraft() {
        pendingPlan = nil
        pendingTurn = nil
        statusMessage = "Plan draft discarded — nothing written."
        if !path.isEmpty { path.removeLast(); persistNavigation() }
    }

    func speakCountIn() {
        guard confirmedPlan != nil else {
            statusMessage = "Keep a practice plan before Count-in."
            return
        }
        tts.speakCountIn(then: currentStepTip)
        statusMessage = "Count-in playing."
    }

    func stopSpeech() {
        tts.stop()
    }

    func toggleAudioBed() {
        guard let session = activeSession else { return }
        if audioBed.isPlaying {
            audioBed.stop()
            statusMessage = "Audio bed stopped."
            return
        }
        audioBed.play()
        let bed = AudioBed(
            id: UUID().uuidString,
            sessionId: session.id,
            kind: audioBed.kind.rawValue,
            pitchHz: audioBed.kind == .drone ? audioBed.pitchHz : nil,
            bpm: audioBed.kind == .metronome ? audioBed.bpm : nil,
            waveformParams: ["level": 0.4]
        )
        beds.removeAll { $0.sessionId == session.id }
        beds.append(bed)
        persistBeds()
        statusMessage = "\(audioBed.kind.rawValue.capitalized) bed playing."
    }

    func startPitchCheck() {
        pitchDetector.start()
        push(.pitchFeedback)
    }

    func stopPitchCheckAndSample() {
        if let session = activeSession, pitchDetector.isListening {
            let sample = PitchSample(
                id: UUID().uuidString,
                sessionId: session.id,
                capturedAt: Date(),
                frequencyHz: pitchDetector.frequencyHz,
                centsOffset: pitchDetector.centsOffset
            )
            pitchSamples.append(sample)
            persistPitch()
        }
        pitchDetector.stop()
    }

    func captureSpeechGoal() async {
        speechBusy = true
        defer { speechBusy = false }
        do {
            let text = try await speechService.recognizeOnce(maxSeconds: 8)
            speechTranscript = text
            if userGoal.isEmpty {
                userGoal = text
            } else {
                userGoal += " " + text
            }
            statusMessage = "Speech captured into practice goal."
        } catch {
            statusMessage = "Speech failed: \(error.localizedDescription). You can still type."
        }
    }

    private func touchSession(_ id: String) {
        if let idx = sessions.firstIndex(where: { $0.id == id }) {
            sessions[idx].updatedAt = Date()
            sessions[idx].instrumentLabel = instrumentLabel
            persistSessions()
        }
    }

    private func persistSessions() { try? sessionsStore.save(sessions) }
    private func persistPhotos() { try? photosStore.save(photos) }
    private func persistPlans() { try? plansStore.save(plans) }
    private func persistTurns() { try? turnsStore.save(turns) }
    private func persistBeds() { try? bedsStore.save(beds) }
    private func persistPitch() { try? pitchStore.save(pitchSamples) }
}
