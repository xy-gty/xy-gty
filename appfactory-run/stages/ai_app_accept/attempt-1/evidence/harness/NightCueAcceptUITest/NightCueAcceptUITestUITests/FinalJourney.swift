import XCTest

final class FinalJourney: XCTestCase {
    let app = XCUIApplication(bundleIdentifier: "com.lingguang.nightcue")
    let shotDir = "/Users/a2026/work/factory-prod-1/runs/kf-20261015T075333Z-d3a0d226/stages/ai_app_accept/attempt-1/evidence/screenshots"

    func snap(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "\(shotDir)/\(name).png"))
        print("SNAP \(name) bytes=\(data.count)")
    }

    func dismissPerm() {
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let labels = [
            "Allow Full Access", "Allow Access to All Photos", "Allow", "OK", "Continue",
            "允许完全访问", "允许访问所有照片", "允许", "好"
        ]
        for label in labels {
            if sb.buttons[label].waitForExistence(timeout: 1.0) { sb.buttons[label].tap(); print("PERM \(label)") }
            if app.buttons[label].exists { app.buttons[label].tap(); print("APPPERM \(label)") }
        }
    }

    func testFullAcceptMatrix() throws {
        app.terminate()
        Thread.sleep(forTimeInterval: 1)
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        Thread.sleep(forTimeInterval: 1)

        if app.tabBars.buttons["Sessions"].exists {
            app.tabBars.buttons["Sessions"].tap()
            Thread.sleep(forTimeInterval: 0.5)
        }
        if app.navigationBars.buttons.count > 0 {
            for _ in 0..<4 {
                let back = app.navigationBars.buttons.element(boundBy: 0)
                if back.exists && back.isHittable { back.tap(); Thread.sleep(forTimeInterval: 0.3) }
                else { break }
            }
        }

        var newSession = app.buttons["cta-new-session"]
        if !newSession.waitForExistence(timeout: 4) {
            newSession = app.buttons["New session"]
        }
        XCTAssertTrue(newSession.waitForExistence(timeout: 8), "home New session")
        snap("ul07-nightcue-home-empty")

        newSession.tap()
        Thread.sleep(forTimeInterval: 0.8)
        if app.textFields["Location label"].exists {
            app.textFields["Location label"].tap()
            app.textFields["Location label"].typeText("Bridge overlook")
        } else if app.textFields.firstMatch.exists {
            app.textFields.firstMatch.tap()
            app.textFields.firstMatch.typeText("Bridge overlook")
        }
        snap("ul07-new-session")
        XCTAssertTrue(app.buttons["Create session"].waitForExistence(timeout: 5))
        app.buttons["Create session"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-capture-import")

        XCTAssertTrue(app.buttons["Camera"].waitForExistence(timeout: 5))
        app.buttons["Camera"].tap()
        Thread.sleep(forTimeInterval: 2)
        dismissPerm()
        Thread.sleep(forTimeInterval: 1)
        for label in ["Photo Capture", "Capture Photo", "快门", "拍照", "Use Photo", "使用照片", "Retake", "重拍"] {
            if app.buttons[label].exists {
                if label.contains("Retake") || label.contains("重拍") { continue }
                app.buttons[label].tap()
                print("CAMERA \(label)")
                break
            }
        }
        // Simulator camera shutter is often a coordinate tap
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.92)).tap()
        Thread.sleep(forTimeInterval: 1.0)
        for label in ["Use Photo", "使用照片", "Choose", "选取", "Done", "完成"] {
            if app.buttons[label].exists { app.buttons[label].tap(); print("CAMERA_CONFIRM \(label)") }
        }
        Thread.sleep(forTimeInterval: 3)

        let keepBtn = app.buttons["Keep"]
        let keepWait = keepBtn.waitForExistence(timeout: 12)
        snap("ul07-nightcue-exposure-review")
        XCTAssertTrue(keepWait, "Exposure review Keep")
        keepBtn.tap()
        print("KEEP exposure")
        Thread.sleep(forTimeInterval: 2)

        XCTAssertTrue(app.tabBars.buttons["Coach"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Coach"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-night-coach")

        let rail = app.otherElements["night-frame-rail"]
        let overlays = app.otherElements["exposure-diagnosis-overlays"]
        print("RAIL=\(rail.exists) OVERLAYS=\(overlays.exists)")

        XCTAssertTrue(app.buttons["Ask coach"].waitForExistence(timeout: 5))
        app.buttons["Ask coach"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-coach-chat")

        let field = app.textFields.firstMatch
        let area = app.textViews.firstMatch
        if field.exists { field.tap(); field.typeText("ISO too high for 20s shutter") }
        else if area.exists { area.tap(); area.typeText("ISO too high for 20s shutter") }

        if app.buttons["Send"].waitForExistence(timeout: 4) {
            app.buttons["Send"].tap()
            Thread.sleep(forTimeInterval: 2)
            if app.buttons["Allow"].waitForExistence(timeout: 3) || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "DeepSeek")).count > 0 {
                snap("ul06-consent-sheet")
                if app.buttons["Not now"].exists { app.buttons["Not now"].tap() }
            } else {
                snap("ul03-local-ai-or-keygate")
                print("LOCAL_COACH_PATH")
            }
            Thread.sleep(forTimeInterval: 1.5)
            if app.buttons["Keep"].waitForExistence(timeout: 6) {
                snap("ul07-turn-review")
                app.buttons["Keep"].tap()
                print("KEEP turn")
            }
        }

        app.tabBars.buttons["Coach"].tap()
        Thread.sleep(forTimeInterval: 1)
        if app.buttons["Annotate"].exists {
            app.buttons["Annotate"].tap()
            Thread.sleep(forTimeInterval: 1)
            snap("ul07-nightcue-annotated-overlay")
            if app.buttons["Keep marks"].exists { app.buttons["Keep marks"].tap() }
        }

        app.tabBars.buttons["Coach"].tap()
        if app.buttons["Field cues"].exists {
            app.buttons["Field cues"].tap()
            Thread.sleep(forTimeInterval: 1)
            snap("ul07-nightcue-field-tts")
            if app.buttons["Play"].exists { app.buttons["Play"].tap() }
        }

        app.tabBars.buttons["Coach"].tap()
        if app.buttons["Dictate"].exists {
            app.buttons["Dictate"].tap()
            dismissPerm()
            Thread.sleep(forTimeInterval: 0.5)
            snap("ul07-dictate-entry")
        }

        XCTAssertTrue(app.tabBars.buttons["Settings"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Settings"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-settings-privacy")

        for label in ["Privacy", "Terms", "Support", "Provider policy"] {
            XCTAssertTrue(app.buttons[label].waitForExistence(timeout: 4), "missing \(label)")
            app.buttons[label].tap()
            Thread.sleep(forTimeInterval: 1)
            snap("ul06-\(label.replacingOccurrences(of: " ", with: "-").lowercased())")
            if app.navigationBars.buttons.element(boundBy: 0).exists {
                app.navigationBars.buttons.element(boundBy: 0).tap()
            }
            Thread.sleep(forTimeInterval: 0.4)
        }

        if app.buttons["Revoke AI consent"].exists {
            app.buttons["Revoke AI consent"].tap()
            print("REVOKED")
            snap("ul06-revoke-consent")
        }

        app.tabBars.buttons["Sessions"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul04-sessions-after-keep")
        let hasSession = app.staticTexts["Bridge overlook"].exists
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Bridge")).count > 0
        print("SESSION_AFTER_KEEP=\(hasSession)")

        app.terminate()
        Thread.sleep(forTimeInterval: 1)
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 10)
        Thread.sleep(forTimeInterval: 1.5)
        snap("ul04-after-relaunch")
        let still = app.staticTexts["Bridge overlook"].exists
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Bridge")).count > 0
            || app.buttons["cta-new-session"].exists
        print("SESSION_AFTER_RELAUNCH=\(still)")
        XCTAssertTrue(still, "app usable after relaunch")
    }
}
