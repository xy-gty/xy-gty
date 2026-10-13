import XCTest
final class DumpSettings: XCTestCase {
    func testDump() {
        let app = XCUIApplication(bundleIdentifier: "com.lingguang.docbrief")
        app.launch()
        if app.tabBars.buttons["Settings"].waitForExistence(timeout: 5) {
            app.tabBars.buttons["Settings"].tap()
        } else {
            _ = app.buttons["Settings"].waitForExistence(timeout: 3) && { app.buttons["Settings"].tap(); return true }()
        }
        sleep(2)
        print("=== SETTINGS DUMP ===")
        print(app.debugDescription)
        XCTAssertTrue(true)
    }
}
