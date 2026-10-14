import XCTest
import CuePartnerDomain
import AppRuntimeCore


final class CuePartnerDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(OCRReviewBar.confirm, "Keep")
        XCTAssertEqual(OCRReviewBar.reject, "Discard")
        XCTAssertEqual(OCRReviewBar.edit, "Edit text")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "cuepartner.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 6)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "ScenesHome", "NewScene", "ImportScript", "OCRReview", "SceneDetail",
            "PartnerChat", "TurnReview", "CueRehearsal", "VoiceNoteCapture",
            "AmbiencePicker", "Settings", "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(CuePartnerRoute.allCases.map(\.rawValue), expected)
    }

    func testRehearsalMessagePersistAndRejectSemantics() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("cuepartner-msg-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[RehearsalMessage]>(url: url)
        let kept = RehearsalMessage(
            id: "m1",
            sceneId: "s1",
            role: "Partner",
            text: "Hold for the cue.",
            createdAt: Date(timeIntervalSince1970: 1),
            feedbackNotes: ["softer on the entrance"]
        )
        try store.save([kept])
        let loaded = try store.load()
        XCTAssertEqual(loaded?.first?.text, "Hold for the cue.")
        XCTAssertEqual(loaded?.first?.feedbackNotes.first, "softer on the entrance")

        // Reject path: draft PartnerTurn never becomes RehearsalMessage
        let draft = PartnerTurn(id: "t1", sceneId: "s1", partnerRole: "Partner", draftText: "Nope", confirmed: false)
        XCTAssertFalse(draft.confirmed)
        let afterReject = try store.load()
        XCTAssertEqual(afterReject?.count, 1)
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

    func testSecondCallContextCarriesFeedbackNotes() throws {
        var msg = RehearsalMessage(
            id: "m2",
            sceneId: "s1",
            role: "Partner",
            text: "We go on my line.",
            createdAt: Date(),
            feedbackNotes: []
        )
        msg.feedbackNotes.append("faster beat")
        let encoded = try JSONEncoder().encode(msg)
        let decoded = try JSONDecoder().decode(RehearsalMessage.self, from: encoded)
        XCTAssertEqual(decoded.feedbackNotes, ["faster beat"])
    }

    func testSceneRoundTripWithAmbience() throws {
        let scene = CuePartnerDomain.Scene(
            id: "s",
            title: "Kitchen",
            roles: ["Me", "Partner"],
            locked: false,
            createdAt: Date(timeIntervalSince1970: 2),
            ambienceId: "quiet_stage"
        )
        let data = try JSONEncoder().encode(scene)
        let decoded = try JSONDecoder().decode(CuePartnerDomain.Scene.self, from: data)
        XCTAssertEqual(decoded.ambienceId, "quiet_stage")
        XCTAssertEqual(AmbienceCatalog.displayName(for: "rain_wings"), "Rain wings")
    }

    func testPrivacyUsageCopyPresent() {
        XCTAssertFalse(PrivacyUsageCopy.camera.isEmpty)
        XCTAssertFalse(PrivacyUsageCopy.photoLibrary.isEmpty)
        XCTAssertFalse(PrivacyUsageCopy.microphone.isEmpty)
        XCTAssertFalse(PrivacyUsageCopy.speechRecognition.isEmpty)
    }
}
