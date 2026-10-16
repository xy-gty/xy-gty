import XCTest
import SpinewellDomain
import AppRuntimeCore

final class SpinewellDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(ShelfReviewControls.confirm, ["Save to Shelf", "Keep", "Use"])
        XCTAssertEqual(ShelfReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(ShelfReviewControls.edit, ["Edit title", "Edit progress"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "spinewell.consent.v1")
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
            .appendingPathComponent("spinewell-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = ShelfStore(directory: dir)
        var state = SpinewellState()
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
                complianceBanner: SpinewellCompliance.personalBookshelfCoach
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
        XCTAssertEqual(SpinewellIdentity.developmentBundleId, "com.lingguang.spinewell")
        XCTAssertEqual(SpinewellIdentity.productDir, "spinewell")
        XCTAssertEqual(SpinewellIdentity.appName, "Spinewell")
        XCTAssertEqual(SpinewellPalette.primary, "#065F46")
        XCTAssertEqual(SpinewellPalette.secondary, "#FEF3C7")
        XCTAssertEqual(SpinewellPalette.accent, "#C026D3")
        XCTAssertEqual(SpinewellDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(SpinewellDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(SpinewellDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(SpinewellAllergy.bannedTwinShells.contains("Zonelight"))
        XCTAssertTrue(SpinewellAllergy.bannedTwinShells.contains("Racknote"))
        XCTAssertTrue(SpinewellAllergy.bannedTwinShells.contains("Stirboard"))
        XCTAssertTrue(SpinewellAllergy.bannedTwinShells.contains("Gillnote"))
        XCTAssertTrue(SpinewellAllergy.bannedTwinShells.contains("Mattebox"))
        XCTAssertTrue(SpinewellAllergy.bannedTwinShells.contains("Shutterdusk"))
        XCTAssertTrue(SpinewellAllergy.bannedTwinShells.contains("Sunbrief"))
        XCTAssertTrue(SpinewellAllergy.bannedTwinShells.contains("Onionreel"))
        XCTAssertTrue(SpinewellAllergy.bannedAppCopyNames.contains("BookBuddy"))
        XCTAssertTrue(SpinewellAllergy.requiredUI.contains("horizontal spine-rail shelf"))
        XCTAssertTrue(SpinewellAllergy.requiredUI.contains("large cover OCR card"))
        XCTAssertTrue(SpinewellAllergy.requiredUI.contains("reading progress bar"))
        XCTAssertTrue(SpinewellAllergy.noAppIconOrLaunchScreen)
    }

    func testComplianceDisclaimers() {
        XCTAssertEqual(SpinewellCompliance.requiredDisclaimers.count, 4)
        XCTAssertTrue(SpinewellCompliance.requiredDisclaimers[0].contains("个人藏书教练"))
        XCTAssertTrue(SpinewellCompliance.requiredDisclaimers[1].contains("非书店目录爬取"))
        XCTAssertTrue(SpinewellCompliance.requiredDisclaimers[2].contains("非全文盗版阅读器"))
        XCTAssertTrue(SpinewellCompliance.requiredDisclaimers[3].contains("非课业批改"))
    }
}
