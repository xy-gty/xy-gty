import XCTest

/// Follow-up after UL-02: dismiss leftover Photos picker chrome and capture Coach/Settings/legal.
final class FollowupTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261015T093242Z-0f4256a0/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = true
        try FileManager.default.createDirectory(atPath: evidenceDir, withIntermediateDirectories: true)
        app = XCUIApplication(bundleIdentifier: "com.lingguang.stopcue")
        app.terminate()
        app.launch()
        sleep(1)
        dismissSheets()
    }

    private func shot(_ name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        try? png.write(to: URL(fileURLWithPath: evidenceDir).appendingPathComponent(name))
    }

    private func dump(_ name: String) {
        try? app.debugDescription.write(
            to: URL(fileURLWithPath: evidenceDir).appendingPathComponent(name),
            atomically: true,
            encoding: .utf8
        )
    }

    private func forceTap(_ element: XCUIElement) {
        if element.isHittable { element.tap() }
        else { element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
    }

    private func dismissSheets() {
        for label in ["完成", "Cancel", "Close", "Done", "Add"] {
            let b = app.buttons[label]
            if b.waitForExistence(timeout: 1.2) { forceTap(b); sleep(1) }
        }
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow", "OK", "Don’t Allow", "Don't Allow"] {
            let b = spring.buttons[label]
            if b.waitForExistence(timeout: 0.8) { b.tap() }
        }
    }

    private func tapTab(_ name: String) -> Bool {
        let tab = app.tabBars.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", name)
        ).firstMatch
        if tab.waitForExistence(timeout: 5) { forceTap(tab); return true }
        return false
    }

    private func tapLabel(_ fragments: [String], timeout: TimeInterval = 6) -> Bool {
        for frag in fragments {
            let button = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] %@", frag)
            ).firstMatch
            if button.waitForExistence(timeout: timeout) { forceTap(button); return true }
        }
        return false
    }

    func testFollowupCoachSettingsLegal() throws {
        dismissSheets()
        // Ensure a project exists for Coach tab content
        if tapLabel(["New project", "+ New project"], timeout: 4) {
            sleep(1)
            dismissSheets()
            if app.textFields.firstMatch.waitForExistence(timeout: 3) {
                let f = app.textFields.firstMatch
                f.tap()
                f.typeText("Followup Set")
            }
            if app.keyboards.firstMatch.waitForExistence(timeout: 1) {
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12)).tap()
            }
            _ = tapLabel(["Create project"], timeout: 4)
            sleep(1)
            dismissSheets()
            if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
                // leave capture if pushed
            }
        }

        XCTAssertTrue(tapTab("Coach"), "Coach tab")
        sleep(1)
        dismissSheets()
        shot("rt-stop-coach.png")
        dump("rt-stop-coach.ax.txt")

        _ = tapLabel(["Chat"], timeout: 5)
        sleep(1)
        if tapLabel(["Allow"], timeout: 3) { sleep(1) }
        else if tapLabel(["Not now"], timeout: 2) {
            sleep(1)
            _ = tapLabel(["Chat"], timeout: 3)
        }
        shot("rt-coach-chat.png")
        dump("rt-coach-chat.ax.txt")
        let area = app.textViews.firstMatch
        if area.waitForExistence(timeout: 2) {
            area.tap()
            area.typeText("onion skin tighter")
            _ = tapLabel(["Send"], timeout: 3)
            sleep(2)
        }
        shot("ul03-after-send.png")
        dump("ul03-after-send.ax.txt")
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }

        _ = tapLabel(["Onion"], timeout: 4)
        sleep(1)
        shot("rt-onion-overlay.png")
        dump("rt-onion-overlay.ax.txt")
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }

        _ = tapLabel(["Countdown"], timeout: 4)
        sleep(1)
        shot("rt-tts-countdown.png")
        dump("rt-tts-countdown.ax.txt")
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }

        _ = tapLabel(["Dictate"], timeout: 4)
        sleep(1)
        shot("rt-dictate.png")
        dump("rt-dictate.ax.txt")

        XCTAssertTrue(tapTab("Settings"), "Settings tab")
        sleep(1)
        shot("rt-settings-privacy.png")
        dump("rt-settings-privacy.ax.txt")

        for (label, file) in [
            ("Privacy", "ul06-privacy"),
            ("Terms", "ul06-terms"),
            ("Support", "ul06-support"),
            ("Provider policy", "ul06-provider"),
        ] {
            if tapLabel([label], timeout: 5) {
                sleep(1)
                shot("\(file).png")
                dump("\(file).ax.txt")
                if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
                    app.navigationBars.buttons.firstMatch.tap()
                    sleep(1)
                }
            }
        }

        _ = tapLabel(["Revoke AI consent", "Revoke"], timeout: 4)
        sleep(1)
        shot("ul06-after-revoke.png")
        dump("ul06-after-revoke.ax.txt")
    }
}
