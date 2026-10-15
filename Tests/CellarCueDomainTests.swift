import XCTest
import CellarCueDomain
import AppRuntimeCore

final class CellarCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(CellarReviewControls.confirm, ["Save Bottle", "Keep", "Use"])
        XCTAssertEqual(CellarReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(CellarReviewControls.edit, ["Edit bin", "Edit window"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "cellarcue.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 5)
    }

    func testComplianceDisclaimers() {
        XCTAssertEqual(
            CellarCueCompliance.sommelierCertificationDisclaimer,
            "非侍酒认证 / not a sommelier certification"
        )
        XCTAssertEqual(
            CellarCueCompliance.investmentAdviceDisclaimer,
            "非投资建议 / not investment advice"
        )
        XCTAssertFalse(CellarCueCompliance.sommelierCertification)
        XCTAssertFalse(CellarCueCompliance.investmentAdvice)
        XCTAssertTrue(CellarCueCompliance.ageGate21PlusOnAlcoholAdvice)
        let ensured = CellarComplianceCopy.ensureDisclaimers("Barolo window open")
        XCTAssertTrue(ensured.contains(CellarCueCompliance.sommelierCertificationDisclaimer))
        XCTAssertTrue(ensured.contains(CellarCueCompliance.investmentAdviceDisclaimer))
        XCTAssertTrue(ensured.contains(CellarCueCompliance.ageGateLabel))
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
            .appendingPathComponent("cellarcue-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = CellarStore(directory: dir)
        var state = CellarCueState()
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
        XCTAssertEqual(CellarCueIdentity.developmentBundleId, "com.lingguang.cellarcue")
        XCTAssertEqual(CellarCueIdentity.productDir, "cellarcue")
        XCTAssertEqual(CellarCueIdentity.appName, "CellarCue")
        XCTAssertEqual(CellarCuePalette.primary, "#3730A3")
        XCTAssertEqual(CellarCuePalette.secondary, "#EEF2FF")
        XCTAssertEqual(CellarCuePalette.accent, "#EA580C")
        XCTAssertEqual(CellarCueDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(CellarCueDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(CellarCueDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(CellarCueAllergy.bannedTwinShells.contains("MixCue"))
        XCTAssertTrue(CellarCueAllergy.bannedTwinShells.contains("SporeCue"))
        XCTAssertTrue(CellarCueAllergy.bannedTwinShells.contains("WingCue"))
        XCTAssertTrue(CellarCueAllergy.bannedTwinShells.contains("FrameCue"))
        XCTAssertTrue(CellarCueAllergy.bannedTwinShells.contains("RuleCue"))
        XCTAssertTrue(CellarCueAllergy.bannedTwinShells.contains("StopCue"))
        XCTAssertTrue(CellarCueAllergy.bannedCompetitorNames.contains("Vinocell"))
        XCTAssertTrue(CellarCueAllergy.requiredUI.contains("cellar row/bin grid"))
        XCTAssertTrue(CellarCueAllergy.requiredUI.contains("large label-OCR hero card"))
        XCTAssertTrue(CellarCueAllergy.requiredUI.contains("drinking-window aging timeline"))
        XCTAssertEqual(CellarCuePermissions.required.count, 4)
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
        XCTAssertTrue(brief.scriptText.contains(CellarCueCompliance.sommelierCertificationDisclaimer))
        XCTAssertTrue(brief.scriptText.contains(CellarCueCompliance.investmentAdviceDisclaimer))
        XCTAssertTrue(brief.scriptText.contains(CellarCueCompliance.ageGateLabel))
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
        XCTAssertTrue(CellarCueNavigation.isValid(.cellarHome))
        XCTAssertTrue(CellarCueNavigation.isValid(.labelResult))
        XCTAssertTrue(CellarCueNavigation.isValid(.windowChat))
        XCTAssertTrue(CellarCueNavigation.isValid(.rackCard))
        XCTAssertTrue(CellarCueNavigation.isValid(.pullBrief))
        XCTAssertTrue(CellarCueNavigation.isValid(.voiceNote))
        XCTAssertTrue(CellarCueNavigation.isValid(.aiConsent))
        XCTAssertTrue(CellarCueNavigation.isValid(.settings))
        XCTAssertTrue(CellarCueNavigation.isValid(.legal))
    }
}
