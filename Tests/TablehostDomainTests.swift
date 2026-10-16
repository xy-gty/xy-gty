import XCTest
import TablehostDomain
import AppRuntimeCore

final class TablehostDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(ComponentReviewBar.confirm, "Keep")
        XCTAssertEqual(ComponentReviewBar.reject, "Discard")
        XCTAssertEqual(ComponentReviewBar.edit, "Edit")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "tablehost.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 8)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "SessionsHome", "NewSession", "CaptureImport", "ComponentReview", "TableCoach",
            "CoachChat", "TurnReview", "SetupOverlay", "HostTTS", "DictateRules",
            "Settings", "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(TablehostRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("rulebook"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("table photos"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("Hands-free"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("coach chat"))
    }

    func testComponentMapKeepPersists() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("tablehost-map-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[ComponentMap]>(url: url)
        let map = ComponentMap(
            id: "m1",
            sessionId: "s1",
            items: ["Deck", "Board", "Player mats"],
            confirmedAt: Date()
        )
        try store.save([map])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.items.count, 3)
        XCTAssertEqual(loaded.first?.items.first, "Deck")
    }

    func testDiscardDoesNotWriteConfirmedMap() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("tablehost-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[ComponentMap]>(url: url)
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
            text: "can I play this card",
            createdAt: Date(),
            status: "confirmed"
        )
        let encoded = try JSONEncoder().encode(msg)
        let decoded = try JSONDecoder().decode(CoachMessage.self, from: encoded)
        XCTAssertTrue(decoded.text.contains("card"))
        XCTAssertEqual(decoded.status, "confirmed")
    }

    func testSessionRoundTripAndIdentity() throws {
        let session = GameSession(
            id: "s",
            gameName: "Cascadia",
            playerCount: 4,
            currentPhase: "setup",
            createdAt: Date(),
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(GameSession.self, from: data)
        XCTAssertEqual(decoded.gameName, "Cascadia")
        XCTAssertEqual(TablehostIdentity.developmentBundleId, "com.lingguang.tablehost")
        XCTAssertEqual(TablehostIdentity.productDir, "tablehost")
        XCTAssertEqual(TablehostIdentity.appName, "Tablehost")
        XCTAssertEqual(TablehostPalette.primary, "#854D0E")
        XCTAssertEqual(TablehostPalette.secondary, "#FEFCE8")
        XCTAssertEqual(TablehostPalette.accent, "#0891B2")
        XCTAssertEqual(TablehostDevicePolicy.targetDevice, "iPhone 17 Pro")
        XCTAssertTrue(TablehostDevicePolicy.bannedDevices.contains("iPhone 17 Pro Max"))
        XCTAssertTrue(TablehostAllergy.bannedTwinShells.contains("Onionreel"))
        XCTAssertTrue(TablehostAllergy.requiredUI.contains("table zone cards"))
        XCTAssertTrue(TablehostAllergy.requiredUI.contains("turn step bar"))
    }

    func testSetupOverlayPersistence() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("tablehost-overlay-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[SetupOverlay]>(url: url)
        let overlay = SetupOverlay(
            id: "o1",
            sessionId: "s1",
            tablePhotoId: "p1",
            zoneBoxes: ["Deck", "Board"],
            arrowNotes: ["Start at Deck"],
            notes: "Place board center",
            status: "confirmed",
            updatedAt: Date()
        )
        try store.save([overlay])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.notes, "Place board center")
        XCTAssertEqual(loaded.first?.status, "confirmed")
    }

    func testPhaseStepOrdering() throws {
        let steps = [
            PhaseStep(id: "a", sessionId: "s", order: 2, title: "Deal", hint: "", confirmedAt: Date()),
            PhaseStep(id: "b", sessionId: "s", order: 1, title: "Setup", hint: "", confirmedAt: Date()),
        ]
        let sorted = steps.sorted { $0.order < $1.order }
        XCTAssertEqual(sorted.first?.title, "Setup")
        XCTAssertEqual(sorted.last?.title, "Deal")
    }
}
