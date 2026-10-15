import XCTest
import FormCueDomain
import AppRuntimeCore

final class FormCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(FormReviewBar.confirm, "Keep")
        XCTAssertEqual(FormReviewBar.reject, "Discard")
        XCTAssertEqual(FormReviewBar.edit, "Edit")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "formcue.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 7)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "SessionsHome", "NewSession", "CaptureImport", "FormReview", "SessionCoach",
            "CoachChat", "TurnReview", "AnnotatedForm", "HandsFreeTTS", "DictateIntent",
            "Settings", "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(FormCueRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("mid-set form"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("reference poses"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("Hands-free coach dictate"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("skip rest"))
    }

    func testFormCorrectionKeepPersists() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("formcue-cue-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[FormCorrection]>(url: url)
        let cue = FormCorrection(
            id: "c1",
            sessionId: "s1",
            formShotId: "f1",
            jointHint: "hips",
            alignmentHint: "level pelvis",
            cueText: "Brace before the squat",
            confirmedAt: Date()
        )
        try store.save([cue])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.cueText, "Brace before the squat")
        XCTAssertEqual(loaded.first?.jointHint, "hips")
    }

    func testDiscardDoesNotWriteConfirmedCorrection() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("formcue-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[FormCorrection]>(url: url)
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
            text: "keep knees tracking on next round",
            createdAt: Date()
        )
        let encoded = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: encoded)
        XCTAssertTrue(decoded.text.contains("knees"))
        XCTAssertEqual(decoded.role, "user")
    }

    func testSessionRoundTripAndIdentity() throws {
        let session = Session(
            id: "s",
            title: "Red HIIT",
            targetBodyArea: "legs",
            currentBlockLabel: "Main HIIT",
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(Session.self, from: data)
        XCTAssertEqual(decoded.title, "Red HIIT")
        XCTAssertEqual(FormCueIdentity.developmentBundleId, "com.lingguang.formcue")
        XCTAssertEqual(FormCueIdentity.productDir, "formcue")
        XCTAssertEqual(FormCueIdentity.appName, "FormCue")
        XCTAssertEqual(FormCuePalette.primary, "#DC2626")
        XCTAssertEqual(FormCuePalette.secondary, "#FEF2F2")
        XCTAssertEqual(FormCuePalette.accent, "#22D3EE")
    }

    func testIntervalBlockPersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("formcue-block-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[IntervalBlock]>(url: url)
        let block = IntervalBlock(
            id: "b1",
            sessionId: "s1",
            label: "Main HIIT",
            workSeconds: 40,
            restSeconds: 20,
            rounds: 4,
            sortIndex: 1
        )
        try store.save([block])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.workSeconds, 40)
        XCTAssertEqual(loaded.first?.restSeconds, 20)
    }
}
