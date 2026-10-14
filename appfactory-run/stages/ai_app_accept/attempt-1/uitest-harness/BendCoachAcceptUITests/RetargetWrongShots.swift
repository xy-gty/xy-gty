import XCTest

final class RetargetWrongShots: XCTestCase {
    var app: XCUIApplication!
    let shotDir = "/Users/a2026/work/factory-prod-2/runs/kf-20261013T132652Z-d15977ae/stages/ai_app_accept/attempt-1/evidence/screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication(bundleIdentifier: "com.lingguang.bendcoach")
    }

    private func tap(_ label: String, timeout: TimeInterval = 5) -> Bool {
        let b = app.buttons[label]
        if b.waitForExistence(timeout: timeout) {
            if b.isHittable { b.tap() } else { b.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
            return true
        }
        let t = app.staticTexts[label]
        if t.waitForExistence(timeout: 1) {
            t.tap(); return true
        }
        return false
    }

    private func exists(_ f: String, timeout: TimeInterval = 5) -> Bool {
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] %@", f)).firstMatch.waitForExistence(timeout: timeout)
    }

    private func shot(_ name: String) {
        sleep(1)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "\(shotDir)/\(name).png"))
        print("RETARGET_SHOT \(name) bytes=\(data.count)")
    }

    private func dump(_ tag: String) {
        var labels: [String] = []
        for i in 0..<min(app.buttons.count, 50) {
            let l = app.buttons.element(boundBy: i).label
            if !l.isEmpty { labels.append(l) }
        }
        print("DUMP[\(tag)] \(labels.joined(separator: " | "))")
    }

    private func dismissAlerts() {
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow While Using App", "Allow", "OK", "Don’t Allow"] {
            if sb.buttons[label].waitForExistence(timeout: 1.5) {
                if label != "Don’t Allow" { sb.buttons[label].tap() }
            }
        }
        _ = tap("Continue", timeout: 1)
        _ = tap("Allow", timeout: 1)
        _ = tap("Not now", timeout: 1)
    }

    private func backIfNeeded() {
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 1) {
            let b = app.navigationBars.buttons.firstMatch
            if b.isHittable { b.tap() }
        }
    }

    /// True DiagramOverlayView with Discard/Use (pendingOverlay set).
    func testDiagramTrueOverlay() {
        app.launchArguments = ["-UITesting"]
        app.launch()
        dismissAlerts()
        sleep(1)

        // Prefer Job tab (may already have job from prior run)
        if app.tabBars.buttons["Job"].waitForExistence(timeout: 4) {
            app.tabBars.buttons["Job"].tap()
        }
        sleep(1)

        // Ensure a job exists
        if !exists("Generate diagram", timeout: 2) {
            if app.tabBars.buttons["Home"].waitForExistence(timeout: 2) {
                app.tabBars.buttons["Home"].tap()
            }
            _ = tap("Open coach", timeout: 3) || tap("Start a bend job", timeout: 2)
            sleep(1)
            if app.tabBars.buttons["Job"].waitForExistence(timeout: 3) {
                app.tabBars.buttons["Job"].tap()
            }
        }

        // Capture → review → Save marks (required for generateDiagram)
        if !exists("Saved marks", timeout: 2) {
            XCTAssertTrue(tap("Capture / import photo"), "need Capture")
            sleep(1)
            XCTAssertTrue(tap("Capture photo", timeout: 4), "need Capture photo")
            dismissAlerts()
            sleep(3)
            // Review bend draft appears after photo
            if tap("Review bend draft", timeout: 5) || tap("Review bend marks", timeout: 2) {
                sleep(1)
            } else {
                backIfNeeded()
                sleep(1)
                _ = tap("Review bend marks", timeout: 4)
                sleep(1)
            }
            dump("review")
            XCTAssertTrue(tap("Save", timeout: 5), "need Save marks")
            sleep(1)
            backIfNeeded(); sleep(1)
            if app.tabBars.buttons["Job"].waitForExistence(timeout: 2) {
                app.tabBars.buttons["Job"].tap()
            }
            sleep(1)
        }

        dump("pre-gen")
        XCTAssertTrue(tap("Generate diagram", timeout: 5), "Generate diagram")
        sleep(3)
        // Status may say diagram draft ready; navigate to overlay
        var opened = exists("Discard", timeout: 2)
        if !opened {
            XCTAssertTrue(tap("Diagram preview", timeout: 5), "Diagram preview")
            sleep(2)
            opened = exists("Discard", timeout: 6)
        }
        if !opened {
            // Retry: back and tap again
            backIfNeeded(); sleep(1)
            _ = tap("Generate diagram", timeout: 3)
            sleep(2)
            _ = tap("Diagram preview", timeout: 4)
            sleep(2)
            opened = exists("Discard", timeout: 5)
        }
        dump("overlay")
        XCTAssertTrue(opened, "Discard/Use must appear on DiagramOverlayView")
        shot("runtime-diagram-overlay")
        // Leave pending; do not Use/Discard so chrome stays if re-shot
    }

    /// Settings with Units control clearly visible (open Units page).
    func testSettingsUnitsVisible() {
        app.launchArguments = ["-UITesting"]
        app.launch()
        dismissAlerts()
        sleep(1)
        XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Settings"].tap()
        sleep(1)
        // Open Units destination so Picker is on-screen
        if tap("Units", timeout: 4) {
            sleep(1)
            dump("units-page")
            shot("runtime-settings-units-privacy")
            return
        }
        // Fallback: scroll until Units row visible then shot list
        for _ in 0..<4 { app.swipeUp(); usleep(300000) }
        dump("settings-list")
        shot("runtime-settings-units-privacy")
        XCTAssertTrue(exists("Units", timeout: 2), "Units control should be visible")
    }
}
