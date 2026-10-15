import XCTest

final class CellarCueUISmokeTests: XCTestCase {
    func testCellarHomeSignatureAndSettings() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-smoke-reset"]
        app.launch()

        XCTAssertTrue(app.staticTexts["CellarCue"].waitForExistence(timeout: 12))
        XCTAssertTrue(
            app.otherElements["ComplianceBanner"].waitForExistence(timeout: 5)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "非侍酒")).firstMatch.exists
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "sommelier")).firstMatch.exists
        )
        XCTAssertTrue(
            app.otherElements["CellarRowBinGrid"].waitForExistence(timeout: 5)
                || app.staticTexts["Cellar rack"].exists
                || app.staticTexts["CELLAR RACK"].exists
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "R1-B")).firstMatch.exists
        )
        XCTAssertTrue(
            app.otherElements["LabelOCRHeroCard"].waitForExistence(timeout: 5)
                || app.staticTexts["Label OCR"].exists
                || app.staticTexts["LABEL OCR"].exists
        )
        XCTAssertTrue(
            app.otherElements["DrinkingWindowTimeline"].waitForExistence(timeout: 5)
                || app.staticTexts["Drinking window"].exists
                || app.staticTexts["DRINKING WINDOW"].exists
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
