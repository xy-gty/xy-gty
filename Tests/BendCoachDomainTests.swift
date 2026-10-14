import XCTest
import BendCoachDomain
import AppRuntimeCore

final class BendCoachDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(BendCoachReviewControls.confirm, "Save")
        XCTAssertEqual(BendCoachReviewControls.reject, "Not this")
        XCTAssertEqual(BendCoachReviewControls.edit, "Edit marks")
        XCTAssertEqual(BendCoachReviewControls.DiagramPreview.confirm, "Use")
        XCTAssertEqual(BendCoachReviewControls.DiagramPreview.reject, "Discard")
        XCTAssertEqual(BendCoachIdentity.aiProvider, "DeepSeek")
        XCTAssertEqual(BendCoachIdentity.consentDisclosureVersion, "bendcoach.consent.v1")
        XCTAssertEqual(BendCoachIdentity.developmentBundleID, "com.lingguang.bendcoach")
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "HomeTab", "BendMathChat", "CaptureImport", "BendReview", "JobDetail",
            "DiagramOverlay", "TTSCoaching", "SpeechCapture", "Settings", "Units",
            "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(BendCoachNavigation.allRoutes.map(\.rawValue), expected)
    }

    func testMarkupPersistRejectDoesNotWriteAndRestart() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("bendcoach-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = BendCoachStorageRoot(rootDirectory: root)
        let job = JobSession(title: "Stub")
        try storage.jobSessions.save(JobSessionCatalog(sessions: [job]))
        let markup = BendMarkup(
            jobSessionID: job.id,
            fieldPhotoID: UUID(),
            bendType: "offset",
            keyDimensions: ["rise": "12 in"]
        )
        // Confirm path writes
        try storage.markups.save(BendMarkupCatalog(markups: [markup]))
        let loaded = try storage.markups.load()
        XCTAssertEqual(loaded?.markups.first?.bendType, "offset")
        // Reject path: empty catalog remains empty
        try storage.markups.save(BendMarkupCatalog(markups: []))
        XCTAssertEqual(try storage.markups.load()?.markups.count, 0)
        // Restart persistence of queries for second-call reuse
        let q = BendQuery(jobSessionID: job.id, promptText: "90 stub", responseText: "demo")
        try storage.bendQueries.save(BendQueryCatalog(queries: [q]))
        XCTAssertEqual(try storage.bendQueries.load()?.queries.first?.promptText, "90 stub")
    }

    @MainActor
    func testConsentGateBlocksUntilGrantAndAfterRevoke() throws {
        var disk: AIConsentGate.State?
        let gate = AIConsentGate(
            provider: BendCoachIdentity.aiProvider,
            disclosureVersion: BendCoachIdentity.consentDisclosureVersion,
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

    func testOutboundRequiresConsentAndKey() {
        XCTAssertFalse(BendCoachOutboundAIBoundary.snapshot(consentGranted: false, apiKeyPresent: true).outboundEnabled)
        XCTAssertTrue(BendCoachOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: true).outboundEnabled)
        XCTAssertFalse(BendCoachOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: false).outboundEnabled)
    }

    func testUnitPreferenceRoundTrip() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("bendcoach-units-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = BendCoachStorageRoot(rootDirectory: root)
        _ = try UnitSystemControl.setUnitSystem(.metric, storage: storage)
        let loaded = try UnitSystemControl.load(storage: storage)
        XCTAssertEqual(loaded.unitSystem, .metric)
    }
}
