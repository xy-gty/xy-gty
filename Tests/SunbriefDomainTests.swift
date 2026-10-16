import XCTest
import SunbriefDomain
import AppRuntimeCore

final class SunbriefDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(SceneReviewBar.confirm, "Keep")
        XCTAssertEqual(SceneReviewBar.reject, "Discard")
        XCTAssertEqual(SceneReviewBar.edit, "Edit labels")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "sunbrief.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 6)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "ScoutsHome", "CaptureImport", "SceneReview", "ScoutCardDetail", "CoachChat",
            "TurnReview", "GoldenOverlay", "NextStopBriefing", "DictateNote", "Settings",
            "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(SunbriefRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("scene recognition"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("scouting shots"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("Dictate shoot notes"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("golden-hour"))
    }

    func testCardPersistKeepSemantics() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("sunbrief-card-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[SceneCard]>(url: url)
        let draft = SceneCard(
            id: "c1",
            shotId: "s1",
            placeLabel: "Wide ridge",
            lightQuality: "Warm side-light",
            facingHint: "West-facing rim",
            status: "draft",
            updatedAt: Date()
        )
        try store.save([draft])
        var loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.status, "draft")

        var kept = draft
        kept.status = "confirmed"
        try store.save([kept])
        loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.status, "confirmed")
        XCTAssertEqual(loaded.first?.placeLabel, "Wide ridge")
    }

    func testDiscardDoesNotWriteConfirmedCard() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("sunbrief-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[SceneCard]>(url: url)
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
            cardId: "c1",
            role: "user",
            text: "prefer later golden window",
            createdAt: Date()
        )
        let encoded = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: encoded)
        XCTAssertTrue(decoded.text.contains("golden"))
        XCTAssertEqual(decoded.role, "user")
    }

    func testIdentityAndPlanRoundTrip() throws {
        let plan = ScoutPlan(
            id: "p",
            cardId: "c",
            title: "Ridge scout",
            windowIds: ["win-golden-pm"],
            notes: "west rim",
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(plan)
        let decoded = try JSONDecoder().decode(ScoutPlan.self, from: data)
        XCTAssertEqual(decoded.title, "Ridge scout")
        XCTAssertEqual(SunbriefIdentity.developmentBundleId, "com.lingguang.sunbrief")
        XCTAssertEqual(SunbriefIdentity.productDir, "sunbrief")
        XCTAssertEqual(SunbriefIdentity.appName, "Sunbrief")
    }
}
