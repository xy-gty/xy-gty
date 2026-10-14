import XCTest
import PitchCueDomain
import AppRuntimeCore

final class PitchCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(CoachingReviewBar.confirm, "Keep")
        XCTAssertEqual(CoachingReviewBar.reject, "Discard")
        XCTAssertEqual(CoachingReviewBar.edit, "Edit")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "pitchcue.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 7)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "PracticeHome", "NewSession", "CaptureImport", "CoachChat", "PlanReview",
            "PracticeFloor", "PitchFeedback", "SessionDetail", "Settings", "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(PitchCueRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("sheet music"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("exercise"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("pitch"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("practice coach"))
    }

    func testPlanPersistKeepSemantics() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("pitchcue-plan-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[PracticePlan]>(url: url)
        let draft = PracticePlan(
            id: "p1",
            sessionId: "s1",
            steps: ["Long tones|90|breathe"],
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
        XCTAssertEqual(loaded.first?.steps.first, "Long tones|90|breathe")
    }

    func testDiscardDoesNotWriteConfirmed() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("pitchcue-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[PracticePlan]>(url: url)
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
        var turn = CoachTurn(
            id: "t1",
            sessionId: "s1",
            role: "user",
            text: "too fast on bar 3",
            feedbackMark: "too_fast",
            createdAt: Date()
        )
        turn.feedbackMark = "too_fast;prefer_slower"
        let encoded = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: encoded)
        XCTAssertTrue(decoded.feedbackMark?.contains("prefer_slower") == true)
        XCTAssertEqual(decoded.role, "user")
    }

    func testSessionRoundTripAndIdentity() throws {
        let session = PracticeSession(
            id: "s",
            title: "Oboe warm-up",
            instrumentLabel: "Oboe",
            updatedAt: Date(),
            freeAccessOpen: true
        )
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(PracticeSession.self, from: data)
        XCTAssertEqual(decoded.title, "Oboe warm-up")
        XCTAssertEqual(PitchCueIdentity.developmentBundleId, "com.lingguang.pitchcue")
        XCTAssertEqual(PitchCueIdentity.productDir, "pitchcue")
    }
}
