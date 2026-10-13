import XCTest
import SnagCueDomain
import AppRuntimeCore

final class SnagCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(SnagReviewBar.confirm, "Save")
        XCTAssertEqual(SnagReviewBar.reject, "Not this")
        XCTAssertEqual(SnagReviewBar.edit, "Edit snag")
        XCTAssertEqual(PunchFieldReview.confirm, "Save")
        XCTAssertEqual(AnnotatedReportPreview.confirm, "Use")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "snagcue.consent.v1")
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "HomeTab", "NewAudit", "Capture", "SnagRecognitionReview", "PunchList",
            "ChatFill", "FieldReview", "AnnotatedReport", "TTSCoach", "Settings",
            "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(SnagCueRoute.allCases.map(\.rawValue), expected)
    }

    func testPunchItemPersistAndRejectSemantics() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("snagcue-punch-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[PunchItem]>(url: url)
        let item = PunchItem(
            id: "p1",
            auditId: "a1",
            title: "Cracked tile",
            location: "Bath",
            severity: "high",
            feedbackNotes: ["assignee is GC not painter"]
        )
        try store.save([item])
        let loaded = try store.load()
        XCTAssertEqual(loaded?.first?.title, "Cracked tile")
        XCTAssertEqual(loaded?.first?.feedbackNotes.first, "assignee is GC not painter")
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
        var item = PunchItem(id: "p2", auditId: "a1", title: "Paint touch-up")
        item.feedbackNotes.append("assignee is GC not painter")
        let encoded = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(PunchItem.self, from: encoded)
        XCTAssertEqual(decoded.feedbackNotes, ["assignee is GC not painter"])
    }

    func testAuditRoundTrip() throws {
        let audit = Audit(id: "a", title: "Walk", siteLabel: "Tower B", status: "open")
        let data = try JSONEncoder().encode(audit)
        let decoded = try JSONDecoder().decode(Audit.self, from: data)
        XCTAssertEqual(decoded.siteLabel, "Tower B")
    }
}
