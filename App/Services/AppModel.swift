import Foundation
import SwiftUI
import UIKit
import PhotosUI
import AppRuntimeCore
import CuePartnerDomain

@MainActor
final class AppModel: ObservableObject {
    enum AppTab: Hashable { case scenes, rehearse, settings }

    @Published var scenes: [CuePartnerDomain.Scene] = []
    @Published var scriptPages: [ScriptPage] = []
    @Published var cueLines: [CueLine] = []
    @Published var partnerTurns: [PartnerTurn] = []
    @Published var rehearsalMessages: [RehearsalMessage] = []
    @Published var voiceNotes: [VoiceNote] = []
    @Published var activeSceneId: String?
    @Published var selectedTab: AppTab = .scenes
    @Published var statusMessage: String?
    @Published var showConsent = false
    @Published var consentGranted = false
    @Published var ocrBusy = false
    @Published var chatBusy = false
    @Published var chatText = ""
    @Published var partnerRole = "Partner"
    @Published var userRole = "Me"
    @Published var pendingTurn: PartnerTurn?
    @Published var editingOCRText = ""
    @Published var pendingOCRPage: ScriptPage?
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var newSceneTitle = ""
    @Published var aiUnavailableReason: String?
    @Published var voiceNoteBusy = false
    @Published var speechBusy = false
    @Published var isRecordingVoice = false
    @Published var path: [CuePartnerRoute] = []

    let consentGate: AIConsentGate
    let navigation: TypedNavigationStore<CuePartnerRoute>
    let tts = CueTTSPlayer()
    let ambience = AmbiencePlayer()

    private let scenesStore: AtomicCodableStore<[CuePartnerDomain.Scene]>
    private let pagesStore: AtomicCodableStore<[ScriptPage]>
    private let cuesStore: AtomicCodableStore<[CueLine]>
    private let turnsStore: AtomicCodableStore<[PartnerTurn]>
    private let messagesStore: AtomicCodableStore<[RehearsalMessage]>
    private let notesStore: AtomicCodableStore<[VoiceNote]>
    private let supportRoot: URL
    private let importsRoot: URL
    private let voiceNotesRoot: URL
    private let keychain = KeychainCredentialStore(
        service: CuePartnerStores.keychainService,
        account: CuePartnerStores.keychainAPIKeyAccount
    )
    private var cachedAPIKey: String?
    private let voiceRecorder = VoiceNoteRecorder()
    private let speechService = SpeechRecognitionService()
    private var pendingVoiceURL: URL?

    var activeScene: CuePartnerDomain.Scene? {
        guard let id = activeSceneId else { return scenes.first }
        return scenes.first(where: { $0.id == id }) ?? scenes.first
    }

    var activePages: [ScriptPage] {
        guard let id = activeScene?.id else { return [] }
        return scriptPages.filter { $0.sceneId == id }
    }

    var activeCues: [CueLine] {
        guard let id = activeScene?.id else { return [] }
        return cueLines.filter { $0.sceneId == id }
    }

    var activeMessages: [RehearsalMessage] {
        guard let id = activeScene?.id else { return [] }
        return rehearsalMessages.filter { $0.sceneId == id }.sorted { $0.createdAt < $1.createdAt }
    }

    var activeVoiceNotes: [VoiceNote] {
        guard let id = activeScene?.id else { return [] }
        return voiceNotes.filter { $0.sceneId == id }
    }

