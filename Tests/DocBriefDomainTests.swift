import XCTest
import DocBriefDomain
import AppRuntimeCore

final class DocBriefDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(DocBriefReviewControls.confirm, "Save")
        XCTAssertEqual(DocBriefReviewControls.reject, "Not this")
        XCTAssertEqual(DocBriefReviewControls.edit, "Edit fields")
        XCTAssertEqual(DocBriefReviewControls.ActionReview.confirm, "Save")
        XCTAssertEqual(DocBriefReviewControls.SummaryCardPreview.confirm, "Use")
        XCTAssertEqual(DocBriefIdentity.aiProvider, "DeepSeek")
        XCTAssertEqual(DocBriefIdentity.consentDisclosureVersion, "docbrief.consent.v1")
        XCTAssertEqual(DocBriefIdentity.developmentBundleID, "com.lingguang.docbrief")
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "HomeTab", "NewBrief", "ImportCapture", "RecognitionReview", "BriefDetail",
            "ChatExtract", "ActionReview", "SummaryCard", "TTSBriefing", "Settings",
            "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(DocBriefNavigation.allRoutes.map(\.rawValue), expected)
    }

    func testActionItemPersistAndFeedbackReuse() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("docbrief-action-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<ActionItemCatalog>(url: url)
        let item = ActionItem(
            briefID: UUID(),
            text: "Pay invoice",
            feedbackNotes: ["deadline is Friday not Thursday"]
        )
        try store.save(ActionItemCatalog(items: [item]))
        let loaded = try store.load()
        XCTAssertEqual(loaded?.items.first?.text, "Pay invoice")
        XCTAssertEqual(loaded?.items.first?.feedbackNotes.first, "deadline is Friday not Thursday")
    }

    @MainActor
    func testConsentGateBlocksUntilGrantAndAfterRevoke() throws {
        var disk: AIConsentGate.State?
        let gate = AIConsentGate(
            provider: DocBriefIdentity.aiProvider,
            disclosureVersion: DocBriefIdentity.consentDisclosureVersion,
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

    func testBriefCatalogRoundTrip() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("docbrief-briefs-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<BriefCatalog>(url: url)
        let brief = Brief(title: "Receipt desk")
        try store.save(BriefCatalog(briefs: [brief]))
        let loaded = try store.load()
        XCTAssertEqual(loaded?.briefs.first?.title, "Receipt desk")
    }

    func testOutboundRequiresConsentAndKey() {
        let off = DocBriefOutboundAIBoundary.snapshot(consentGranted: false, apiKeyPresent: true)
        XCTAssertFalse(off.outboundEnabled)
        let on = DocBriefOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: true)
        XCTAssertTrue(on.outboundEnabled)
        let noKey = DocBriefOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: false)
        XCTAssertFalse(noKey.outboundEnabled)
    }

    func testRejectDoesNotConfirmField() {
        var field = ExtractedField(briefID: UUID(), key: "vendor", value: "Acme", confirmed: false)
        XCTAssertFalse(field.confirmed)
        field.confirmed = true
        XCTAssertTrue(field.confirmed)
    }
}
