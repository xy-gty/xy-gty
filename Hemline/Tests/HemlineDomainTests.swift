import XCTest
import HemlineDomain
import AppRuntimeCore

final class HemlineDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(HemlineReviewControls.confirm, "Keep")
        XCTAssertEqual(HemlineReviewControls.reject, "Not this")
        XCTAssertEqual(HemlineReviewControls.edit, "Edit tags")
        XCTAssertEqual(HemlineReviewControls.FlatLayPreview.confirm, "Save look")
        XCTAssertEqual(HemlineReviewControls.FlatLayPreview.reject, "Discard")
        XCTAssertEqual(HemlineIdentity.aiProvider, "DeepSeek")
        XCTAssertEqual(HemlineIdentity.consentDisclosureVersion, "hemline.consent.v1")
        XCTAssertEqual(HemlineIdentity.developmentBundleID, "com.lingguang.hemline")
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "HomeTab", "ClosetShelf", "CaptureImport", "GarmentReview", "ClosetItemDetail",
            "StylistChat", "FlatLayBoard", "MorningBriefing", "SpeechCapture", "Settings",
            "LegalPages", "ConsentSheet"
        ]
        XCTAssertEqual(HemlineNavigation.allRoutes.map(\.rawValue), expected)
    }

    func testClosetItemPersistRejectDoesNotWriteAndRestart() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("hemline-test-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = HemlineStorageRoot(rootDirectory: root)
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
            provider: HemlineIdentity.aiProvider,
            disclosureVersion: HemlineIdentity.consentDisclosureVersion,
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
        XCTAssertFalse(HemlineOutboundAIBoundary.snapshot(consentGranted: false, apiKeyPresent: true).outboundEnabled)
        XCTAssertTrue(HemlineOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: true).outboundEnabled)
        XCTAssertFalse(HemlineOutboundAIBoundary.snapshot(consentGranted: true, apiKeyPresent: false).outboundEnabled)
    }

    func testFlatLaySaveAndDiscardSemantics() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("hemline-board-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let storage = HemlineStorageRoot(rootDirectory: root)
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
