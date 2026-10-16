import XCTest
import StirboardDomain
import AppRuntimeCore

final class StirboardDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(MixReviewControls.confirm, ["Save Mix", "Keep", "Use"])
        XCTAssertEqual(MixReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(MixReviewControls.edit, ["Edit pour steps"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "stirboard.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 5)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("bottle"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("bar-shelf"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("shake"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("substitute"))
        XCTAssertFalse(PrivacyUsageCopy.camera.contains("Cocktail Party"))
        XCTAssertFalse(PrivacyUsageCopy.camera.contains("Bevnap"))
    }

    func testMixStoreRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("stirboard-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = MixStore(directory: dir)
        var state = StirboardState()
        let session = MixSession(
            id: "s1",
            createdAt: Date(),
            photoLocalURL: "/tmp/bottle.jpg",
            source: "camera",
            subject: "bottle",
            status: "confirmed"
        )
        state.sessions = [session]
        state.candidates = [
            SpiritCandidate(
                sessionId: "s1",
                displayName: "London Dry",
                baseSpirit: "gin",
                confidence: 0.91,
                rank: 1,
                labelCues: ["juniper", "clear glass"]
            )
        ]
        let recipe = PourBoardBuilder.placeholderRecipe(sessionId: "s1", baseSpirit: "gin")
        state.recipes = [recipe]
        try store.save(state)
        let loaded = try store.load()
        XCTAssertEqual(loaded.sessions.first?.status, "confirmed")
        XCTAssertEqual(loaded.candidates.first?.baseSpirit, "gin")
        XCTAssertEqual(loaded.recipes.first?.steps.count, 5)
        XCTAssertFalse(loaded.recipes.first?.garnishChips.isEmpty ?? true)
    }

    func testRejectedResultNotConfirmed() throws {
        let session = MixSession(
            id: "s2",
            createdAt: Date(),
            photoLocalURL: "/tmp/x.jpg",
            source: "photos",
            subject: "label",
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

    func testSecondCallContextCarriesConfirmedSpirits() throws {
        let spirits = ["London Dry (gin)", "Repos blanc"]
        let encoded = try JSONEncoder().encode(spirits)
        let decoded = try JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertTrue(decoded.contains("London Dry (gin)"))
    }

    func testIdentityPaletteAndAllergy() {
        XCTAssertEqual(StirboardIdentity.developmentBundleId, "com.lingguang.stirboard")
        XCTAssertEqual(StirboardIdentity.productDir, "stirboard")
        XCTAssertEqual(StirboardIdentity.appName, "Stirboard")
        XCTAssertEqual(StirboardPalette.primary, "#E11D48")
        XCTAssertEqual(StirboardPalette.secondary, "#FFF1F2")
        XCTAssertEqual(StirboardPalette.accent, "#CA8A04")
        XCTAssertEqual(StirboardDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(StirboardDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(StirboardDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(StirboardAllergy.bannedTwinShells.contains("Fieldmark"))
        XCTAssertTrue(StirboardAllergy.bannedTwinShells.contains("Mattebox"))
        XCTAssertTrue(StirboardAllergy.bannedTwinShells.contains("Sunbrief"))
        XCTAssertTrue(StirboardAllergy.bannedTwinShells.contains("Tablehost"))
        XCTAssertTrue(StirboardAllergy.bannedTwinShells.contains("Onionreel"))
        XCTAssertTrue(StirboardAllergy.bannedTwinShells.contains("Hemline"))
        XCTAssertTrue(StirboardAllergy.bannedCompetitorNames.contains("Cocktail Party"))
        XCTAssertTrue(StirboardAllergy.requiredUI.contains("vertical bottle-rail"))
        XCTAssertTrue(StirboardAllergy.requiredUI.contains("large next-pour card"))
        XCTAssertTrue(StirboardAllergy.requiredUI.contains("garnish chip row"))
        XCTAssertEqual(StirboardPermissions.required.count, 4)
    }

    func testPourBoardAdvanceAndCurrentStep() {
        let recipe = PourBoardBuilder.placeholderRecipe(sessionId: "s1", baseSpirit: "rum")
        let first = PourBoardBuilder.currentStep(in: recipe, ordinal: 1)
        XCTAssertEqual(first?.ordinal, 1)
        let next = PourBoardBuilder.advanceOrdinal(current: 1, recipe: recipe)
        XCTAssertEqual(next, 2)
        let last = PourBoardBuilder.advanceOrdinal(current: 5, recipe: recipe)
        XCTAssertEqual(last, 5)
    }

    func testCoachTurnSpeechSource() throws {
        let turn = CoachTurn(
            sessionId: "s1",
            role: "user",
            text: "what can I sub for Cointreau",
            sttSource: "speech",
            createdAt: Date()
        )
        let data = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: data)
        XCTAssertEqual(decoded.sttSource, "speech")
    }

    func testGarnishChipPersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("stirboard-chip-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[GarnishChip]>(url: url)
        let chip = GarnishChip(
            sessionId: "s1",
            recipeId: "r1",
            name: "Citrus twist",
            placed: true,
            accentColor: StirboardPalette.accent
        )
        try store.save([chip])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.name, "Citrus twist")
        XCTAssertTrue(loaded.first?.placed ?? false)
    }
}
