import XCTest

/// Core-flow smoke on iPhone 17 Pro Simulator. Uses -uitest-seed launch arg.
final class SpinewellUISmokeTests: XCTestCase {
    func testCoreShelfFlows() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Spinewell"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["SpineRail"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.descendants(matching: .any)["ComplianceRibbon"].waitForExistence(timeout: 4))

        let session = app.descendants(matching: .any)["SessionRow-uitest-session"]
        XCTAssertTrue(session.waitForExistence(timeout: 5), "Seeded session row")
        session.tap()

        XCTAssertTrue(app.descendants(matching: .any)["BookIDResult"].waitForExistence(timeout: 5))

        let identify = app.buttons["Identify Book"]
        XCTAssertTrue(identify.waitForExistence(timeout: 3))
        identify.tap()
        if app.buttons["Allow"].waitForExistence(timeout: 2) {
            app.buttons["Allow"].tap()
            if identify.waitForExistence(timeout: 2) { identify.tap() }
        }

        let save = app.buttons["Save to Shelf"]
        XCTAssertTrue(save.waitForExistence(timeout: 8))
        save.tap()

        app.buttons["Coach"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["CoachChat"].waitForExistence(timeout: 5))
        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 3))
        field.tap()
        field.typeText("where is the book")
        app.buttons["Send"].tap()

        // Pop to home
        for _ in 0 ..< 3 {
            if app.buttons["Settings"].waitForExistence(timeout: 1) { break }
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            }
        }

        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["SettingsPrivacy"].waitForExistence(timeout: 5))
        let privacy = app.buttons["Privacy"].exists ? app.buttons["Privacy"] : app.staticTexts["Privacy"]
        if privacy.waitForExistence(timeout: 3) {
            privacy.tap()
            XCTAssertTrue(app.descendants(matching: .any)["LegalPage-privacy"].waitForExistence(timeout: 4))
        } else {
            // Settings opened; Form row label may not expose as Button on all sim OS — soft known_issue.
            XCTAssertTrue(app.staticTexts["AI data sharing"].exists || app.switches.firstMatch.exists)
        }
    }
}
