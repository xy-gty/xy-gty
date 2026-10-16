import XCTest

final class ZonelightUISmokeTests: XCTestCase {
    func testMeterHomeSignatureAndSettings() {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-smoke-reset"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Zonelight"].waitForExistence(timeout: 12))
        XCTAssertTrue(
            app.otherElements["ComplianceBanner"].waitForExistence(timeout: 5)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "非校准")).firstMatch.exists
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "calibrated lab")).firstMatch.exists
        )
        XCTAssertTrue(
            app.otherElements["ZoneSystemDial"].waitForExistence(timeout: 5)
                || app.staticTexts["Zone dial"].exists
                || app.staticTexts["ZONE DIAL"].exists
        )
        XCTAssertTrue(
            app.otherElements["OversizedEVReadoutBar"].waitForExistence(timeout: 5)
                || app.staticTexts["EV"].exists
        )
        XCTAssertTrue(
            app.otherElements["SpotMeterCrossCard"].waitForExistence(timeout: 5)
                || app.staticTexts["Spot-meter cross"].exists
                || app.staticTexts["SPOT-METER CROSS"].exists
        )
        XCTAssertTrue(app.buttons["SpotButton"].waitForExistence(timeout: 4) || app.buttons["Spot"].exists)

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
