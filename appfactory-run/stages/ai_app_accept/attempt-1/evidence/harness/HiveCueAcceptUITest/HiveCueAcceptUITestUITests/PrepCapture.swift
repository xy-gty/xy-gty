import XCTest

final class PrepCapture: XCTestCase {
    let app = XCUIApplication(bundleIdentifier: "com.lingguang.hivecue")
    let shotDir = "/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/ai_app_accept/attempt-1/evidence/screenshots"
    let runtimeDir = "/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/ai_app_accept/attempt-1/evidence/runtime"

    func snap(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "\(shotDir)/\(name).png"))
        print("SNAP \(name)")
    }

    func testPrepHomeCapture() throws {
        continueAfterFailure = true
        app.terminate(); Thread.sleep(forTimeInterval: 1); app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 12))
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.buttons["New inspection"].waitForExistence(timeout: 10))
        snap("ul07-hivecue-home-empty")
        snap("ul01-home-operable")
        app.buttons["New inspection"].tap()
        Thread.sleep(forTimeInterval: 0.7)
        if app.textFields.firstMatch.exists {
            app.textFields.firstMatch.tap()
            app.textFields.firstMatch.typeText("Accept Hive A")
        }
        app.buttons["Start inspection"].tap()
        Thread.sleep(forTimeInterval: 1.2)
        snap("ul07-hivecue-capture-import")
        XCTAssertTrue(app.buttons["Photo library"].exists || app.buttons["Open camera for brood frame"].exists)
        // Marker for shell seeder
        try? "prep_ok\n".write(
            to: URL(fileURLWithPath: "\(runtimeDir)/prep-capture.ok"),
            atomically: true,
            encoding: .utf8
        )
        app.terminate()
    }
}
