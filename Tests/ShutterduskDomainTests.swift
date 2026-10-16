import XCTest
import ShutterduskDomain
import AppRuntimeCore

final class ShutterduskDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(ExposureReviewBar.confirm, "Keep")
        XCTAssertEqual(ExposureReviewBar.reject, "Discard")
        XCTAssertEqual(ExposureReviewBar.edit, "Edit")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "shutterdusk.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 9)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "SessionsHome", "NewSession", "CaptureImport", "ExposureReview", "NightCoach",
            "CoachChat", "TurnReview", "AnnotatedOverlay", "FieldCueTTS", "DictateExposure",
            "Settings", "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(ShutterduskRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("night test frames"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("night frames"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("Hands-free"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("Dictate exposure"))
    }

    func testFindingKeepPersists() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("shutterdusk-finding-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[DiagnosisFinding]>(url: url)
        let finding = DiagnosisFinding(
            id: "f1",
            sessionId: "s1",
            nightFrameId: "n1",
            tag: "underexposed",
            detail: "Lift ISO or lengthen shutter",
            confirmedAt: Date()
        )
        try store.save([finding])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.detail, "Lift ISO or lengthen shutter")
        XCTAssertEqual(loaded.first?.tag, "underexposed")
    }

    func testDiscardDoesNotWriteConfirmedFinding() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("shutterdusk-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[DiagnosisFinding]>(url: url)
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
            sessionId: "s1",
            role: "user",
            text: "prefer longer shutter over ISO 6400",
            createdAt: Date()
        )
        let encoded = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: encoded)
        XCTAssertTrue(decoded.text.contains("shutter"))
        XCTAssertEqual(decoded.role, "user")
    }

    func testSessionRoundTripAndIdentity() throws {
        let session = Session(
            id: "s",
            locationLabel: "River bridge",
            sessionDate: Date(),
            sceneGoal: "Light trails",
            currentFrameLabel: "N2",
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(Session.self, from: data)
        XCTAssertEqual(decoded.locationLabel, "River bridge")
        XCTAssertEqual(ShutterduskIdentity.developmentBundleId, "com.lingguang.shutterdusk")
        XCTAssertEqual(ShutterduskIdentity.productDir, "shutterdusk")
        XCTAssertEqual(ShutterduskIdentity.appName, "Shutterdusk")
        XCTAssertEqual(ShutterduskPalette.primary, "#1E3A8A")
        XCTAssertEqual(ShutterduskPalette.secondary, "#EFF6FF")
        XCTAssertEqual(ShutterduskPalette.accent, "#FBBF24")
        XCTAssertEqual(ShutterduskDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertTrue(ShutterduskDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(ShutterduskAllergy.bannedTwinShells.contains("Broodcheck"))
        XCTAssertTrue(ShutterduskAllergy.requiredUI.contains("night-frame rail"))
    }

    func testAnnotatedOverlayPersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("shutterdusk-overlay-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[AnnotatedOverlay]>(url: url)
        let overlay = AnnotatedOverlay(
            id: "o1",
            sessionId: "s1",
            nightFrameId: "n1",
            xNorm: 0.4,
            yNorm: 0.5,
            diagnosisValue: 0.7,
            label: "noise",
            status: "confirmed",
            updatedAt: Date()
        )
        try store.save([overlay])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.label, "noise")
        XCTAssertEqual(try XCTUnwrap(loaded.first?.diagnosisValue), 0.7, accuracy: 0.001)
    }
}
