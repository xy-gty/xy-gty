import XCTest

final class FinishCueUISmokeTests: XCTestCase {
    func testLaunchHeatHome() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["HeatHome"].waitForExistence(timeout: 8)
            || app.staticTexts["FinishCue"].waitForExistence(timeout: 8))
    }
}
