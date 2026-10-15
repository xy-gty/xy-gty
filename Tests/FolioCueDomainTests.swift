import XCTest
import FolioCueDomain
import AppRuntimeCore

final class FolioCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(ShelfReviewControls.confirm, ["Save to Shelf", "Keep", "Use"])
        XCTAssertEqual(ShelfReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(ShelfReviewControls.edit, ["Edit title", "Edit progress"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "foliocue.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 5)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("cover"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("bookshelf"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("shelf location"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("where a book"))
        XCTAssertFalse(PrivacyUsageCopy.camera.contains("BookBuddy"))
    }

    func testShelfStoreRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("foliocue-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = ShelfStore(directory: dir)
        var state = FolioCueState()
        let session = ShelfSession(
            id: "s1",
            createdAt: Date(),
            source: "camera",
            status: "confirmed",
            shelfNote: "top lane",
            disclaimerAck: true
        )
        state.sessions = [session]
        state.bookIDs = [
            BookID(
                sessionId: "s1",
                title: "The Left Hand of Darkness",
                author: "Ursula K. Le Guin",
                editionHint: "Ace",
                confidence: 0.91,
                rationale: "cover typography",
                complianceBanner: FolioCueCompliance.personalBookshelfCoach
            )
        ]
        state.readingProgress = [
            ReadingProgress(sessionId: "s1", state: "reading", percent: 40, updatedAt: Date())
        ]
        state.spineRail = [
            SpineRailItem(bookId: "s1", spineLabel: "Left Hand", position: 0, shelfLane: "home")
        ]
        try store.save(state)
        let loaded = try store.load()
        XCTAssertEqual(loaded.sessions.first?.status, "confirmed")
        XCTAssertEqual(loaded.bookIDs.first?.title, "The Left Hand of Darkness")
        XCTAssertEqual(loaded.readingProgress.first?.percent, 40)
        XCTAssertEqual(loaded.spineRail.first?.spineLabel, "Left Hand")
    }

    func testRejectedResultNotConfirmed() throws {
        let session = ShelfSession(
            id: "s2",
            createdAt: Date(),
            source: "photos",
            status: "identified"
        )
        XCTAssertNotEqual(session.status, "confirmed")
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

    func testSecondCallContextCarriesConfirmedBooks() throws {
        let notes = ["Left Hand by Le Guin [reading 40%]", "Dune by Herbert [tbr 0%]"]
        let encoded = try JSONEncoder().encode(notes)
        let decoded = try JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertTrue(decoded[0].contains("Left Hand"))
    }

    func testIdentityPaletteAndAllergy() {
        XCTAssertEqual(FolioCueIdentity.developmentBundleId, "com.lingguang.foliocue")
        XCTAssertEqual(FolioCueIdentity.productDir, "foliocue")
        XCTAssertEqual(FolioCueIdentity.appName, "FolioCue")
        XCTAssertEqual(FolioCuePalette.primary, "#065F46")
        XCTAssertEqual(FolioCuePalette.secondary, "#FEF3C7")
        XCTAssertEqual(FolioCuePalette.accent, "#C026D3")
        XCTAssertEqual(FolioCueDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(FolioCueDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(FolioCueDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(FolioCueAllergy.bannedTwinShells.contains("LuxCue"))
        XCTAssertTrue(FolioCueAllergy.bannedTwinShells.contains("CellarCue"))
        XCTAssertTrue(FolioCueAllergy.bannedTwinShells.contains("MixCue"))
        XCTAssertTrue(FolioCueAllergy.bannedTwinShells.contains("SporeCue"))
        XCTAssertTrue(FolioCueAllergy.bannedTwinShells.contains("FrameCue"))
        XCTAssertTrue(FolioCueAllergy.bannedTwinShells.contains("NightCue"))
        XCTAssertTrue(FolioCueAllergy.bannedTwinShells.contains("ScoutCue"))
        XCTAssertTrue(FolioCueAllergy.bannedTwinShells.contains("StopCue"))
        XCTAssertTrue(FolioCueAllergy.bannedAppCopyNames.contains("BookBuddy"))
        XCTAssertTrue(FolioCueAllergy.requiredUI.contains("horizontal spine-rail shelf"))
        XCTAssertTrue(FolioCueAllergy.requiredUI.contains("large cover OCR card"))
        XCTAssertTrue(FolioCueAllergy.requiredUI.contains("reading progress bar"))
        XCTAssertTrue(FolioCueAllergy.noAppIconOrLaunchScreen)
    }

    func testComplianceDisclaimers() {
        XCTAssertEqual(FolioCueCompliance.requiredDisclaimers.count, 4)
        XCTAssertTrue(FolioCueCompliance.requiredDisclaimers[0].contains("个人藏书教练"))
        XCTAssertTrue(FolioCueCompliance.requiredDisclaimers[1].contains("非书店目录爬取"))
        XCTAssertTrue(FolioCueCompliance.requiredDisclaimers[2].contains("非全文盗版阅读器"))
        XCTAssertTrue(FolioCueCompliance.requiredDisclaimers[3].contains("非课业批改"))
    }
}
