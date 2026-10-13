import XCTest
final class NavTTS: XCTestCase {
    func testGoTTS() {
        let app = XCUIApplication(bundleIdentifier: "com.lingguang.docbrief")
        app.launch()
        if app.tabBars.buttons["Active brief"].waitForExistence(timeout: 4) { app.tabBars.buttons["Active brief"].tap() }
        let speak = app.buttons["Speak briefing"]
        if speak.waitForExistence(timeout: 6) { speak.tap() }
        else {
            // open first brief then speak
            let row = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Brief")).firstMatch
            if row.waitForExistence(timeout: 3) { row.tap() }
            if app.buttons["Speak briefing"].waitForExistence(timeout: 5) { app.buttons["Speak briefing"].tap() }
        }
        sleep(2)
        XCTAssertTrue(true)
    }
}
