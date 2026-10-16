import XCTest
import BloomkettleDomain
import AppRuntimeCore

final class BloomkettleDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(ReadingReviewBar.confirm, "Keep")
        XCTAssertEqual(ReadingReviewBar.reject, "Discard")
        XCTAssertEqual(ReadingReviewBar.edit, "Edit")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "bloomkettle.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 10)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("beans") || PrivacyUsageCopy.camera.contains("pour"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("post-brew") || PrivacyUsageCopy.photoLibrary.contains("diagnosis"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("kettle"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("V60") || PrivacyUsageCopy.speechRecognition.contains("next pour"))
        XCTAssertFalse(PrivacyUsageCopy.camera.lowercased().contains("the great coffee"))
    }

    func testBrewStoreRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("bloomkettle-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = AtomicCodableStore<BloomkettleState>(
            url: BloomkettleStores.storeURL(directory: dir, name: BloomkettleStores.stateFile)
        )
        var state = BloomkettleState()
        let session = BrewSession(
            id: "s1",
            title: "Morning V60",
            gearNote: "V60",
            complianceSnapshot: BloomkettleCompliance.bannerEN,
            createdAt: Date(),
            updatedAt: Date()
        )
        state.sessions = [session]
        state.pourSteps = [
            PourStep(id: "p1", sessionId: "s1", kind: "bloom", pourIndex: 0, targetGrams: 40, targetSeconds: 30, sortIndex: 0)
        ]
        state.grindPicks = [GrindPick(id: "g1", sessionId: "s1", grind: "medium", updatedAt: Date())]
        try store.save(state)
        let loaded = try store.load()
        XCTAssertEqual(loaded?.sessions.first?.title, "Morning V60")
        XCTAssertEqual(loaded?.pourSteps.first?.targetGrams, 40)
        XCTAssertEqual(loaded?.grindPicks.first?.grind, "medium")
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

    func testSecondCallContextCarriesPriorPourSteps() throws {
        let notes = ["bloom#0 40g/30s", "pour#1 60g/25s"]
        let encoded = try JSONEncoder().encode(notes)
        let decoded = try JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertTrue(decoded[0].contains("40g"))
    }

    func testIdentityPaletteComplianceAndAllergy() {
        XCTAssertEqual(BloomkettleIdentity.developmentBundleId, "com.lingguang.bloomkettle")
        XCTAssertEqual(BloomkettleIdentity.productDir, "bloomkettle")
        XCTAssertEqual(BloomkettleIdentity.appName, "Bloomkettle")
        XCTAssertEqual(BloomkettlePalette.primary, "#A16207")
        XCTAssertEqual(BloomkettlePalette.secondary, "#ECFDF5")
        XCTAssertEqual(BloomkettlePalette.accent, "#4F46E5")
        XCTAssertEqual(BloomkettleDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(BloomkettleDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(BloomkettleDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(BloomkettleAllergy.bannedAppCopyNames.contains("The Great Coffee App"))
        XCTAssertTrue(BloomkettleAllergy.bannedTwinShells.contains("Stirboard"))
        XCTAssertTrue(BloomkettleAllergy.bannedTwinShells.contains("Heatbar"))
        XCTAssertTrue(BloomkettleAllergy.requiredUI.contains(where: { $0.contains("funnel") }))
        XCTAssertTrue(BloomkettleAllergy.noAppIconOrLaunchScreen)
        XCTAssertTrue(BloomkettleCompliance.bannerZH.contains("家用冲煮教练"))
        XCTAssertTrue(BloomkettleCompliance.bannerEN.contains("Home brew coach"))
        XCTAssertTrue(BloomkettleCompliance.bannerEN.contains("not barista certification"))
    }

    func testKeychainServiceIdentity() {
        XCTAssertEqual(BloomkettleStores.keychainService, "com.lingguang.bloomkettle")
        XCTAssertEqual(BloomkettleStores.keychainAPIKeyAccount, "DEEPSEEK_API_KEY")
    }
}
