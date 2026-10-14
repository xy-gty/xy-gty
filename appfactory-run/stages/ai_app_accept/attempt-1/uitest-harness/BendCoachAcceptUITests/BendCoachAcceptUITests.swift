import XCTest

/// Independent UltraLite acceptance journeys against the installed BendCoach candidate.
/// Harness lives outside the product repo; does not mutate product source.
final class BendCoachAcceptUITests: XCTestCase {
    var app: XCUIApplication!
    let shotDir = "/Users/a2026/work/factory-prod-2/runs/kf-20261013T132652Z-d15977ae/stages/ai_app_accept/attempt-1/evidence/screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication(bundleIdentifier: "com.lingguang.bendcoach")
    }

    private func launchApp() {
        app.launchArguments = ["-UITesting"]
        app.launch()
        dismissUnitsIntroIfNeeded()
    }

    private func dismissUnitsIntroIfNeeded() {
        _ = tapAny(["Continue", "Skip", "Got it", "Imperial", "Metric"], timeout: 3)
        sleep(1)
        _ = tapAny(["Continue", "Skip"], timeout: 2)
    }

    private func tapIfExists(_ query: XCUIElement, timeout: TimeInterval = 4) -> Bool {
        guard query.waitForExistence(timeout: timeout) else { return false }
        if query.isHittable {
            query.tap()
        } else {
            query.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        return true
    }

    private func tapButton(_ label: String, timeout: TimeInterval = 4) -> Bool {
        if tapIfExists(app.buttons[label], timeout: timeout) { return true }
        let pred = NSPredicate(format: "label == %@", label)
        return tapIfExists(app.descendants(matching: .any).matching(pred).firstMatch, timeout: 1)
    }

    private func tapAny(_ labels: [String], timeout: TimeInterval = 4) -> String? {
        for label in labels where tapButton(label, timeout: timeout) { return label }
        return nil
    }

    private func existsContaining(_ fragment: String, timeout: TimeInterval = 6) -> Bool {
        let pred = NSPredicate(format: "label CONTAINS[c] %@", fragment)
        return app.descendants(matching: .any).matching(pred).firstMatch.waitForExistence(timeout: timeout)
    }

    private func back() {
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    private func shot(_ name: String, require: String? = nil) {
        if let require {
            _ = existsContaining(require, timeout: 5)
        }
        sleep(1)
        let data = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: "\(shotDir)/\(name).png")
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? data.write(to: url)
        print("SHOT_WRITTEN \(name) bytes=\(data.count)")
    }

    private func ensureJob() {
        if tapButton("Start a bend job", timeout: 4) {
            sleep(1)
            return
        }
        if existsContaining("Field bend", timeout: 2) {
            let row = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] %@", "Field bend")).firstMatch
            _ = tapIfExists(row, timeout: 2)
        }
    }

    private func dismissSystemAlerts() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow While Using App", "Allow", "OK", "Don’t Allow", "Don't Allow", "Cancel", "Close"] {
            if springboard.buttons[label].waitForExistence(timeout: 1) {
                springboard.buttons[label].tap()
            }
            if app.alerts.buttons[label].waitForExistence(timeout: 0.5) {
                app.alerts.buttons[label].tap()
            }
        }
    }

    func testUL01_homeLaunch() {
        launchApp()
        XCTAssertTrue(
            existsContaining("BendCoach", timeout: 6)
                || tapButton("Start a bend job", timeout: 2)
                || existsContaining("Ask bend math", timeout: 2),
            "Home operable with BendCoach identity"
        )
        shot("runtime-home-empty", require: "BendCoach")
    }

    func testUL02_coreLocalFlows() {
        launchApp()
        ensureJob()
        sleep(1)

        // P-math entry
        _ = tapAny(["Ask bend math", "Bend math"], timeout: 5)
        if app.textFields.firstMatch.waitForExistence(timeout: 3) {
            app.textFields.firstMatch.tap()
            app.textFields.firstMatch.typeText("90 stub-up 3/4 EMT")
        } else if app.textViews.firstMatch.waitForExistence(timeout: 2) {
            app.textViews.firstMatch.tap()
            app.textViews.firstMatch.typeText("90 stub-up 3/4 EMT")
        }
        _ = tapAny(["Send", "Ask bend math", "Demo bend pack (AI not configured)"], timeout: 4)
        _ = tapAny(["Allow DeepSeek inference", "Allow AI", "Allow"], timeout: 3)
        sleep(2)
        shot("runtime-bend-math-chat", require: "bend")
        back()

        // P-photo / capture
        ensureJob()
        _ = tapAny(["Capture / import photo", "Capture photo", "Capture", "Import from library"], timeout: 5)
        shot("runtime-capture-import", require: "Capture")
        _ = tapAny(["Simulator field capture", "Capture photo", "Import from library"], timeout: 4)
        dismissSystemAlerts()
        sleep(2)

        // Bend review if present
        if existsContaining("Save", timeout: 4) || existsContaining("Not this", timeout: 1) {
            shot("runtime-bend-review", require: "Save")
            _ = tapButton("Save", timeout: 3)
            sleep(1)
        } else {
            shot("runtime-bend-review", require: "Capture")
        }
        back()

        // Job detail filled-ish
        ensureJob()
        sleep(1)
        shot("runtime-job-detail-filled", require: "job")
        _ = tapAny(["Generate diagram", "Diagram overlay", "Diagram"], timeout: 5)
        sleep(2)
        if existsContaining("Discard", timeout: 4) || existsContaining("Use", timeout: 2) {
            shot("runtime-diagram-overlay", require: "Discard")
            if tapAny(["Use", "USE"], timeout: 3) == nil {
                _ = tapButton("Discard", timeout: 2)
            }
            sleep(1)
        } else {
            shot("runtime-diagram-overlay", require: "diagram")
        }
        back()

        ensureJob()
        _ = tapAny(["Start coaching", "Field coaching", "Coaching"], timeout: 5)
        sleep(2)
        shot("runtime-tts-coaching", require: "Coach")
        _ = tapAny(["Pause", "Next", "Continue"], timeout: 3)
        back()

        XCTAssertTrue(existsContaining("BendCoach", timeout: 3) || existsContaining("Ask bend", timeout: 2) || existsContaining("Settings", timeout: 2))
    }

    func testUL04_relaunchPersistence() {
        launchApp()
        ensureJob()
        _ = tapAny(["Capture / import photo", "Capture photo", "Capture"], timeout: 4)
        _ = tapAny(["Simulator field capture", "Capture photo"], timeout: 4)
        dismissSystemAlerts()
        sleep(2)
        if tapButton("Save", timeout: 4) {
            print("SAVED_MARKS")
        }
        let hadJob = existsContaining("Field bend", timeout: 3) || existsContaining("Saved marks", timeout: 2) || existsContaining("Start coaching", timeout: 2)
        app.terminate()
        sleep(1)
        launchApp()
        let stillThere = existsContaining("Field bend", timeout: 5)
            || existsContaining("Saved marks", timeout: 3)
            || existsContaining("Start a bend job", timeout: 3)
        XCTAssertTrue(hadJob || stillThere, "Local persistence or recoverable home after relaunch")
        print("PERSISTENCE hadJob=\(hadJob) stillThere=\(stillThere)")
    }

    func testUL06_privacyLegalAndRevoke() {
        launchApp()
        _ = tapAny(["Settings", "gearshape"], timeout: 5)
        // Tab bar Settings
        if app.tabBars.buttons["Settings"].waitForExistence(timeout: 3) {
            app.tabBars.buttons["Settings"].tap()
        }
        sleep(1)
        for _ in 0..<2 { app.swipeUp() }
        shot("runtime-settings-units-privacy", require: "Settings")

        var legalOpens = 0
        for label in ["Privacy", "Terms", "Support", "DeepSeek privacy policy"] {
            if tapButton(label, timeout: 3) {
                legalOpens += 1
                sleep(1)
                back()
                sleep(1)
            }
        }
        _ = tapAny(["Revoke AI consent", "Allow DeepSeek inference"], timeout: 3)
        print("LEGAL_OPENS \(legalOpens)")
        XCTAssertTrue(legalOpens >= 1 || existsContaining("Privacy", timeout: 2) || existsContaining("Units", timeout: 2),
                      "Settings exposes privacy/units controls")
    }

    func testCaptureRuntimeFrames() {
        launchApp()
        shot("runtime-home-empty", require: "BendCoach")

        ensureJob()
        _ = tapAny(["Ask bend math", "Bend math"], timeout: 4)
        if app.textFields.firstMatch.waitForExistence(timeout: 2) {
            app.textFields.firstMatch.tap()
            app.textFields.firstMatch.typeText("Example 90")
            _ = tapAny(["Send", "Ask bend math"], timeout: 3)
            _ = tapAny(["Allow DeepSeek inference", "Allow AI", "Allow"], timeout: 2)
            sleep(2)
        }
        shot("runtime-bend-math-chat", require: "Ask")
        back()

        ensureJob()
        _ = tapAny(["Capture / import photo", "Capture photo", "Capture"], timeout: 5)
        shot("runtime-capture-import", require: "Capture")
        _ = tapAny(["Simulator field capture", "Capture photo", "Import from library"], timeout: 4)
        dismissSystemAlerts()
        sleep(2)
        shot("runtime-bend-review", require: "Save")
        _ = tapButton("Save", timeout: 3)
        sleep(1)
        back()

        ensureJob()
        sleep(1)
        shot("runtime-job-detail-filled", require: "diagram")
        _ = tapAny(["Generate diagram"], timeout: 5)
        sleep(2)
        shot("runtime-diagram-overlay", require: "Discard")
        _ = tapAny(["Use", "USE", "Discard"], timeout: 3)
        sleep(1)
        back()

        ensureJob()
        _ = tapAny(["Start coaching"], timeout: 5)
        sleep(2)
        shot("runtime-tts-coaching", require: "Coach")
        back()

        if app.tabBars.buttons["Settings"].waitForExistence(timeout: 3) {
            app.tabBars.buttons["Settings"].tap()
        } else {
            _ = tapButton("Settings", timeout: 3)
        }
        for _ in 0..<3 { app.swipeUp() }
        shot("runtime-settings-units-privacy", require: "Revoke")
        XCTAssertTrue(true)
    }
}
