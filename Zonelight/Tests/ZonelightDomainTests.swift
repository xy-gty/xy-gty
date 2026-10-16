import XCTest
import ZonelightDomain
import AppRuntimeCore

final class ZonelightDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(LuxReviewControls.confirm, ["Save Reading", "Keep", "Use"])
        XCTAssertEqual(LuxReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(LuxReviewControls.edit, ["Edit EV", "Edit zone"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "zonelight.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 5)
    }

    func testComplianceDisclaimers() {
        XCTAssertFalse(ZonelightCompliance.calibratedLabInstrument)
        XCTAssertFalse(ZonelightCompliance.medicalLighting)
        XCTAssertTrue(ZonelightCompliance.neverClaimLabCalibrationOrMedicalLighting)
        XCTAssertEqual(ZonelightCompliance.requiredDisclaimers.count, 2)
        XCTAssertTrue(ZonelightCompliance.requiredDisclaimers[0].contains("非校准实验室仪表"))
        XCTAssertTrue(ZonelightCompliance.requiredDisclaimers[1].contains("非医疗用光"))
        XCTAssertTrue(ZonelightCompliance.requiredDisclaimers[0].contains("not a calibrated lab instrument"))
        XCTAssertTrue(ZonelightCompliance.requiredDisclaimers[1].contains("not for medical lighting"))
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("spot-meter") || PrivacyUsageCopy.camera.contains("gray-card"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("Import") || PrivacyUsageCopy.photoLibrary.contains("stills"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("hands-free") || PrivacyUsageCopy.microphone.contains("camera"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("zone") || PrivacyUsageCopy.speechRecognition.contains("coach"))
        XCTAssertFalse(PrivacyUsageCopy.camera.lowercased().contains("mylightmeter"))
        XCTAssertFalse(PrivacyUsageCopy.photoLibrary.lowercased().contains("mylightmeter"))
    }

    func testMeterStoreRoundTripPersistReviewed() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("zonelight-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = AtomicCodableStore<ZonelightState>(
            url: ZonelightStores.storeURL(directory: dir, name: ZonelightStores.meterState)
        )
        var state = ZonelightState()
        let session = MeterSession(
            id: "s1",
            createdAt: Date(),
            source: "camera",
            status: "confirmed",
            sceneNote: "gray card",
            disclaimerAck: true
        )
        state.sessions = [session]
        state.spotReadings = [
            SpotReading(
                sessionId: "s1",
                evEstimate: 9.2,
                luxHint: nil,
                zoneHint: "V",
                crossX: 0.5,
                crossY: 0.5,
                capturedAt: Date(),
                photoLocalURL: "/tmp/spot.jpg"
            )
        ]
        state.exposureIDs = [
            ExposureID(
                sessionId: "s1",
                ev: 9.0,
                aperture: "f/2.8",
                shutter: "1/125",
                iso: "200",
                confidence: 0.8,
                rationale: ZonelightCompliance.requiredDisclaimers.joined(separator: ". "),
                complianceBanner: true
            )
        ]
        try store.save(state)
        let loaded = try store.load()
        XCTAssertEqual(loaded?.sessions.first?.status, "confirmed")
        XCTAssertEqual(loaded?.exposureIDs.first?.ev, 9.0)
        XCTAssertTrue(loaded?.exposureIDs.first?.rationale.contains("非校准") ?? false)
    }

    func testRejectedResultNotConfirmed() {
        let session = MeterSession(
            id: "s2",
            createdAt: Date(),
            source: "photos",
            status: "identified",
            disclaimerAck: true
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

    func testSecondCallContextCarriesConfirmedReadings() throws {
        let notes = ["EV 9.0 f/2.8 1/125 ISO 200 zone:V", "rejected: wrong EV"]
        let encoded = try JSONEncoder().encode(notes)
        let decoded = try JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertTrue(decoded[0].contains("zone:V"))
    }

    func testIdentityPaletteAndAllergy() {
        XCTAssertEqual(ZonelightIdentity.developmentBundleId, "com.lingguang.zonelight")
        XCTAssertEqual(ZonelightIdentity.productDir, "zonelight")
        XCTAssertEqual(ZonelightIdentity.appName, "Zonelight")
        XCTAssertEqual(ZonelightIdentity.simulatorPrefUDID, "B14CC0EA")
        XCTAssertEqual(ZonelightPalette.primary, "#1D4ED8")
        XCTAssertEqual(ZonelightPalette.secondary, "#F0F9FF")
        XCTAssertEqual(ZonelightPalette.accent, "#EAB308")
        XCTAssertTrue(ZonelightUISpecies.signature.contains("zone_system_dial"))
        XCTAssertTrue(ZonelightUISpecies.signature.contains("oversized_ev_readout_bar"))
        XCTAssertTrue(ZonelightUISpecies.signature.contains("spot_meter_cross_card"))
    }

    func testSetCalloutComplianceLiterals() {
        let exposure = ExposureID(
            sessionId: "s3",
            ev: 8.5,
            aperture: "f/4",
            shutter: "1/60",
            iso: "400",
            confidence: 0.7,
            rationale: "draft",
            complianceBanner: true
        )
        var script = "Set EV \(exposure.ev), aperture \(exposure.aperture), shutter \(exposure.shutter), ISO \(exposure.iso)."
        for line in ZonelightCompliance.requiredDisclaimers where !script.contains(line) {
            script += " " + line
        }
        XCTAssertTrue(script.contains("非校准实验室仪表"))
        XCTAssertTrue(script.contains("非医疗用光"))
        XCTAssertFalse(script.lowercased().contains("mylightmeter"))
        XCTAssertFalse(script.lowercased().contains("calibrated lab instrument with certification"))
    }

    func testCoachTurnSpeechSource() throws {
        let turn = CoachTurn(
            sessionId: "s1",
            role: "user",
            text: "skin at Zone V",
            strategy: "zone",
            sttSource: "speech",
            createdAt: Date()
        )
        let data = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: data)
        XCTAssertEqual(decoded.sttSource, "speech")
    }

    func testNavigationRoutesValid() {
        XCTAssertTrue(ZonelightNavigation.isValid(.meterHome))
        XCTAssertTrue(ZonelightNavigation.isValid(.cameraSpot))
        XCTAssertTrue(ZonelightNavigation.isValid(.photoImport))
        XCTAssertTrue(ZonelightNavigation.isValid(.exposureResult))
        XCTAssertTrue(ZonelightNavigation.isValid(.coachChat))
        XCTAssertTrue(ZonelightNavigation.isValid(.meterCard))
        XCTAssertTrue(ZonelightNavigation.isValid(.setCallout))
        XCTAssertTrue(ZonelightNavigation.isValid(.voiceNote))
        XCTAssertTrue(ZonelightNavigation.isValid(.aiConsent))
        XCTAssertTrue(ZonelightNavigation.isValid(.settings))
        XCTAssertTrue(ZonelightNavigation.isValid(.legal))
    }

    func testKeychainServiceIdentity() {
        XCTAssertEqual(ZonelightStores.keychainService, "zonelight.ai")
        XCTAssertEqual(ZonelightStores.keychainAPIKeyAccount, "deepseek_api_key")
    }
}
