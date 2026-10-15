import XCTest
import HiveCueDomain
import AppRuntimeCore

final class HiveCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(BroodReviewBar.confirm, "Keep")
        XCTAssertEqual(BroodReviewBar.reject, "Discard")
        XCTAssertEqual(BroodReviewBar.edit, "Edit")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "hivecue.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 9)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "InspectionsHome", "NewInspection", "CaptureImport", "BroodReview", "InspectionCoach",
            "CoachChat", "TurnReview", "AnnotatedFrame", "HandsFreeTTS", "DictateFields",
            "Settings", "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(HiveCueRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("brood-frame"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("compare brood"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("Hands-free"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("Dictate inspection fields"))
    }

    func testFindingKeepPersists() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hivecue-finding-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[Finding]>(url: url)
        let finding = Finding(
            id: "f1",
            inspectionId: "i1",
            frameShotId: "s1",
            tag: "brood",
            detail: "Capped brood band present",
            confirmedAt: Date()
        )
        try store.save([finding])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.detail, "Capped brood band present")
        XCTAssertEqual(loaded.first?.tag, "brood")
    }

    func testDiscardDoesNotWriteConfirmedFinding() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hivecue-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[Finding]>(url: url)
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
            inspectionId: "i1",
            role: "user",
            text: "check stores on next frame",
            createdAt: Date()
        )
        let encoded = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: encoded)
        XCTAssertTrue(decoded.text.contains("stores"))
        XCTAssertEqual(decoded.role, "user")
    }

    func testInspectionRoundTripAndIdentity() throws {
        let inspection = Inspection(
            id: "i",
            hiveLabel: "Hive A",
            inspectedAt: Date(),
            currentFrameLabel: "F2",
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(inspection)
        let decoded = try JSONDecoder().decode(Inspection.self, from: data)
        XCTAssertEqual(decoded.hiveLabel, "Hive A")
        XCTAssertEqual(HiveCueIdentity.developmentBundleId, "com.lingguang.hivecue")
        XCTAssertEqual(HiveCueIdentity.productDir, "hivecue")
        XCTAssertEqual(HiveCueIdentity.appName, "HiveCue")
        XCTAssertEqual(HiveCuePalette.primary, "#9F1239")
        XCTAssertEqual(HiveCuePalette.secondary, "#FDF2F8")
        XCTAssertEqual(HiveCuePalette.accent, "#4D7C0F")
        XCTAssertEqual(HiveCueDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertTrue(HiveCueDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
    }

    func testAnnotatedOverlayPersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hivecue-overlay-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[AnnotatedOverlay]>(url: url)
        let overlay = AnnotatedOverlay(
            id: "o1",
            inspectionId: "i1",
            frameShotId: "s1",
            xNorm: 0.4,
            yNorm: 0.5,
            heatValue: 0.7,
            label: "brood",
            status: "confirmed",
            updatedAt: Date()
        )
        try store.save([overlay])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.label, "brood")
        XCTAssertEqual(try XCTUnwrap(loaded.first?.heatValue), 0.7, accuracy: 0.001)
    }
}
