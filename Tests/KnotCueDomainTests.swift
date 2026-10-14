import XCTest
import KnotCueDomain
import AppRuntimeCore

final class KnotCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(KnotCueReviewControls.confirm, "Keep stage")
        XCTAssertEqual(KnotCueReviewControls.reject, "Not this")
        XCTAssertEqual(KnotCueReviewControls.edit, "Edit stage")
        XCTAssertEqual(KnotCueReviewControls.StepOverlayPreview.confirm, "Save overlay")
        XCTAssertEqual(KnotCueReviewControls.StepOverlayPreview.reject, "Discard")
        XCTAssertEqual(KnotCueIdentity.aiProvider, "DeepSeek")
        XCTAssertEqual(KnotCueIdentity.consentDisclosureVersion, "knotcue.consent.v1")
        XCTAssertEqual(KnotCueIdentity.developmentBundleID, "com.lingguang.knotcue")
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "HomeTab", "RopeCarousel", "KnotCapture", "StageReview", "KnotStageDetail",
            "CoachChat", "StepOverlay", "HandsFreeCoach", "SpeechCapture", "Settings",
            "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(KnotCueNavigation.allRoutes.map(\.rawValue), expected)
    }

    func testKeepStagePersistRejectDoesNotWriteAndRestart() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("knotcue-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = KnotCueStorageRoot(rootDirectory: root)
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("domain", isDirectory: true),
            withIntermediateDirectories: true
        )
        let stage = KnotStage(
            localFileName: "knot.jpg",
            stageTags: ["Step 3 · rabbit through hole"],
            wrongHauls: ["Loop too small"],
            ropeDiameterMM: 10
        )
        try storage.knotStages.save(KnotStageCatalog(stages: [stage]))
        XCTAssertEqual(try storage.knotStages.load()?.stages.first?.stageTags.first, "Step 3 · rabbit through hole")
        try storage.knotStages.save(KnotStageCatalog(stages: []))
        XCTAssertEqual(try storage.knotStages.load()?.stages.count, 0)
        let turn = CoachTurn(
            promptText: "Next haul?",
            responseText: "Pull working end to set the knot",
            haulContext: "Pull working end"
        )
        try storage.coachTurns.save(CoachTurnCatalog(turns: [turn]))
        XCTAssertEqual(try storage.coachTurns.load()?.turns.first?.promptText, "Next haul?")
    }

    @MainActor
    func testConsentGateBlocksUntilGrantAndAfterRevoke() throws {
        var disk: AIConsentGate.State?
        let gate = AIConsentGate(
            provider: KnotCueIdentity.aiProvider,
            disclosureVersion: KnotCueIdentity.consentDisclosureVersion,
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
        XCTAssertFalse(KnotCueOutboundAIBoundary.snapshot(consentGranted: false, apiKeyPresent: true).outboundEnabled)
        XCTAssertTrue(KnotCueOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: true).outboundEnabled)
        XCTAssertFalse(KnotCueOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: false).outboundEnabled)
    }

    func testOverlaySaveAndDiscardSemantics() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("knotcue-overlay-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = KnotCueStorageRoot(rootDirectory: root)
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("domain", isDirectory: true),
            withIntermediateDirectories: true
        )
        var overlay = StepOverlay(localFileName: "o.png", annotationNotes: ["1 Mark bite"], status: "draft")
        try storage.stepOverlays.save(StepOverlayCatalog(overlays: [overlay]))
        overlay.status = "saved"
        overlay.savedAt = Date()
        try storage.stepOverlays.save(StepOverlayCatalog(overlays: [overlay]))
        XCTAssertEqual(try storage.stepOverlays.load()?.overlays.first?.status, "saved")
        try storage.stepOverlays.save(StepOverlayCatalog(overlays: []))
        XCTAssertEqual(try storage.stepOverlays.load()?.overlays.count, 0)
    }
}
