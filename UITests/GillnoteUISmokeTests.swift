import XCTest

final class GillnoteUISmokeTests: XCTestCase {
    func testFieldHomeSignatureAndSettings() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-smoke-reset"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Gillnote"].waitForExistence(timeout: 12))
        XCTAssertTrue(
            app.otherElements["DisclaimerBanner"].waitForExistence(timeout: 5)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "edibility")).firstMatch.exists
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "非可食")).firstMatch.exists
        )
        XCTAssertTrue(
            app.otherElements["SpeciesConfidenceStack"].waitForExistence(timeout: 5)
                || app.staticTexts["Species confidence"].exists
                || app.staticTexts["SPECIES CONFIDENCE"].exists
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Rank 1")).firstMatch.exists
        )
        XCTAssertTrue(app.buttons["ShootButton"].waitForExistence(timeout: 4) || app.buttons["Shoot"].exists)

        let settings = app.buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 4))
        settings.tap()
        XCTAssertTrue(
            app.navigationBars["Settings"].waitForExistence(timeout: 6)
                || app.otherElements["Settings"].waitForExistence(timeout: 6)
        )
        XCTAssertTrue(app.buttons["Revoke AI consent"].waitForExistence(timeout: 5))
    }
}
