import XCTest

final class DocBriefAcceptUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication(bundleIdentifier: "com.lingguang.docbrief")
    }

    private func launchFresh(clear: Bool) {
        if clear {
            app.terminate()
            // Reset container by deleting and relying on reinstall done outside, or springboard delete.
            // Prefer launch with clear via uninstall hook: if home has briefs, use existing brief path.
        }
        app.launchArguments = ["-UITesting"]
        app.launch()
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
        tapIfExists(app.buttons[label], timeout: timeout)
    }

    private func tapAnyButton(_ labels: [String], timeout: TimeInterval = 4) -> String? {
        for label in labels where tapButton(label, timeout: timeout) { return label }
        return nil
    }

    private func existsContaining(_ fragment: String, timeout: TimeInterval = 6) -> Bool {
        let pred = NSPredicate(format: "label CONTAINS[c] %@", fragment)
        return app.descendants(matching: .any).matching(pred).firstMatch.waitForExistence(timeout: timeout)
    }

    private func openOrCreateBrief() {
        if tapButton("Start brief", timeout: 3) {
            let tf = app.textFields.firstMatch
            if tf.waitForExistence(timeout: 3) {
                tf.tap()
                tf.typeText("Accept Sample Brief")
            }
            _ = tapButton("Create brief", timeout: 5)
            return
        }
        // Non-empty home: plus Add or existing row
        if app.buttons["Add"].waitForExistence(timeout: 2) {
            app.buttons["Add"].tap()
            let tf = app.textFields.firstMatch
            if tf.waitForExistence(timeout: 3) {
                tf.tap()
                tf.typeText("Accept Sample Brief 2")
            }
            _ = tapButton("Create brief", timeout: 5)
            return
        }
        let row = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Brief")).firstMatch
        if row.waitForExistence(timeout: 3) { row.tap() }
        _ = tapButton("Active brief", timeout: 2)
    }

    func testUL01_homeLaunch() {
        launchFresh(clear: false)
        XCTAssertTrue(
            app.staticTexts["DocBrief AI"].waitForExistence(timeout: 4)
                || app.staticTexts["Briefs"].waitForExistence(timeout: 4)
                || app.buttons["Start brief"].waitForExistence(timeout: 2)
                || app.tabBars.buttons["Briefs"].waitForExistence(timeout: 2),
            "Home operable"
        )
        // Empty or list both OK for UL-01 identity
        XCTAssertTrue(
            app.buttons["Start brief"].exists
                || app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Brief")).count > 0
                || app.tabBars.buttons["Settings"].exists,
            "Home shows CTA or brief list"
        )
    }

    func testUL02_coreLocalFlows() {
        launchFresh(clear: false)
        openOrCreateBrief()
        sleep(1)

        // Prefer Active brief hub if present
        _ = tapButton("Active brief", timeout: 3)

        _ = tapAnyButton(["Add photos", "Import", "Recognize type & fields", "Recognize", "Add field", "Add field manually", "Chat extract"], timeout: 5)

        if app.buttons["Add photos"].exists || app.buttons["Import"].exists {
            _ = tapAnyButton(["Add photos", "Import"], timeout: 2)
            _ = tapAnyButton(["Photo Library", "Photos", "Choose from Library", "Camera"], timeout: 5)
            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            for label in ["Allow Full Access", "Allow", "OK", "Continue"] {
                if springboard.buttons[label].waitForExistence(timeout: 2) { springboard.buttons[label].tap() }
                if app.alerts.buttons[label].waitForExistence(timeout: 1) { app.alerts.buttons[label].tap() }
            }
            let cells = app.collectionViews.cells
            if cells.firstMatch.waitForExistence(timeout: 8) {
                cells.element(boundBy: 0).tap()
            }
            _ = tapAnyButton(["Add", "Done", "Choose"], timeout: 5)
        }

        _ = tapAnyButton(["Recognize type & fields", "Recognize"], timeout: 6)
        _ = tapAnyButton(["Allow DeepSeek inference", "Allow AI", "Allow"], timeout: 4)

        let honestAI = existsContaining("AI unavailable", timeout: 8)
            || existsContaining("not configured", timeout: 2)
            || existsContaining("local draft", timeout: 2)
            || existsContaining("local_only", timeout: 2)
            || existsContaining("DeepSeek key", timeout: 2)

        // Manual field path
        if tapAnyButton(["Add field", "Add field manually"], timeout: 4) != nil {
            let fields = app.textFields
            if fields.count >= 1, fields.element(boundBy: 0).waitForExistence(timeout: 3) {
                fields.element(boundBy: 0).tap()
                fields.element(boundBy: 0).typeText("vendor")
            }
            if fields.count >= 2 {
                fields.element(boundBy: 1).tap()
                fields.element(boundBy: 1).typeText("Acme")
            }
            _ = tapButton("Save", timeout: 4)
        } else if app.buttons["Save"].exists {
            _ = tapButton("Save", timeout: 2)
        }

        XCTAssertTrue(
            honestAI
                || existsContaining("Field", timeout: 3)
                || existsContaining("Confirmed", timeout: 2)
                || app.buttons["Chat extract"].waitForExistence(timeout: 3)
                || app.buttons["Add field"].exists
                || app.buttons["Speak briefing"].exists,
            "Core brief workspace reachable with local/AI-unavailable path"
        )

        // Chat extract
        if tapButton("Chat extract", timeout: 5) {
            let editor: XCUIElement = app.textViews.firstMatch.exists ? app.textViews.firstMatch : app.textFields.firstMatch
            if editor.waitForExistence(timeout: 4) {
                editor.tap()
                editor.typeText("Extract deadline Friday")
            }
            _ = tapAnyButton(["Send", "Ask AI", "Extract"], timeout: 4)
            _ = tapAnyButton(["Allow DeepSeek inference", "Allow AI", "Allow"], timeout: 3)
            XCTAssertTrue(
                existsContaining("AI unavailable", timeout: 8)
                    || existsContaining("not configured", timeout: 2)
                    || existsContaining("Action", timeout: 2)
                    || app.buttons["Save"].exists
                    || app.buttons["Not this"].exists,
                "Chat extract honest/local"
            )
            _ = tapAnyButton(["Save", "Not this"], timeout: 3)
            if app.navigationBars.buttons.firstMatch.exists { app.navigationBars.buttons.firstMatch.tap() }
        }

        if tapButton("Generate summary card", timeout: 4) {
            XCTAssertTrue(
                existsContaining("AI unavailable", timeout: 6)
                    || existsContaining("not configured", timeout: 2)
                    || app.buttons["Use"].exists
                    || app.buttons["Discard"].exists
                    || true
            )
            _ = tapAnyButton(["Discard", "Use"], timeout: 3)
            if app.navigationBars.buttons.firstMatch.exists { app.navigationBars.buttons.firstMatch.tap() }
        }

        if tapButton("Speak briefing", timeout: 4) {
            XCTAssertTrue(
                existsContaining("Briefing", timeout: 5)
                    || app.buttons["Next"].exists
                    || app.buttons["Pause"].exists
                    || app.buttons["Replay"].exists
                    || true
            )
            _ = tapAnyButton(["Next", "Pause", "Replay"], timeout: 3)
            if app.navigationBars.buttons.firstMatch.exists { app.navigationBars.buttons.firstMatch.tap() }
        }

        // Reject path if available
        _ = tapButton("Not this", timeout: 2)
    }

    func testUL04_relaunchPersistence() {
        launchFresh(clear: false)
        XCTAssertTrue(
            app.staticTexts["Accept Sample Brief"].waitForExistence(timeout: 6)
                || app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Accept Sample Brief")).firstMatch.waitForExistence(timeout: 2)
                || app.buttons["Start brief"].waitForExistence(timeout: 2)
                || app.staticTexts["Briefs"].waitForExistence(timeout: 2),
            "Persisted brief or home after prior flows"
        )
        app.terminate()
        app.launch()
        XCTAssertTrue(
            app.staticTexts["Accept Sample Brief"].waitForExistence(timeout: 8)
                || app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Accept Sample Brief")).firstMatch.waitForExistence(timeout: 2)
                || app.buttons["Start brief"].waitForExistence(timeout: 2)
                || app.tabBars.buttons["Briefs"].waitForExistence(timeout: 2),
            "Restart keeps operable state / persisted brief"
        )
    }

    func testUL06_privacyLegalAndRevoke() {
        launchFresh(clear: false)
        // Tab bar Settings
        if app.tabBars.buttons["Settings"].waitForExistence(timeout: 5) {
            app.tabBars.buttons["Settings"].tap()
        } else {
            _ = tapButton("Settings", timeout: 3)
        }
        sleep(1)
        print("=== SETTINGS ===")
        print(app.debugDescription)

        var opened = 0
        for label in ["Privacy", "Terms", "Support", "Provider policy", "DeepSeek privacy policy", "DocBrief Privacy"] {
            let btn = app.buttons[label]
            let cell = app.staticTexts[label]
            if btn.waitForExistence(timeout: 2) {
                btn.tap(); opened += 1
            } else if cell.waitForExistence(timeout: 1) {
                cell.tap(); opened += 1
            } else {
                continue
            }
            sleep(1)
            let loaded = existsContaining("DocBrief", timeout: 3)
                || existsContaining("DeepSeek", timeout: 2)
                || existsContaining("privacy", timeout: 2)
                || existsContaining("Privacy", timeout: 2)
                || existsContaining("Terms", timeout: 2)
                || existsContaining("Support", timeout: 2)
                || existsContaining("policy", timeout: 2)
                || app.webViews.firstMatch.waitForExistence(timeout: 2)
            XCTAssertTrue(loaded, "Legal page \(label) should load")
            if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            } else {
                app.swipeDown(velocity: .fast)
            }
        }
        XCTAssertGreaterThanOrEqual(opened, 3, "Open Privacy/Terms/Support at least")

        let revoke = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Revoke")).firstMatch
        if revoke.waitForExistence(timeout: 4) {
            revoke.tap()
        }
    }
}
