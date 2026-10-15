import XCTest
import FrameCueDomain
import AppRuntimeCore

final class FrameCueDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(CompositionReviewBar.confirm, "Keep")
        XCTAssertEqual(CompositionReviewBar.reject, "Discard")
        XCTAssertEqual(CompositionReviewBar.edit, "Edit")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(OverlayEditor.confirm, "Keep marks")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "framecue.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 8)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "SessionsHome", "NewSession", "CaptureImport", "CompositionReview", "SlateStage",
            "CoachChat", "TurnReview", "OverlayMarks", "HandsFreeTTS", "DictateShot",
            "Settings", "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(FrameCueRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("framing"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("stills"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("Hands-free"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("coach chat"))
    }

    func testCompositionNoteKeepPersists() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("framecue-note-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[CompositionNote]>(url: url)
        let note = CompositionNote(
            id: "n1",
            sessionId: "s1",
            stillId: "p1",
            subject: "Subject left of center",
            edges: "Top edge risk",
            negativeSpace: "Right unused",
            symmetry: "Slight asymmetry",
            confirmedAt: Date()
        )
        try store.save([note])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.subject, "Subject left of center")
    }

    func testDiscardDoesNotWriteConfirmedNote() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("framecue-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[CompositionNote]>(url: url)
        try store.save([])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertTrue(loaded.isEmpty)
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

    func testSecondCallContextCarriesConfirmedFeedback() throws {
        let msg = CoachMessage(
            id: "c1",
            sessionId: "s1",
            role: "user",
            text: "switch to medium shot",
            createdAt: Date(),
            status: "confirmed"
        )
        let encoded = try JSONEncoder().encode(msg)
        let decoded = try JSONDecoder().decode(CoachMessage.self, from: encoded)
        XCTAssertTrue(decoded.text.contains("medium"))
        XCTAssertEqual(decoded.status, "confirmed")
    }

    func testSessionRoundTripAndIdentity() throws {
        let session = FramingSession(
            id: "s",
            title: "Take one",
            currentShotSize: "MS",
            aspectRatio: "16:9",
            createdAt: Date(),
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(FramingSession.self, from: data)
        XCTAssertEqual(decoded.title, "Take one")
        XCTAssertEqual(FrameCueIdentity.developmentBundleId, "com.lingguang.framecue")
        XCTAssertEqual(FrameCueIdentity.productDir, "framecue")
        XCTAssertEqual(FrameCueIdentity.appName, "FrameCue")
        XCTAssertEqual(FrameCuePalette.primary, "#7E22CE")
        XCTAssertEqual(FrameCuePalette.secondary, "#FAF5FF")
        XCTAssertEqual(FrameCuePalette.accent, "#F59E0B")
        XCTAssertEqual(FrameCueDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertTrue(FrameCueDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(FrameCueAllergy.bannedTwinShells.contains("RuleCue"))
        XCTAssertTrue(FrameCueAllergy.requiredUI.contains("clapper frame canvas"))
        XCTAssertTrue(FrameCueAllergy.requiredUI.contains("bottom shot-size chip bar"))
        XCTAssertTrue(FrameCueAllergy.noAppIconOrLaunchScreen)
    }

    func testAspectOverlayPersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("framecue-overlay-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[AspectOverlay]>(url: url)
        let overlay = AspectOverlay(
            id: "o1",
            sessionId: "s1",
            stillId: "p1",
            aspectRatioLabel: "16:9",
            safeFrameEnabled: true,
            ruleOfThirdsEnabled: true,
            notes: "Safe frame locked",
            status: "confirmed",
            updatedAt: Date()
        )
        try store.save([overlay])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.notes, "Safe frame locked")
        XCTAssertEqual(loaded.first?.status, "confirmed")
    }

    func testShotSizePlanChipSwitch() throws {
        let plan = ShotSizePlan(
            id: "p",
            sessionId: "s",
            chips: ["ECU", "CU", "MS", "WS", "EWS"],
            selectedChip: "MS",
            updatedAt: Date()
        )
        XCTAssertEqual(plan.chips.count, 5)
        XCTAssertEqual(plan.selectedChip, "MS")
    }
}
