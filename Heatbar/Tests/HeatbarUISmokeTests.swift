import XCTest

final class HeatbarUISmokeTests: XCTestCase {
    func testLaunchHeatHome() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest-seed"]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)["HeatHome"].waitForExistence(timeout: 8)
            || app.staticTexts["Heatbar"].waitForExistence(timeout: 8))
    }
}
