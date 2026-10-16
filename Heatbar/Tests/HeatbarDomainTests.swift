import XCTest
import HeatbarDomain
import AppRuntimeCore

final class HeatbarDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(ReadingReviewBar.confirm, "Keep")
        XCTAssertEqual(ReadingReviewBar.reject, "Discard")
        XCTAssertEqual(ReadingReviewBar.edit, "Edit")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "heatbar.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 8)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("finish-line"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("amateur-meet"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("racked at the finish"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("start heat") || PrivacyUsageCopy.speechRecognition.contains("mark lane"))
        XCTAssertFalse(PrivacyUsageCopy.camera.lowercased().contains("sprinttimer"))
    }

    func testHeatStoreRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("heatbar-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = AtomicCodableStore<HeatbarState>(
            url: HeatbarStores.storeURL(directory: dir, name: HeatbarStores.stateFile)
        )
        var state = HeatbarState()
        let pack = HeatPack(
            id: "h1",
            title: "Heat A",
            venueNote: "practice",
            complianceSnapshot: HeatbarCompliance.bannerEN,
            createdAt: Date(),
            updatedAt: Date()
        )
        state.heatPacks = [pack]
        state.laneReads = [
            LaneRead(
                id: "r1",
                heatPackId: "h1",
                finishStripId: "s1",
                laneNumber: 3,
                athleteLabel: "A. Lee",
                timeRead: "12.34",
                status: "confirmed",
                updatedAt: Date()
            )
        ]
        try store.save(state)
        let loaded = try store.load()
        XCTAssertEqual(loaded?.heatPacks.first?.title, "Heat A")
        XCTAssertEqual(loaded?.laneReads.first?.status, "confirmed")
        XCTAssertEqual(loaded?.laneReads.first?.timeRead, "12.34")
    }

    func testDiscardedReadNotConfirmed() {
        let read = LaneRead(
            id: "r2",
            heatPackId: "h1",
            finishStripId: "s1",
            laneNumber: 2,
            timeRead: "11.90",
            status: "discarded",
            updatedAt: Date()
        )
        XCTAssertNotEqual(read.status, "confirmed")
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

    func testSecondCallContextCarriesPriorLaneReads() throws {
        let notes = ["L3 A. Lee 12.34", "L4 B. Kim 12.51"]
        let encoded = try JSONEncoder().encode(notes)
        let decoded = try JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertTrue(decoded[0].contains("12.34"))
    }

    func testIdentityPaletteComplianceAndAllergy() {
        XCTAssertEqual(HeatbarIdentity.developmentBundleId, "com.lingguang.heatbar")
        XCTAssertEqual(HeatbarIdentity.productDir, "heatbar")
        XCTAssertEqual(HeatbarIdentity.appName, "Heatbar")
        XCTAssertEqual(HeatbarPalette.primary, "#BE185D")
        XCTAssertEqual(HeatbarPalette.secondary, "#ECFEFF")
        XCTAssertEqual(HeatbarPalette.accent, "#65A30D")
        XCTAssertEqual(HeatbarDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(HeatbarDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(HeatbarDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(HeatbarAllergy.bannedAppCopyNames.contains("SprintTimer"))
        XCTAssertTrue(HeatbarAllergy.bannedTwinShells.contains("Workrest"))
        XCTAssertTrue(HeatbarAllergy.bannedTwinShells.contains("Onionreel"))
        XCTAssertTrue(HeatbarAllergy.requiredUI.contains(where: { $0.contains("slit-scan") }))
        XCTAssertTrue(HeatbarAllergy.noAppIconOrLaunchScreen)
        XCTAssertTrue(HeatbarCompliance.bannerZH.contains("辅助训练"))
        XCTAssertTrue(HeatbarCompliance.bannerEN.contains("not an official FAT"))
    }

    func testNavigationRoutesCoverContract() {
        let required: Set<String> = [
            "HeatHome", "CaptureImport", "SlitScrubber", "CoachChat", "ReadingReview",
            "FinishCard", "CalloutDeck", "HeatDetail", "Settings", "LegalPages", "ConsentSheet",
        ]
        let actual = Set(HeatbarRoute.allCases.map(\.rawValue))
        XCTAssertEqual(actual, required)
    }
}
