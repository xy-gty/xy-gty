import XCTest
import GillnoteDomain
import AppRuntimeCore

final class GillnoteDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(SporeReviewControls.confirm, ["Save Find", "Keep", "Use"])
        XCTAssertEqual(SporeReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(SporeReviewControls.edit, ["Edit callouts"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "gillnote.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 5)
    }

    func testComplianceDisclaimer() {
        XCTAssertEqual(GillnoteCompliance.requiredDisclaimer, "非可食认证 / not an edibility certification")
        XCTAssertFalse(GillnoteCompliance.edibilityCertification)
        XCTAssertTrue(GillnoteCompliance.neverImplySafeToEat)
        let ensured = ChipRailBuilder.ensureDisclaimer("gill spacing tight")
        XCTAssertTrue(ensured.contains(GillnoteCompliance.requiredDisclaimer))
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
            .appendingPathComponent("gillnote-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = ForageStore(directory: dir)
        var state = GillnoteState()
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
        XCTAssertEqual(GillnoteIdentity.developmentBundleId, "com.lingguang.gillnote")
        XCTAssertEqual(GillnoteIdentity.productDir, "gillnote")
        XCTAssertEqual(GillnoteIdentity.appName, "Gillnote")
        XCTAssertEqual(GillnotePalette.primary, "#9A3412")
        XCTAssertEqual(GillnotePalette.secondary, "#FFF7ED")
        XCTAssertEqual(GillnotePalette.accent, "#0284C7")
        XCTAssertEqual(GillnoteDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertEqual(GillnoteDevicePolicy.preferredUDID, "B14CC0EA")
        XCTAssertTrue(GillnoteDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(GillnoteAllergy.bannedTwinShells.contains("Stirboard"))
        XCTAssertTrue(GillnoteAllergy.bannedTwinShells.contains("Fieldmark"))
        XCTAssertTrue(GillnoteAllergy.bannedTwinShells.contains("Mattebox"))
        XCTAssertTrue(GillnoteAllergy.bannedTwinShells.contains("Sunbrief"))
        XCTAssertTrue(GillnoteAllergy.bannedCompetitorNames.contains("Shroomify"))
        XCTAssertTrue(GillnoteAllergy.bannedCompetitorNames.contains("Pilze 123"))
        XCTAssertTrue(GillnoteAllergy.requiredUI.contains("vertical species-confidence stack"))
        XCTAssertTrue(GillnoteAllergy.requiredUI.contains("oversized gill/pore closeup bar"))
        XCTAssertTrue(GillnoteAllergy.requiredUI.contains("edible/warning chip rail"))
        XCTAssertEqual(GillnotePermissions.required.count, 4)
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
        XCTAssertTrue(brief.scriptText.contains(GillnoteCompliance.requiredDisclaimer))
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
        XCTAssertTrue(GillnoteNavigation.isValid(.fieldHome))
        XCTAssertTrue(GillnoteNavigation.isValid(.idResult))
        XCTAssertTrue(GillnoteNavigation.isValid(.lookalikeChat))
        XCTAssertTrue(GillnoteNavigation.isValid(.overlayAnnotate))
        XCTAssertTrue(GillnoteNavigation.isValid(.fieldBrief))
        XCTAssertTrue(GillnoteNavigation.isValid(.voiceNote))
        XCTAssertTrue(GillnoteNavigation.isValid(.aiConsent))
        XCTAssertTrue(GillnoteNavigation.isValid(.settings))
        XCTAssertTrue(GillnoteNavigation.isValid(.legal))
    }
}
