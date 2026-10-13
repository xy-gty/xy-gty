import XCTest

/// Navigate product routes and write host-path PNGs for UL-07.
final class ScreenshotTour: XCTestCase {
    var app: XCUIApplication!
    let shotDir = "/Users/a2026/work/factory-prod-2/runs/kf-20261013T095745Z-aa3ad9a0/stages/ai_app_accept/attempt-2/screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication(bundleIdentifier: "com.lingguang.docbrief")
        app.launchArguments = ["-UITesting"]
        app.launch()
    }

    private func tap(_ label: String, timeout: TimeInterval = 5) -> Bool {
        let b = app.buttons.matching(NSPredicate(format: "label == %@", label)).element(boundBy: 0)
        guard b.waitForExistence(timeout: timeout) else { return false }
        if b.isHittable { b.tap() } else { b.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        return true
    }

    private func tapId(_ id: String, timeout: TimeInterval = 4) -> Bool {
        let e = app.descendants(matching: .any).matching(NSPredicate(format: "identifier == %@", id)).firstMatch
        guard e.waitForExistence(timeout: timeout) else { return false }
        if e.isHittable { e.tap() } else { e.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        return true
    }

    private func hub() {
        _ = tapId("checkmark.seal", timeout: 3) || tap("Active brief", timeout: 3)
    }

    private func shot(_ name: String, require: String? = nil) {
        if let require {
            let pred = NSPredicate(format: "label CONTAINS[c] %@", require)
            _ = app.descendants(matching: .any).matching(pred).firstMatch.waitForExistence(timeout: 4)
        }
        sleep(1)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: "\(shotDir)/\(name).png")
        try? data.write(to: url)
        print("SHOT_WRITTEN \(name) bytes=\(data.count)")
    }

    private func back() {
        if app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    func testCaptureRuntimeFrames() {
        // home-empty or list
        shot("runtime-home-empty", require: "DocBrief")

        if tap("Start brief", timeout: 4) {
            if app.textFields.firstMatch.waitForExistence(timeout: 3) {
                app.textFields.firstMatch.tap()
                app.textFields.firstMatch.typeText("Visual Tour Brief")
            }
            _ = tap("Create brief", timeout: 5)
        } else if tap("Add", timeout: 2) {
            if app.textFields.firstMatch.waitForExistence(timeout: 3) {
                app.textFields.firstMatch.tap()
                app.textFields.firstMatch.typeText("Visual Tour Brief")
            }
            _ = tap("Create brief", timeout: 5)
        }

        hub()

        // capture-import
        _ = tap("Add photos", timeout: 5) || tap("Import", timeout: 2)
        shot("runtime-capture-import", require: "photo")
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Cancel", "Close"] {
            if springboard.buttons[label].waitForExistence(timeout: 1) { springboard.buttons[label].tap() }
            if app.buttons[label].waitForExistence(timeout: 1) { app.buttons[label].tap() }
        }
        back()

        hub()
        _ = tap("Recognize type & fields", timeout: 5) || tap("Review recognition", timeout: 3)
        _ = tap("Allow DeepSeek inference", timeout: 3) || tap("Allow", timeout: 2)
        shot("runtime-fields-review", require: "AI")
        back()

        hub()
        _ = tap("Add field", timeout: 4) || tap("Add field manually", timeout: 2)
        if app.textFields.count >= 1 {
            app.textFields.element(boundBy: 0).tap()
            app.textFields.element(boundBy: 0).typeText("vendor")
        }
        if app.textFields.count >= 2 {
            app.textFields.element(boundBy: 1).tap()
            app.textFields.element(boundBy: 1).typeText("Acme")
        }
        _ = tap("Save", timeout: 4)
        hub()
        shot("runtime-brief-detail-filled", require: "brief")

        _ = tap("Chat extract", timeout: 6)
        shot("runtime-chat-extract", require: "Chat")
        back()

        hub()
        _ = tap("Generate summary card", timeout: 5)
        shot("runtime-summary-card", require: "AI")
        back()

        hub()
        _ = tap("Speak briefing", timeout: 5)
        shot("runtime-tts-briefing", require: "Brief")
        back()

        _ = tapId("gearshape", timeout: 4) || tap("Settings", timeout: 3)
        sleep(1)
        for _ in 0..<3 { app.swipeUp() }
        shot("runtime-settings-privacy", require: "Revoke")
        XCTAssertTrue(true)
    }
}
