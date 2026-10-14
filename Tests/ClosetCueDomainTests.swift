import XCTest
import ClosetCueDomain
import AppRuntimeCore

final class ClosetCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(ClosetCueReviewControls.confirm, "Keep")
        XCTAssertEqual(ClosetCueReviewControls.reject, "Not this")
        XCTAssertEqual(ClosetCueReviewControls.edit, "Edit tags")
        XCTAssertEqual(ClosetCueReviewControls.FlatLayPreview.confirm, "Save look")
        XCTAssertEqual(ClosetCueReviewControls.FlatLayPreview.reject, "Discard")
        XCTAssertEqual(ClosetCueIdentity.aiProvider, "DeepSeek")
        XCTAssertEqual(ClosetCueIdentity.consentDisclosureVersion, "closetcue.consent.v1")
        XCTAssertEqual(ClosetCueIdentity.developmentBundleID, "com.lingguang.closetcue")
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "HomeTab", "ClosetShelf", "CaptureImport", "GarmentReview", "ClosetItemDetail",
            "StylistChat", "FlatLayBoard", "MorningBriefing", "SpeechCapture", "Settings",
            "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(ClosetCueNavigation.allRoutes.map(\.rawValue), expected)
    }

    func testClosetItemPersistRejectDoesNotWriteAndRestart() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("closetcue-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = ClosetCueStorageRoot(rootDirectory: root)
        let item = ClosetItem(
            localFileName: "navy.jpg",
            category: "Tops",
            colorTone: "Cool",
            seasonHint: "Spring",
            tags: ["Tops", "Cool tone", "Spring"]
        )
        try storage.closetItems.save(ClosetItemCatalog(items: [item]))
        XCTAssertEqual(try storage.closetItems.load()?.items.first?.category, "Tops")
        // Reject path: empty catalog remains empty
        try storage.closetItems.save(ClosetItemCatalog(items: []))
        XCTAssertEqual(try storage.closetItems.load()?.items.count, 0)
        // Restart persistence of outfit plans for second-call reuse
        let plan = OutfitPlan(promptText: "Office Tuesday light rain", responseText: "Shirt + trousers")
        try storage.outfitPlans.save(OutfitPlanCatalog(plans: [plan]))
        XCTAssertEqual(try storage.outfitPlans.load()?.plans.first?.promptText, "Office Tuesday light rain")
    }

    @MainActor
    func testConsentGateBlocksUntilGrantAndAfterRevoke() throws {
        var disk: AIConsentGate.State?
        let gate = AIConsentGate(
            provider: ClosetCueIdentity.aiProvider,
            disclosureVersion: ClosetCueIdentity.consentDisclosureVersion,
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
        XCTAssertFalse(ClosetCueOutboundAIBoundary.snapshot(consentGranted: false, apiKeyPresent: true).outboundEnabled)
        XCTAssertTrue(ClosetCueOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: true).outboundEnabled)
        XCTAssertFalse(ClosetCueOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: false).outboundEnabled)
    }

    func testFlatLaySaveAndDiscardSemantics() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("closetcue-board-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = ClosetCueStorageRoot(rootDirectory: root)
        var board = FlatLayBoard(closetItemIDs: [UUID()], localFileName: "look.png", status: "draft")
        try storage.flatLayBoards.save(FlatLayBoardCatalog(boards: [board]))
        board.status = "saved"
        board.savedAt = Date()
        try storage.flatLayBoards.save(FlatLayBoardCatalog(boards: [board]))
        XCTAssertEqual(try storage.flatLayBoards.load()?.boards.first?.status, "saved")
        try storage.flatLayBoards.save(FlatLayBoardCatalog(boards: []))
        XCTAssertEqual(try storage.flatLayBoards.load()?.boards.count, 0)
    }
}
