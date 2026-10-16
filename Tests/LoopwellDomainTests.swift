import XCTest
import LoopwellDomain
import AppRuntimeCore

final class LoopwellDomainTests: XCTestCase {
    func testReviewControlLabels() {
        XCTAssertEqual(StitchReviewBar.confirm, "Keep")
        XCTAssertEqual(StitchReviewBar.reject, "Discard")
        XCTAssertEqual(StitchReviewBar.edit, "Edit")
        XCTAssertEqual(TurnReview.confirm, "Keep")
        XCTAssertEqual(TurnReview.reject, "Discard")
        XCTAssertEqual(AIConsentContract.provider, "DeepSeek")
        XCTAssertEqual(AIConsentContract.disclosureVersion, "loopwell.consent.v1")
        XCTAssertEqual(AIConsentContract.fields.count, 7)
    }

    func testNavigationCasesMatchContract() {
        let expected = [
            "ProjectsHome", "NewProject", "CaptureImport", "StitchReview", "ProjectCoach",
            "CoachChat", "TurnReview", "AnnotatedWIP", "HandsFreeTTS", "DictateNote",
            "Settings", "LegalPages", "ConsentSheet",
        ]
        XCTAssertEqual(LoopwellRoute.allCases.map(\.rawValue), expected)
    }

    func testPrivacyUsageCopy() {
        XCTAssertTrue(PrivacyUsageCopy.camera.contains("WIP photos"))
        XCTAssertTrue(PrivacyUsageCopy.photoLibrary.contains("WIP / yarn"))
        XCTAssertTrue(PrivacyUsageCopy.microphone.contains("Dictate pattern notes"))
        XCTAssertTrue(PrivacyUsageCopy.speechRecognition.contains("next-row"))
    }

    func testStitchCueKeepPersists() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("loopwell-cue-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[StitchCue]>(url: url)
        let cue = StitchCue(
            id: "c1",
            projectId: "p1",
            stepIndex: 0,
            stitchName: "Knit stockinette",
            rowNumber: 4,
            notes: "even tension",
            confirmedAt: Date()
        )
        try store.save([cue])
        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.first?.stitchName, "Knit stockinette")
        XCTAssertEqual(loaded.first?.rowNumber, 4)
    }

    func testDiscardDoesNotWriteConfirmedCue() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("loopwell-discard-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = AtomicCodableStore<[StitchCue]>(url: url)
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
        let turn = CoachTurn(
            id: "t1",
            projectId: "p1",
            role: "user",
            text: "prefer looser tension on next row",
            createdAt: Date()
        )
        let encoded = try JSONEncoder().encode(turn)
        let decoded = try JSONDecoder().decode(CoachTurn.self, from: encoded)
        XCTAssertTrue(decoded.text.contains("looser"))
        XCTAssertEqual(decoded.role, "user")
    }

    func testProjectRoundTripAndIdentity() throws {
        let project = Project(
            id: "p",
            title: "Scarlet scarf",
            yarnSwatchHexes: ["#A21CAF", "#84CC16"],
            currentRow: 3,
            updatedAt: Date()
        )
        let data = try JSONEncoder().encode(project)
        let decoded = try JSONDecoder().decode(Project.self, from: data)
        XCTAssertEqual(decoded.title, "Scarlet scarf")
        XCTAssertEqual(LoopwellIdentity.developmentBundleId, "com.lingguang.loopwell")
        XCTAssertEqual(LoopwellIdentity.productDir, "loopwell")
        XCTAssertEqual(LoopwellIdentity.appName, "Loopwell")
    }
}
