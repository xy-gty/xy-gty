import XCTest

final class DumpPicker: XCTestCase {
    func testDumpPicker() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lingguang.hivecue")
        app.terminate()
        Thread.sleep(forTimeInterval: 1)
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.buttons["New inspection"].waitForExistence(timeout: 8))
        app.buttons["New inspection"].tap()
        Thread.sleep(forTimeInterval: 0.8)
        if app.textFields.firstMatch.exists {
            app.textFields.firstMatch.tap()
            app.textFields.firstMatch.typeText("PickDump")
        }
        app.buttons["Start inspection"].tap()
        Thread.sleep(forTimeInterval: 1)
        XCTAssertTrue(app.buttons["Photo library"].waitForExistence(timeout: 5))
        app.buttons["Photo library"].tap()
        Thread.sleep(forTimeInterval: 2.5)
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow Full Access", "Allow Access to All Photos", "允许完全访问", "允许访问所有照片", "Allow", "允许"] {
            if sb.buttons[label].waitForExistence(timeout: 1) { sb.buttons[label].tap(); print("PERM \(label)") }
            if app.buttons[label].exists { app.buttons[label].tap() }
        }
        Thread.sleep(forTimeInterval: 2)
        print("APP buttons=\(app.buttons.count) cells=\(app.cells.count) images=\(app.images.count) other=\(app.otherElements.count)")
        for i in 0..<min(app.buttons.count, 40) {
            let b = app.buttons.element(boundBy: i)
            if b.exists { print("BTN[\(i)] label=\(b.label) id=\(b.identifier)") }
        }
        for i in 0..<min(app.cells.count, 20) {
            let c = app.cells.element(boundBy: i)
            if c.exists { print("CELL[\(i)] label=\(c.label) id=\(c.identifier)") }
        }
        for i in 0..<min(app.images.count, 20) {
            let im = app.images.element(boundBy: i)
            if im.exists { print("IMG[\(i)] id=\(im.identifier) label=\(im.label)") }
        }
        if app.collectionViews.count > 0 {
            let cv = app.collectionViews.firstMatch
            print("CV cells=\(cv.cells.count)")
            for i in 0..<min(cv.cells.count, 10) {
                print("CVCELL[\(i)] \(cv.cells.element(boundBy: i).identifier)")
            }
        }
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try data.write(to: URL(fileURLWithPath: "/Users/a2026/work/factory-prod-1/runs/kf-20261015T053908Z-ea6ff1de/stages/ai_app_accept/attempt-1/evidence/screenshots/picker-probe.png"))
        print("WROTE picker-probe")
    }
}
