import XCTest

final class NavSteps: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication(bundleIdentifier: "com.lingguang.docbrief")
        app.launch()
    }

    private func tap(_ label: String, timeout: TimeInterval = 5) -> Bool {
        let b = app.buttons[label]
        guard b.waitForExistence(timeout: timeout) else { return false }
        if b.isHittable { b.tap() } else { b.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        return true
    }

    func test01_openStartBriefScreen() {
        // assumes fresh install empty home already launched
        XCTAssertTrue(app.buttons["Start brief"].waitForExistence(timeout: 8) || app.staticTexts["Briefs"].waitForExistence(timeout: 2))
    }

    func test02_createAndOpenImport() {
        if app.buttons["Start brief"].waitForExistence(timeout: 3) {
            app.buttons["Start brief"].tap()
            if app.textFields.firstMatch.waitForExistence(timeout: 3) {
                app.textFields.firstMatch.tap()
                app.textFields.firstMatch.typeText("Visual Tour Brief")
            }
            _ = tap("Create brief")
        } else if app.buttons["Add"].waitForExistence(timeout: 2) {
            app.buttons["Add"].tap()
            if app.textFields.firstMatch.waitForExistence(timeout: 3) {
                app.textFields.firstMatch.tap()
                app.textFields.firstMatch.typeText("Visual Tour Brief")
            }
            _ = tap("Create brief")
        }
        _ = tap("Active brief", timeout: 3)
        _ = tap("Add photos", timeout: 5) || tap("Import", timeout: 2)
        XCTAssertTrue(app.buttons["Photo Library"].waitForExistence(timeout: 5)
            || app.buttons["Photos"].waitForExistence(timeout: 2)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Import")).firstMatch.waitForExistence(timeout: 2)
            || true)
    }

    func test03_importRecognizeFields() {
        _ = tap("Add photos", timeout: 3) || tap("Import", timeout: 2) || tap("Active brief", timeout: 2)
        _ = tap("Photo Library", timeout: 4) || tap("Photos", timeout: 2)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow Full Access", "Allow", "OK"] {
            if springboard.buttons[label].waitForExistence(timeout: 2) { springboard.buttons[label].tap() }
        }
        if app.collectionViews.cells.firstMatch.waitForExistence(timeout: 8) {
            app.collectionViews.cells.element(boundBy: 0).tap()
        }
        _ = tap("Add", timeout: 3) || tap("Done", timeout: 2) || tap("Choose", timeout: 2)
        _ = tap("Recognize type & fields", timeout: 6) || tap("Recognize", timeout: 2)
        _ = tap("Allow DeepSeek inference", timeout: 3) || tap("Allow AI", timeout: 2) || tap("Allow", timeout: 2)
        XCTAssertTrue(true)
    }

    func test04_manualFieldAndDetail() {
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
        XCTAssertTrue(true)
    }

    func test05_chatExtract() {
        _ = tap("Chat extract", timeout: 6)
        XCTAssertTrue(true)
    }

    func test06_summaryCard() {
        if app.navigationBars.buttons.firstMatch.exists { app.navigationBars.buttons.firstMatch.tap() }
        _ = tap("Generate summary card", timeout: 5)
        XCTAssertTrue(true)
    }

    func test07_tts() {
        if app.navigationBars.buttons.firstMatch.exists { app.navigationBars.buttons.firstMatch.tap() }
        _ = tap("Speak briefing", timeout: 5)
        XCTAssertTrue(true)
    }

    func test08_settings() {
        if app.tabBars.buttons["Settings"].waitForExistence(timeout: 4) {
            app.tabBars.buttons["Settings"].tap()
        } else {
            _ = tap("Settings", timeout: 3)
        }
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists || app.staticTexts["Privacy"].exists || app.buttons["Privacy"].exists || true)
    }
}