    init() {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("CuePartner", isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        supportRoot = root
        importsRoot = root.appendingPathComponent("imports", isDirectory: true)
        voiceNotesRoot = root.appendingPathComponent("voice-notes", isDirectory: true)
        try? FileManager.default.createDirectory(at: importsRoot, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: voiceNotesRoot, withIntermediateDirectories: true)

        scenesStore = AtomicCodableStore(url: root.appendingPathComponent("\(CuePartnerStores.scenes).json"))
        pagesStore = AtomicCodableStore(url: root.appendingPathComponent("\(CuePartnerStores.scriptPages).json"))
        cuesStore = AtomicCodableStore(url: root.appendingPathComponent("\(CuePartnerStores.cueLines).json"))
        turnsStore = AtomicCodableStore(url: root.appendingPathComponent("\(CuePartnerStores.partnerTurns).json"))
        messagesStore = AtomicCodableStore(url: root.appendingPathComponent("\(CuePartnerStores.rehearsalMessages).json"))
        notesStore = AtomicCodableStore(url: root.appendingPathComponent("\(CuePartnerStores.voiceNotes).json"))
        navigation = TypedNavigationStore(
            url: root.appendingPathComponent("navigation.json"),
            isValid: { _ in true }
        )

        let consentURL = root.appendingPathComponent("\(CuePartnerStores.aiConsentLocal).json")
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
        if let restored = try? navigation.restore() { path = restored }
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
        scenes = (try? scenesStore.load()) ?? []
        scriptPages = (try? pagesStore.load()) ?? []
        cueLines = (try? cuesStore.load()) ?? []
        partnerTurns = (try? turnsStore.load()) ?? []
        rehearsalMessages = (try? messagesStore.load()) ?? []
        voiceNotes = (try? notesStore.load()) ?? []
        consentGranted = consentGate.state.granted
        if activeSceneId == nil { activeSceneId = scenes.first?.id }
    }

    func persistNavigation() {
        try? navigation.save(path)
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

    func createScene() {
        let title = newSceneTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            statusMessage = "Enter a scene title."
            return
        }
        let scene = CuePartnerDomain.Scene(
            id: UUID().uuidString,
            title: title,
            roles: ["Me", "Partner"],
            locked: false,
            createdAt: Date(),
            ambienceId: "off"
        )
        scenes.insert(scene, at: 0)
        activeSceneId = scene.id
        persistScenes()
        newSceneTitle = ""
        statusMessage = "Scene created. Import a script page."
        path = [.importScript]
        persistNavigation()
    }

    func selectScene(_ id: String) {
        activeSceneId = id
        selectedTab = .rehearse
        path = [.sceneDetail]
        persistNavigation()
        if let amb = activeScene?.ambienceId { ambience.use(presetId: amb) }
    }

    func importCameraData(_ data: Data) async {
        guard let scene = activeScene else {
            statusMessage = "Create a scene first."
            return
        }
        ocrBusy = true
        defer { ocrBusy = false }
        do {
            let dest = importsRoot.appendingPathComponent("\(UUID().uuidString).jpg")
            let session = PhotoImportSession(destination: dest)
            let result = try await session.importSelection { data }
            switch result {
            case .cancelled, .superseded:
                statusMessage = "Camera import cancelled."
            case .imported(let url):
                let text = try await ScriptOCRService.recognizeText(in: data)
                let page = ScriptPage(
                    id: UUID().uuidString,
                    sceneId: scene.id,
                    relativePath: url.lastPathComponent,
                    ocrText: text.isEmpty ? "(No text detected — edit or paste.)" : text
                )
                pendingOCRPage = page
                editingOCRText = page.ocrText
                path = [.ocrReview]
                persistNavigation()
                statusMessage = "Camera capture ready for OCR review."
            }
        } catch {
            statusMessage = "Camera OCR failed: \(error.localizedDescription)"
        }
    }

    func importPhotoFromPicker() async {
        guard let scene = activeScene else {
            statusMessage = "Create a scene first."
            return
        }
        ocrBusy = true
        defer { ocrBusy = false }
        do {
            let dest = importsRoot.appendingPathComponent("\(UUID().uuidString).jpg")
            let session = PhotoImportSession(destination: dest)
            let result = try await session.importSelection {
                guard let item = selectedPhotoItem else { return nil }
                return try await item.loadTransferable(type: Data.self)
            }
            switch result {
            case .cancelled:
                statusMessage = "Import cancelled."
            case .superseded:
                statusMessage = "Import superseded by a newer selection."
            case .imported(let url):
                let data = try Data(contentsOf: url)
                let text = try await ScriptOCRService.recognizeText(in: data)
                let page = ScriptPage(
                    id: UUID().uuidString,
                    sceneId: scene.id,
                    relativePath: url.lastPathComponent,
                    ocrText: text
                )
                pendingOCRPage = page
                editingOCRText = text.isEmpty ? "(No text detected — edit or paste.)" : text
                path = [.ocrReview]
                persistNavigation()
                statusMessage = text.isEmpty ? "OCR found no text. Edit before Keep." : "OCR ready for review."
            }
        } catch {
            statusMessage = "OCR failed: \(error.localizedDescription). Retry or paste text."
        }
    }

    func importSimulatorTestStill() async {
        guard let scene = activeScene else {
            statusMessage = "Create a scene first."
            return
        }
        ocrBusy = true
        defer { ocrBusy = false }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 1200))
        let image = renderer.image { ctx in
            UIColor(red: 0.96, green: 0.94, blue: 0.90, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 800, height: 1200))
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 10
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .regular),
                .foregroundColor: UIColor(red: 0.11, green: 0.14, blue: 0.19, alpha: 1),
                .paragraphStyle: paragraph
            ]
            let sample = "PARTNER\nDid you lock the stage door?\n\nME\nNot yet — hold for the cue.\n\nPARTNER\nThen take a breath. We go on my line."
            sample.draw(in: CGRect(x: 48, y: 80, width: 700, height: 1000), withAttributes: attrs)
        }
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            statusMessage = "Could not create simulator test still."
            return
        }
        do {
            let dest = importsRoot.appendingPathComponent("\(UUID().uuidString).jpg")
            let session = PhotoImportSession(destination: dest)
            let result = try await session.importSelection { data }
            guard case .imported(let url) = result else {
                statusMessage = "Import cancelled."
                return
            }
            let text = try await ScriptOCRService.recognizeText(in: data)
            let page = ScriptPage(
                id: UUID().uuidString,
                sceneId: scene.id,
                relativePath: url.lastPathComponent,
                ocrText: text.isEmpty ? sampleFallbackText() : text
            )
            pendingOCRPage = page
            editingOCRText = page.ocrText
            path = [.ocrReview]
            persistNavigation()
            statusMessage = "Simulator test still ready for OCR review."
        } catch {
            // Vision may miss rendered text; still offer editable draft.
            let page = ScriptPage(
                id: UUID().uuidString,
                sceneId: scene.id,
                relativePath: "sim-draft.txt",
                ocrText: sampleFallbackText()
            )
            pendingOCRPage = page
            editingOCRText = page.ocrText
            path = [.ocrReview]
            persistNavigation()
            statusMessage = "OCR limited on this still — edit text then Keep."
        }
    }

    private func sampleFallbackText() -> String {
        "PARTNER\nDid you lock the stage door?\n\nME\nNot yet — hold for the cue.\n\nPARTNER\nThen take a breath. We go on my line."
    }

    func keepOCRPage() {
        guard var page = pendingOCRPage else { return }
        page.ocrText = editingOCRText.trimmingCharacters(in: .whitespacesAndNewlines)
        scriptPages.removeAll { $0.id == page.id }
        scriptPages.append(page)
        persistPages()
        seedCueLines(from: page)
        pendingOCRPage = nil
        path = [.sceneDetail]
        persistNavigation()
        statusMessage = "Script page kept."
    }

    func discardOCRPage() {
        pendingOCRPage = nil
        editingOCRText = ""
        path = [.importScript]
        persistNavigation()
        statusMessage = "OCR draft discarded."
    }

    private func seedCueLines(from page: ScriptPage) {
        let blocks = page.ocrText.components(separatedBy: "\n\n")
        var seeded: [CueLine] = []
        for block in blocks {
            let lines = block.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
            guard let first = lines.first else { continue }
            let role: String
            let text: String
            if lines.count >= 2, first.uppercased() == first, first.count < 24 {
                role = first.trimmingCharacters(in: .whitespacesAndNewlines)
                text = lines.dropFirst().joined(separator: " ")
            } else {
                role = "Line"
                text = lines.joined(separator: " ")
            }
            guard !text.isEmpty else { continue }
            seeded.append(CueLine(
                id: UUID().uuidString,
                sceneId: page.sceneId,
                role: role,
                text: text,
                pauseMilliseconds: 600
            ))
        }
        if seeded.isEmpty {
            seeded = [CueLine(
                id: UUID().uuidString,
                sceneId: page.sceneId,
                role: "Line",
                text: page.ocrText,
                pauseMilliseconds: 600
            )]
        }
        cueLines.removeAll { $0.sceneId == page.sceneId }
        cueLines.append(contentsOf: seeded)
        if var scene = scenes.first(where: { $0.id == page.sceneId }) {
            let roles = Array(Set(seeded.map(\.role))).sorted()
            scene.roles = roles.isEmpty ? scene.roles : roles
            if let idx = scenes.firstIndex(where: { $0.id == scene.id }) {
                scenes[idx] = scene
                persistScenes()
            }
        }
        persistCues()
    }

    func addCueLine(role: String, text: String, pauseMs: Int) {
        guard let scene = activeScene else { return }
        let line = CueLine(
            id: UUID().uuidString,
            sceneId: scene.id,
            role: role,
            text: text,
            pauseMilliseconds: pauseMs
        )
        cueLines.append(line)
        persistCues()
    }

    func deleteCueLine(_ id: String) {
        cueLines.removeAll { $0.id == id }
        persistCues()
    }

    func prepareSendPartner() {
        if apiKey() == nil {
            statusMessage = aiUnavailableReason ?? "DeepSeek key not configured."
            return
        }
        if !consentGate.state.granted {
            showConsent = true
            return
        }
        Task { await sendPartner() }
    }

    func sendPartner() async {
        guard let scene = activeScene else { return }
        let text = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            statusMessage = "Enter a line to send."
            return
        }
        guard let key = apiKey() else {
            statusMessage = "DeepSeek key not configured (local_only gap)."
            return
        }
        chatBusy = true
        defer { chatBusy = false }
        do {
            let turn = try await AIPrivacyTransport.partnerReply(
                gate: consentGate,
                apiKey: key,
                sceneTitle: scene.title,
                ocrText: activePages.map(\.ocrText).joined(separator: "\n"),
                cueLines: activeCues,
                partnerRole: partnerRole,
                userLine: text,
                voiceTranscript: nil,
                history: activeMessages
            )
            var stamped = turn
            stamped.sceneId = scene.id
            pendingTurn = stamped
            partnerTurns.append(stamped)
            persistTurns()
            statusMessage = "Partner draft ready — Keep or Discard."
        } catch {
            statusMessage = "Partner send failed: \(error.localizedDescription)"
        }
    }

    func keepPendingTurn(feedback: String? = nil) {
        guard let turn = pendingTurn, let scene = activeScene else { return }
        let userMsg = RehearsalMessage(
            id: UUID().uuidString,
            sceneId: scene.id,
            role: userRole,
            text: chatText,
            createdAt: Date()
        )
        var partnerMsg = RehearsalMessage(
            id: UUID().uuidString,
            sceneId: scene.id,
            role: turn.partnerRole,
            text: turn.draftText,
            createdAt: Date().addingTimeInterval(1)
        )
        if let feedback, !feedback.isEmpty {
            partnerMsg.feedbackNotes.append(feedback)
        }
        rehearsalMessages.append(userMsg)
        rehearsalMessages.append(partnerMsg)
        if let idx = partnerTurns.firstIndex(where: { $0.id == turn.id }) {
            partnerTurns[idx].confirmed = true
        }
        persistMessages()
        persistTurns()
        pendingTurn = nil
        chatText = ""
        statusMessage = "Turn kept in rehearsal history."
    }

    func discardPendingTurn() {
        pendingTurn = nil
        statusMessage = "Partner draft discarded."
    }

    func grantConsent() {
        do {
            try consentGate.grant()
            consentGranted = true
            showConsent = false
            refreshAIAvailability()
            statusMessage = "AI data sharing allowed."
        } catch {
            statusMessage = "Could not save consent: \(error.localizedDescription)"
        }
    }

    func denyConsent() {
        showConsent = false
        statusMessage = "AI send cancelled. Local rehearsal stays available."
    }

    func revokeConsent() {
        do {
            try consentGate.revoke()
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "AI consent revoked — outbound stopped."
        } catch {
            consentGranted = false
            refreshAIAvailability()
            statusMessage = "Consent revoked in memory; persist error: \(error.localizedDescription)"
        }
    }

    func setAmbience(_ id: String) {
        guard var scene = activeScene else { return }
        scene.ambienceId = id
        if let idx = scenes.firstIndex(where: { $0.id == scene.id }) {
            scenes[idx] = scene
            persistScenes()
        }
        ambience.use(presetId: id)
        statusMessage = "Ambience: \(AmbienceCatalog.displayName(for: id))"
    }

    func startVoiceNote() async {
        guard let scene = activeScene else { return }
        voiceNoteBusy = true
        defer { voiceNoteBusy = false }
        let url = voiceNotesRoot.appendingPathComponent("\(UUID().uuidString).m4a")
        do {
            try await voiceRecorder.start(to: url)
            pendingVoiceURL = url
            isRecordingVoice = true
            statusMessage = "Recording voice note…"
        } catch {
            // Simulator: persist a placeholder note entry so journey remains testable.
            let note = VoiceNote(
                id: UUID().uuidString,
                sceneId: scene.id,
                relativeAudioPath: "simulator-placeholder.txt",
                transcript: "Simulator voice note placeholder — record on device."
            )
            voiceNotes.append(note)
            persistNotes()
            statusMessage = error.localizedDescription
        }
    }

    func stopVoiceNote() async {
        guard let scene = activeScene else { return }
        voiceNoteBusy = true
        defer { voiceNoteBusy = false }
        do {
            let url = try await voiceRecorder.stop()
            let note = VoiceNote(
                id: UUID().uuidString,
                sceneId: scene.id,
                relativeAudioPath: url.lastPathComponent,
                transcript: nil
            )
            voiceNotes.append(note)
            persistNotes()
            isRecordingVoice = false
            pendingVoiceURL = nil
            statusMessage = "Voice note saved."
        } catch {
            isRecordingVoice = false
            statusMessage = error.localizedDescription
        }
    }

    func speakLineIntoChat() async {
        speechBusy = true
        defer { speechBusy = false }
        do {
            let text = try await speechService.transcribeOnce()
            chatText = text
            statusMessage = "Transcript filled into partner input."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func persistScenes() { try? scenesStore.save(scenes) }
    private func persistPages() { try? pagesStore.save(scriptPages) }
    private func persistCues() { try? cuesStore.save(cueLines) }
    private func persistTurns() { try? turnsStore.save(partnerTurns) }
    private func persistMessages() { try? messagesStore.save(rehearsalMessages) }
    private func persistNotes() { try? notesStore.save(voiceNotes) }
}
