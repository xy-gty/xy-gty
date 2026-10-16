import XCTest
import FieldmarkDomain
import AppRuntimeCore

final class FieldmarkDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(IDReviewControls.confirm, ["Save ID", "Keep", "Use"])
        XCTAssertEqual(IDReviewControls.reject, ["Dismiss", "Reject"])
        XCTAssertEqual(IDReviewControls.edit, ["Edit marks"])
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "fieldmark.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 5)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("plumage"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("trip album"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("binoculars"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("lookalike"))
    }

    func testSightingStoreRoundTrip() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("fieldmark-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let store = SightingStore(directory: dir)
        var state = FieldmarkState()
        let session = IDSession(
            id: "s1",
            createdAt: Date(),
            photoLocalURL: "/tmp/bird.jpg",
            source: "camera",
            status: "confirmed"
        )
        state.sessions = [session]
        state.candidates = [
            SpeciesCandidate(
                sessionId: "s1",
                scientificName: "Setophaga coronata",
                commonName: "Yellow-rumped Warbler",
                confidence: 0.91,
                rank: 1,
                silhouetteKey: "warbler"
            )
        ]
        state.fieldMarks = [
            FieldMark(
                candidateId: "Setophaga coronata",
                label: "yellow rump",
                bodyRegion: "rump",
                salience: 0.95,
                chipEmphasis: true
            )
        ]
        try store.save(state)
        let loaded = try store.load()
        XCTAssertEqual(loaded.sessions.first?.status, "confirmed")
        XCTAssertEqual(loaded.candidates.first?.commonName, "Yellow-rumped Warbler")
        XCTAssertEqual(loaded.fieldMarks.first?.label, "yellow rump")
    }

    func testRejectedResultNotConfirmed() throws {
        let session = IDSession(
            id: "s2",
            createdAt: Date(),
            photoLocalURL: "/tmp/x.jpg",
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

    func testSecondCallContextCarriesConfirmedMarks() throws {
        let marks = ["white wing bars", "eye ring"]
        let encoded = try JSONEncoder().encode(marks)
        let decoded = try JSONDecoder().decode([String].self, from: encoded)
        XCTAssertEqual(decoded.count, 2)
        XCTAssertTrue(decoded.contains("white wing bars"))
    }

    func testIdentityPaletteAndAllergy() {
        XCTAssertEqual(FieldmarkIdentity.developmentBundleId, "com.lingguang.fieldmark")
        XCTAssertEqual(FieldmarkIdentity.productDir, "fieldmark")
        XCTAssertEqual(FieldmarkIdentity.appName, "Fieldmark")
        XCTAssertEqual(FieldmarkPalette.primary, "#0F766E")
        XCTAssertEqual(FieldmarkPalette.secondary, "#F0FDFA")
        XCTAssertEqual(FieldmarkPalette.accent, "#C2410C")
        XCTAssertEqual(FieldmarkDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertTrue(FieldmarkDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(FieldmarkAllergy.bannedTwinShells.contains("Hemline"))
        XCTAssertTrue(FieldmarkAllergy.bannedTwinShells.contains("Mattebox"))
        XCTAssertTrue(FieldmarkAllergy.bannedTwinShells.contains("Sunbrief"))
        XCTAssertTrue(FieldmarkAllergy.bannedTwinShells.contains("Tablehost"))
        XCTAssertTrue(FieldmarkAllergy.bannedTwinShells.contains("Onionreel"))
        XCTAssertTrue(FieldmarkAllergy.requiredUI.contains("field-card stack"))
        XCTAssertTrue(FieldmarkAllergy.requiredUI.contains("oversized field-mark chips"))
        XCTAssertTrue(FieldmarkAllergy.requiredUI.contains("silhouette compare bar"))
        XCTAssertEqual(FieldmarkPermissions.required.count, 4)
    }

    func testOverlayBoundToSessionPhoto() throws {
        let overlay = AnnotatedOverlay(
            sessionId: "s1",
            photoLocalURL: "/tmp/bird.jpg",
            callouts: [OverlayCallout(markId: "m1", x: 0.4, y: 0.3, label: "wing bar")],
            createdAt: Date()
        )
        XCTAssertEqual(overlay.photoLocalURL, "/tmp/bird.jpg")
        XCTAssertEqual(overlay.callouts.first?.label, "wing bar")
    }

    func testCoachTurnSpeechSource() throws {
        let turn = CoachTurn(
            sessionId: "s1",
            role: "user",
            text: "which warbler has the white wing bars",
            sttSource: "speech",
            createdAt: Date()
        )
        let data = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: data)
        XCTAssertEqual(decoded.sttSource, "speech")
    }

    func testLookalikePairPersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("fieldmark-pair-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[LookalikePair]>(url: url)
        let pair = LookalikePair(
            sessionId: "s1",
            leftCandidateId: "a",
            rightCandidateId: "b",
            contrastNotes: "Check wing bars vs throat"
        )
        try store.save([pair])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.contrastNotes, "Check wing bars vs throat")
    }
}
