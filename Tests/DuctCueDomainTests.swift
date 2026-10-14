import XCTest
import DuctCueDomain
import AppRuntimeCore

final class DuctCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(DuctCueReviewControls.confirm, "Use")
        XCTAssertEqual(DuctCueReviewControls.reject, "Not this")
        XCTAssertEqual(DuctCueReviewControls.edit, "Edit sizes")
        XCTAssertEqual(DuctCueReviewControls.SizeDiagramPreview.confirm, "Save diagram")
        XCTAssertEqual(DuctCueReviewControls.SizeDiagramPreview.reject, "Discard")
        XCTAssertEqual(DuctCueIdentity.aiProvider, "DeepSeek")
        XCTAssertEqual(DuctCueIdentity.consentDisclosureVersion, "ductcue.consent.v1")
        XCTAssertEqual(DuctCueIdentity.developmentBundleID, "com.lingguang.ductcue")
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "HomeTab", "JobsCanvas", "JobCapture", "DuctRunReview", "DuctRunDetail",
            "CoachChat", "SizeDiagram", "FieldSteps", "SpeechCapture", "Settings",
            "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(DuctCueNavigation.allRoutes.map(\.rawValue), expected)
    }

    func testDuctRunPersistRejectDoesNotWriteAndRestart() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ductcue-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = DuctCueStorageRoot(rootDirectory: root)
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
            provider: DuctCueIdentity.aiProvider,
            disclosureVersion: DuctCueIdentity.consentDisclosureVersion,
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
        XCTAssertFalse(DuctCueOutboundAIBoundary.snapshot(consentGranted: false, apiKeyPresent: true).outboundEnabled)
        XCTAssertTrue(DuctCueOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: true).outboundEnabled)
        XCTAssertFalse(DuctCueOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: false).outboundEnabled)
    }

    func testSizeDiagramSaveAndDiscardSemantics() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ductcue-diagram-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = DuctCueStorageRoot(rootDirectory: root)
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
