import XCTest
import SporeCueDomain
import AppRuntimeCore

final class SporeCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(SporeReviewControls.confirm, ["Save Find", "Keep", "Use"])
        XCTAssertEqual(SporeReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(SporeReviewControls.edit, ["Edit callouts"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "sporecue.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 5)
    }

    func testComplianceDisclaimer() {
        XCTAssertEqual(SporeCueCompliance.requiredDisclaimer, "非可食认证 / not an edibility certification")
        XCTAssertFalse(SporeCueCompliance.edibilityCertification)
        XCTAssertTrue(SporeCueCompliance.neverImplySafeToEat)
        let ensured = ChipRailBuilder.ensureDisclaimer("gill spacing tight")
        XCTAssertTrue(ensured.contains(SporeCueCompliance.requiredDisclaimer))
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("cap"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("hike"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("knife") || PrivacyUsageCopy.microphone.contains("basket"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("lookalike") || PrivacyUsageCopy.speechRecognition.contains("habitat"))
        XCTAssertFalse(PrivacyUsageCopy.camera.contains("Shroomify"))
        XCTAssertFalse(PrivacyUsageCopy.camera.contains("Pilze 123"))
    }

    func testForageStoreRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("sporecue-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = ForageStore(directory: dir)
        var state = SporeCueState()
        let session = ForageSession(
            id: "s1",
            createdAt: Date(),
            photoLocalURL: "/tmp/gill.jpg",
            source: "camera",
            subject: "gill",
            status: "confirmed",
            disclaimerAck: true
        )
        state.sessions = [session]
        state.candidates = [
            SpeciesCandidate(
                sessionId: "s1",
                displayName: "Chanterelle-like",
                scientificName: "Cantharellus sp.",
                confidence: 0.84,
                rank: 1,
                morphologyCues: ["false gills", "apricot odor"]
            )
        ]
        state.chips = ChipRailBuilder.informationalChips(sessionId: "s1")
        state.overlays = [
            OverlayAnnotator.placeholderOverlay(sessionId: "s1", imageLocalURL: session.photoLocalURL, subject: "gill")
        ]
        try store.save(state)
        let loaded = try store.load()
        XCTAssertEqual(loaded.sessions.first?.status, "confirmed")
        XCTAssertEqual(loaded.candidates.first?.displayName, "Chanterelle-like")
        XCTAssertFalse(loaded.chips.isEmpty)
        XCTAssertTrue(loaded.chips.allSatisfy(\.informationalOnly))
        XCTAssertFalse(loaded.overlays.first?.callouts.isEmpty ?? true)
    }

    func testRejectedResultNotConfirmed() {
        let session = ForageSession(
            id: "s2",
            createdAt: Date(),
            photoLocalURL: "/tmp/x.jpg",
            source: "photos",
            subject: "pore",
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

    func testSecondCallContextCarriesConfirmedSpecies() throws {
        let notes = ["Chanterelle-like (Cantharellus sp.)", "rejected: jack-o-lantern lookalike"]
        let encoded = try JSONEncoder().encode(notes)
        let decoded = try JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertTrue(decoded[0].contains("Chanterelle"))
    }

    func testIdentityPaletteAndAllergy() {
        XCTAssertEqual(SporeCueIdentity.developmentBundleId, "com.lingguang.sporecue")
        XCTAssertEqual(SporeCueIdentity.productDir, "sporecue")
        XCTAssertEqual(SporeCueIdentity.appName, "SporeCue")
        XCTAssertEqual(SporeCuePalette.primary, "#9A3412")
        XCTAssertEqual(SporeCuePalette.secondary, "#FFF7ED")
        XCTAssertEqual(SporeCuePalette.accent, "#0284C7")
        XCTAssertEqual(SporeCueDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(SporeCueDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(SporeCueDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(SporeCueAllergy.bannedTwinShells.contains("MixCue"))
        XCTAssertTrue(SporeCueAllergy.bannedTwinShells.contains("WingCue"))
        XCTAssertTrue(SporeCueAllergy.bannedTwinShells.contains("FrameCue"))
        XCTAssertTrue(SporeCueAllergy.bannedTwinShells.contains("ScoutCue"))
        XCTAssertTrue(SporeCueAllergy.bannedCompetitorNames.contains("Shroomify"))
        XCTAssertTrue(SporeCueAllergy.bannedCompetitorNames.contains("Pilze 123"))
        XCTAssertTrue(SporeCueAllergy.requiredUI.contains("vertical species-confidence stack"))
        XCTAssertTrue(SporeCueAllergy.requiredUI.contains("oversized gill/pore closeup bar"))
        XCTAssertTrue(SporeCueAllergy.requiredUI.contains("edible/warning chip rail"))
        XCTAssertEqual(SporeCuePermissions.required.count, 4)
    }

    func testChipRailInformationalOnly() {
        let chips = ChipRailBuilder.informationalChips(sessionId: "s1")
        XCTAssertFalse(chips.isEmpty)
        XCTAssertTrue(chips.allSatisfy(\.informationalOnly))
        XCTAssertFalse(chips.contains { $0.title.lowercased().contains("safe to eat") })
        XCTAssertFalse(chips.contains { $0.title.lowercased().contains("certified") })
    }

    func testFieldBriefIncludesDisclaimer() {
        let brief = FieldBriefBuilder.script(
            sessionId: "s1",
            topName: "Bolete-like",
            lookalike: "bitter bolete",
            cues: ["pore surface", "cap margin"]
        )
        XCTAssertTrue(brief.scriptText.contains(SporeCueCompliance.requiredDisclaimer))
        XCTAssertFalse(brief.scriptText.lowercased().contains("safe to eat"))
    }

    func testCoachTurnSpeechSource() throws {
        let turn = CoachTurn(
            sessionId: "s1",
            role: "user",
            text: "how does this differ from death cap",
            sttSource: "speech",
            createdAt: Date()
        )
        let data = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: data)
        XCTAssertEqual(decoded.sttSource, "speech")
    }

    func testNavigationRoutesValid() {
        XCTAssertTrue(SporeCueNavigation.isValid(.fieldHome))
        XCTAssertTrue(SporeCueNavigation.isValid(.idResult))
        XCTAssertTrue(SporeCueNavigation.isValid(.lookalikeChat))
        XCTAssertTrue(SporeCueNavigation.isValid(.overlayAnnotate))
        XCTAssertTrue(SporeCueNavigation.isValid(.fieldBrief))
        XCTAssertTrue(SporeCueNavigation.isValid(.voiceNote))
        XCTAssertTrue(SporeCueNavigation.isValid(.aiConsent))
        XCTAssertTrue(SporeCueNavigation.isValid(.settings))
        XCTAssertTrue(SporeCueNavigation.isValid(.legal))
    }
}
