import XCTest

final class PhotoKeep: XCTestCase {
    func testPhotoThenKeep() throws {
        let app = XCUIApplication(bundleIdentifier: "com.lingguang.nightcue")
        app.terminate(); Thread.sleep(forTimeInterval: 1); app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        Thread.sleep(forTimeInterval: 1)
        var cta = app.buttons["cta-new-session"]
        if !cta.waitForExistence(timeout: 4) { cta = app.buttons["New session"] }
        XCTAssertTrue(cta.exists)
        cta.tap(); Thread.sleep(forTimeInterval: 0.8)
        if app.textFields.firstMatch.exists {
            app.textFields.firstMatch.tap(); app.textFields.firstMatch.typeText("Bridge overlook")
        }
        app.buttons["Create session"].tap(); Thread.sleep(forTimeInterval: 1)
        app.buttons["Photo library"].tap(); Thread.sleep(forTimeInterval: 2)
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow Full Access", "Allow Access to All Photos", "允许完全访问", "允许访问所有照片", "Allow", "允许"] {
            if sb.buttons[label].waitForExistence(timeout: 2) { sb.buttons[label].tap(); print("SB \(label)") }
            if app.buttons[label].waitForExistence(timeout: 0.5) { app.buttons[label].tap(); print("APP \(label)") }
        }
        Thread.sleep(forTimeInterval: 1)
        if app.buttons["关闭"].exists { app.buttons["关闭"].tap() }
        for i in 0..<min(app.buttons.count, 20) {
            let b = app.buttons.element(boundBy: i)
            if b.exists { print("B[\(i)] \(b.label) id=\(b.identifier)") }
        }
        if app.cells.count > 0 {
            app.cells.element(boundBy: 0).tap()
            print("TAP cell 0")
        }
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.16, dy: 0.32)).tap()
        Thread.sleep(forTimeInterval: 1.5)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.16, dy: 0.32)).tap()
        Thread.sleep(forTimeInterval: 2)
        // iOS limited picker confirm bar
        if app.toolbars.buttons.count > 0 {
            for i in 0..<app.toolbars.buttons.count {
                let b = app.toolbars.buttons.element(boundBy: i)
                print("TB \(b.label)")
                if b.label.contains("Add") || b.label.contains("添加") { b.tap() }
            }
        }
        for label in ["Add", "Choose", "Done", "添加", "选取", "完成", "Use Photo", "添加 1 张照片"] {
            if app.buttons[label].exists { app.buttons[label].tap(); print("CONF \(label)") }
        }
        Thread.sleep(forTimeInterval: 4)
        let shotDir = "/Users/a2026/work/factory-prod-1/runs/kf-20261015T075333Z-d3a0d226/stages/ai_app_accept/attempt-1/evidence/screenshots"
        try XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: "\(shotDir)/debug-after-photo.png"))
        print("KEEP=\(app.buttons["Keep"].exists) DISCARD=\(app.buttons["Discard"].exists)")
        for i in 0..<min(app.buttons.count, 35) {
            let b = app.buttons.element(boundBy: i)
            if b.exists { print("AFTER[\(i)] \(b.label) id=\(b.identifier)") }
        }
        if app.buttons["Keep"].waitForExistence(timeout: 8) {
            app.buttons["Keep"].tap()
            print("KEPT")
        }
        XCTAssertTrue(app.buttons["Keep"].exists || app.staticTexts["Exposure / noise diagnosis"].exists)
    }
}
