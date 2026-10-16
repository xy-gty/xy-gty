import XCTest

final class BloomkettleUISmokeTests: XCTestCase {
    func testLaunchBrewHome() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["BrewHome"].waitForExistence(timeout: 8)
            || app.staticTexts["Bloomkettle"].waitForExistence(timeout: 8))
    }

    func testCoreFunnelFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Bloomkettle"].waitForExistence(timeout: 8))
        // Open seeded session
        let session = app.buttons.matching(NSPredicate(format: "label CONTAINS 'UITest V60'")).firstMatch
        if session.waitForExistence(timeout: 4) {
            session.tap()
        } else {
            app.staticTexts["UITest V60"].tap()
        }
        // Resume funnel from session detail
        let resume = app.buttons["Resume funnel"]
        XCTAssertTrue(resume.waitForExistence(timeout: 6))
        resume.tap()
        XCTAssertTrue(app.descendants(matching: .any)["FunnelTimelineScreen"].waitForExistence(timeout: 6)
            || app.staticTexts["Pour-over funnel"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.descendants(matching: .any)["NextPourCard"].waitForExistence(timeout: 4)
            || app.staticTexts["Next pour"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.descendants(matching: .any)["GrindChipRail"].waitForExistence(timeout: 4)
            || app.staticTexts["Grind size"].waitForExistence(timeout: 4))
        // Coach chat entry
        let chat = app.buttons["Coach chat"]
        if chat.waitForExistence(timeout: 3) {
            chat.tap()
            XCTAssertTrue(app.descendants(matching: .any)["CoachChat"].waitForExistence(timeout: 5)
                || app.navigationBars["Coach chat"].waitForExistence(timeout: 5))
        }
    }
}
