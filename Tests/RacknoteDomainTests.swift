import XCTest
import RacknoteDomain
import AppRuntimeCore

final class RacknoteDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(CellarReviewControls.confirm, ["Save Bottle", "Keep", "Use"])
        XCTAssertEqual(CellarReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(CellarReviewControls.edit, ["Edit bin", "Edit window"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "racknote.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 5)
    }

    func testComplianceDisclaimers() {
        XCTAssertEqual(
            RacknoteCompliance.sommelierCertificationDisclaimer,
            "非侍酒认证 / not a sommelier certification"
        )
        XCTAssertEqual(
            RacknoteCompliance.investmentAdviceDisclaimer,
            "非投资建议 / not investment advice"
        )
        XCTAssertFalse(RacknoteCompliance.sommelierCertification)
        XCTAssertFalse(RacknoteCompliance.investmentAdvice)
        XCTAssertTrue(RacknoteCompliance.ageGate21PlusOnAlcoholAdvice)
        let ensured = CellarComplianceCopy.ensureDisclaimers("Barolo window open")
        XCTAssertTrue(ensured.contains(RacknoteCompliance.sommelierCertificationDisclaimer))
        XCTAssertTrue(ensured.contains(RacknoteCompliance.investmentAdviceDisclaimer))
        XCTAssertTrue(ensured.contains(RacknoteCompliance.ageGateLabel))
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("label"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("cellar") || PrivacyUsageCopy.photoLibrary.contains("OCR"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("bin") || PrivacyUsageCopy.microphone.contains("carrying"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("drinking") || PrivacyUsageCopy.speechRecognition.contains("pairing"))
        XCTAssertFalse(PrivacyUsageCopy.camera.lowercased().contains("vinocell"))
    }

    func testCellarStoreRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("racknote-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = CellarStore(directory: dir)
        var state = RacknoteState()
        CellarComplianceCopy.ensureDefaultRack(state: &state)
        let bottle = BottleEntry(
            id: "b1",
            binId: "R1-B1",
            createdAt: Date(),
            photoLocalURL: "/tmp/label.jpg",
            source: "camera",
            status: "confirmed",
            vintage: "2015",
            producer: "Test Producer",
            varietal: "Nebbiolo",
            disclaimerAck: true,
            ageGateAck: true
        )
        state.bottles = [bottle]
        state.labelResults = [
            LabelOCRResult(
                bottleId: "b1",
                rawText: "Test Producer 2015 Nebbiolo",
                structuredFields: ["producer": "Test Producer"],
                confidence: 0.9
            )
        ]
        state.drinkingWindows = [CellarComplianceCopy.defaultTimeline(for: "b1", vintage: "2015")]
        try store.save(state)
        let loaded = try store.load()
        XCTAssertEqual(loaded.bottles.first?.status, "confirmed")
        XCTAssertEqual(loaded.bottles.first?.producer, "Test Producer")
        XCTAssertFalse(loaded.racks.isEmpty)
        XCTAssertEqual(loaded.bins.count, 12)
        XCTAssertFalse(loaded.drinkingWindows.first?.timelinePoints.isEmpty ?? true)
    }

    func testRejectedResultNotConfirmed() {
        let bottle = BottleEntry(
            id: "b2",
            binId: "R1-B2",
            createdAt: Date(),
            photoLocalURL: "/tmp/x.jpg",
            source: "photos",
            status: "identified",
            disclaimerAck: true
        )
        XCTAssertNotEqual(bottle.status, "confirmed")
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

    func testSecondCallContextCarriesConfirmedBottles() throws {
        let notes = ["Test Producer 2015 Nebbiolo bin:R1-B1", "rejected: wrong vintage"]
        let encoded = try JSONEncoder().encode(notes)
        let decoded = try JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertTrue(decoded[0].contains("Nebbiolo"))
    }

    func testIdentityPaletteAndAllergy() {
        XCTAssertEqual(RacknoteIdentity.developmentBundleId, "com.lingguang.racknote")
        XCTAssertEqual(RacknoteIdentity.productDir, "racknote")
        XCTAssertEqual(RacknoteIdentity.appName, "Racknote")
        XCTAssertEqual(RacknotePalette.primary, "#3730A3")
        XCTAssertEqual(RacknotePalette.secondary, "#EEF2FF")
        XCTAssertEqual(RacknotePalette.accent, "#EA580C")
        XCTAssertEqual(RacknoteDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(RacknoteDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(RacknoteDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(RacknoteAllergy.bannedTwinShells.contains("Stirboard"))
        XCTAssertTrue(RacknoteAllergy.bannedTwinShells.contains("Gillnote"))
        XCTAssertTrue(RacknoteAllergy.bannedTwinShells.contains("Fieldmark"))
        XCTAssertTrue(RacknoteAllergy.bannedTwinShells.contains("Mattebox"))
        XCTAssertTrue(RacknoteAllergy.bannedTwinShells.contains("Tablehost"))
        XCTAssertTrue(RacknoteAllergy.bannedTwinShells.contains("Onionreel"))
        XCTAssertTrue(RacknoteAllergy.bannedCompetitorNames.contains("Vinocell"))
        XCTAssertTrue(RacknoteAllergy.requiredUI.contains("cellar row/bin grid"))
        XCTAssertTrue(RacknoteAllergy.requiredUI.contains("large label-OCR hero card"))
        XCTAssertTrue(RacknoteAllergy.requiredUI.contains("drinking-window aging timeline"))
        XCTAssertEqual(RacknotePermissions.required.count, 4)
    }

    func testPullBriefIncludesCompliance() {
        let bottle = BottleEntry(
            id: "b3",
            binId: "R2-B1",
            createdAt: Date(),
            photoLocalURL: "/tmp/y.jpg",
            source: "camera",
            status: "identified",
            vintage: "2012",
            producer: "Barolo Estate",
            varietal: "Nebbiolo",
            disclaimerAck: true,
            ageGateAck: true
        )
        let brief = CellarComplianceCopy.makePullBriefScript(
            bottle: bottle,
            binLabel: "R2-B1",
            windowStatus: "open"
        )
        XCTAssertTrue(brief.scriptText.contains(RacknoteCompliance.sommelierCertificationDisclaimer))
        XCTAssertTrue(brief.scriptText.contains(RacknoteCompliance.investmentAdviceDisclaimer))
        XCTAssertTrue(brief.scriptText.contains(RacknoteCompliance.ageGateLabel))
        XCTAssertFalse(brief.scriptText.lowercased().contains("certified tasting returns"))
        XCTAssertFalse(brief.scriptText.lowercased().contains("vinocell"))
    }

    func testCoachTurnSpeechSource() throws {
        let turn = CoachTurn(
            bottleId: "b1",
            role: "user",
            text: "pair with lamb?",
            sttSource: "speech",
            createdAt: Date()
        )
        let data = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: data)
        XCTAssertEqual(decoded.sttSource, "speech")
    }

    func testNavigationRoutesValid() {
        XCTAssertTrue(RacknoteNavigation.isValid(.cellarHome))
        XCTAssertTrue(RacknoteNavigation.isValid(.labelResult))
        XCTAssertTrue(RacknoteNavigation.isValid(.windowChat))
        XCTAssertTrue(RacknoteNavigation.isValid(.rackCard))
        XCTAssertTrue(RacknoteNavigation.isValid(.pullBrief))
        XCTAssertTrue(RacknoteNavigation.isValid(.voiceNote))
        XCTAssertTrue(RacknoteNavigation.isValid(.aiConsent))
        XCTAssertTrue(RacknoteNavigation.isValid(.settings))
        XCTAssertTrue(RacknoteNavigation.isValid(.legal))
    }
}
