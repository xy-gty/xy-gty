import XCTest
import AirspanDomain
import AppRuntimeCore

final class AirspanDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(AirspanReviewControls.confirm, "Use")
        XCTAssertEqual(AirspanReviewControls.reject, "Not this")
        XCTAssertEqual(AirspanReviewControls.edit, "Edit sizes")
        XCTAssertEqual(AirspanReviewControls.SizeDiagramPreview.confirm, "Save diagram")
        XCTAssertEqual(AirspanReviewControls.SizeDiagramPreview.reject, "Discard")
        XCTAssertEqual(AirspanIdentity.aiProvider, "DeepSeek")
        XCTAssertEqual(AirspanIdentity.consentDisclosureVersion, "airspan.consent.v1")
        XCTAssertEqual(AirspanIdentity.developmentBundleID, "com.lingguang.airspan")
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "HomeTab", "JobsCanvas", "JobCapture", "DuctRunReview", "DuctRunDetail",
            "CoachChat", "SizeDiagram", "FieldSteps", "SpeechCapture", "Settings",
            "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(AirspanNavigation.allRoutes.map(\.rawValue), expected)
    }

    func testDuctRunPersistRejectDoesNotWriteAndRestart() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("airspan-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = AirspanStorageRoot(rootDirectory: root)
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("domain", isDirectory: true),
            withIntermediateDirectories: true
        )
        let run = DuctRun(
            localFileName: "run.jpg",
            sizeTags: ["10×8 rectangular"],
            lengthFeet: 12
        )
        try storage.ductRuns.save(DuctRunCatalog(runs: [run]))
        XCTAssertEqual(try storage.ductRuns.load()?.runs.first?.sizeTags.first, "10×8 rectangular")
        // Reject path: empty catalog remains empty
        try storage.ductRuns.save(DuctRunCatalog(runs: []))
        XCTAssertEqual(try storage.ductRuns.load()?.runs.count, 0)
        // Restart persistence of sizing sessions for second-call reuse
        let session = SizingSession(
            promptText: "Size for 420 CFM",
            responseText: "10×8 @ ~900 FPM",
            cfm: 420,
            friction: 0.08,
            velocity: 900,
            citedFormulas: ["Q = V × A"]
        )
        try storage.sizingSessions.save(SizingSessionCatalog(sessions: [session]))
        XCTAssertEqual(try storage.sizingSessions.load()?.sessions.first?.promptText, "Size for 420 CFM")
    }

    @MainActor
    func testConsentGateBlocksUntilGrantAndAfterRevoke() throws {
        var disk: AIConsentGate.State?
        let gate = AIConsentGate(
            provider: AirspanIdentity.aiProvider,
            disclosureVersion: AirspanIdentity.consentDisclosureVersion,
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
        XCTAssertFalse(AirspanOutboundAIBoundary.snapshot(consentGranted: false, apiKeyPresent: true).outboundEnabled)
        XCTAssertTrue(AirspanOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: true).outboundEnabled)
        XCTAssertFalse(AirspanOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: false).outboundEnabled)
    }

    func testSizeDiagramSaveAndDiscardSemantics() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("airspan-diagram-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = AirspanStorageRoot(rootDirectory: root)
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("domain", isDirectory: true),
            withIntermediateDirectories: true
        )
        var diagram = SizeDiagram(localFileName: "d.png", status: "draft")
        try storage.sizeDiagrams.save(SizeDiagramCatalog(diagrams: [diagram]))
        diagram.status = "saved"
        diagram.savedAt = Date()
        try storage.sizeDiagrams.save(SizeDiagramCatalog(diagrams: [diagram]))
        XCTAssertEqual(try storage.sizeDiagrams.load()?.diagrams.first?.status, "saved")
        try storage.sizeDiagrams.save(SizeDiagramCatalog(diagrams: []))
        XCTAssertEqual(try storage.sizeDiagrams.load()?.diagrams.count, 0)
    }
}
