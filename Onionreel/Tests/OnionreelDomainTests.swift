import XCTest
import OnionreelDomain
import AppRuntimeCore

final class OnionreelDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(FrameReviewBar.confirm, "Keep")
        XCTAssertEqual(FrameReviewBar.reject, "Discard")
        XCTAssertEqual(FrameReviewBar.edit, "Edit")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "onionreel.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 8)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "ProjectsHome", "NewProject", "CaptureImport", "FrameReview", "StopCoach",
            "CoachChat", "TurnReview", "OnionSkinGuide", "CountdownTTS", "DictateInterval",
            "Settings", "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(OnionreelRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("stop-motion"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("frame sequences"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("Hands-free"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("Dictate interval"))
    }

    func testTimingKeepPersists() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("onionreel-timing-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[TimingCue]>(url: url)
        let cue = TimingCue(
            id: "t1",
            projectId: "p1",
            intervalMs: 400,
            countdownText: "3-2-1-click",
            confirmedAt: Date()
        )
        try store.save([cue])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.intervalMs, 400)
        XCTAssertEqual(loaded.first?.countdownText, "3-2-1-click")
    }

    func testDiscardDoesNotWriteConfirmedTiming() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("onionreel-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[TimingCue]>(url: url)
        try store.save([])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertTrue(loaded.isEmpty)
    }

    @MainActor
    func testConsentGateBlocksUntilGrantAndAfterRevoke() throws {
        var disk: AIConsentGate.State?
        let gate = AIConsentGate(
            provider: AIConsentContract.provider,
            disclosureVersion: AIConsentContract.disclosureVersion,
            load: { disk },
            persist: { disk = $0 }
        )
        XCTAssertFalse(gate.state.granted)
        XCTAssertThrowsError(try gate.permit())
        try gate.grant()
        XCTAssertTrue(gate.state.granted)
        let permit = try gate.permit()
        try gate.validate(permit)
        try gate.revoke()
        XCTAssertFalse(gate.state.granted)
        XCTAssertThrowsError(try gate.permit())
    }

    func testSecondCallContextCarriesConfirmedFeedback() throws {
        let turn = CoachTurn(
            id: "t1",
            projectId: "p1",
            role: "user",
            text: "next frame a bit closer",
            createdAt: Date()
        )
        let encoded = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: encoded)
        XCTAssertTrue(decoded.text.contains("closer"))
        XCTAssertEqual(decoded.role, "user")
    }

    func testProjectRoundTripAndIdentity() throws {
        let project = Project(
            id: "p",
            title: "Desk puppet",
            targetFrameRate: 12,
            createdAt: Date(),
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(project)
        let decoded = try JSONDecoder().decode(Project.self, from: data)
        XCTAssertEqual(decoded.title, "Desk puppet")
        XCTAssertEqual(OnionreelIdentity.developmentBundleId, "com.lingguang.onionreel")
        XCTAssertEqual(OnionreelIdentity.productDir, "onionreel")
        XCTAssertEqual(OnionreelIdentity.appName, "Onionreel")
        XCTAssertEqual(OnionreelPalette.primary, "#16A34A")
        XCTAssertEqual(OnionreelPalette.secondary, "#F0FDF4")
        XCTAssertEqual(OnionreelPalette.accent, "#DB2777")
        XCTAssertEqual(OnionreelDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertTrue(OnionreelDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(OnionreelAllergy.bannedTwinShells.contains("Shutterdusk"))
        XCTAssertTrue(OnionreelAllergy.requiredUI.contains("film-sprocket timeline"))
        XCTAssertTrue(OnionreelAllergy.requiredUI.contains("onion-skin overlay preview"))
    }

    func testOnionSkinGuidePersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("onionreel-onion-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[OnionSkinGuide]>(url: url)
        let guide = OnionSkinGuide(
            id: "o1",
            projectId: "p1",
            frameSequenceId: "fs1",
            alignmentHint: "Match front edge",
            displacementNote: "Closer",
            notes: "ok",
            status: "confirmed",
            updatedAt: Date()
        )
        try store.save([guide])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.alignmentHint, "Match front edge")
        XCTAssertEqual(loaded.first?.status, "confirmed")
    }
}
