import XCTest

final class SeededJourney: XCTestCase {
    let app = XCUIApplication(bundleIdentifier: "com.lingguang.nightcue")
    let shotDir = "/Users/a2026/work/factory-prod-1/runs/kf-20261015T075333Z-d3a0d226/stages/ai_app_accept/attempt-1/evidence/screenshots"

    func snap(_ name: String) {
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "\(shotDir)/\(name).png"))
        print("SNAP \(name)")
    }

    func testSeededCoachAndSettings() throws {
        app.terminate()
        Thread.sleep(forTimeInterval: 1)
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
        Thread.sleep(forTimeInterval: 1.5)

        app.tabBars.buttons["Sessions"].tap()
        Thread.sleep(forTimeInterval: 1)
        if app.staticTexts["Bridge overlook"].exists {
            app.staticTexts["Bridge overlook"].tap()
        }
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-night-coach")
        XCTAssertTrue(app.buttons["Ask coach"].waitForExistence(timeout: 6))
        app.buttons["Ask coach"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-coach-chat")
        if app.textFields.firstMatch.exists {
            app.textFields.firstMatch.tap()
            app.textFields.firstMatch.typeText("Reduce noise at ISO 3200")
        }
        app.buttons["Send"].tap()
        Thread.sleep(forTimeInterval: 2)
        snap("ul03-local-ai-or-keygate")
        if app.buttons["Keep"].waitForExistence(timeout: 6) {
            snap("ul07-turn-review")
            app.buttons["Keep"].tap()
        }

        app.tabBars.buttons["Coach"].tap()
        app.buttons["Annotate"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-annotated-overlay")
        app.buttons["Field cues"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-field-tts")
        if app.buttons["Play"].exists { app.buttons["Play"].tap() }

        app.tabBars.buttons["Settings"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul07-nightcue-settings-privacy")
        for label in ["Privacy", "Terms", "Support", "Provider policy"] {
            let pred = NSPredicate(format: "label == %@", label)
            let match = app.staticTexts.matching(pred).firstMatch
            if match.waitForExistence(timeout: 3) {
                match.tap()
                Thread.sleep(forTimeInterval: 0.8)
                snap("ul06-\(label.replacingOccurrences(of: " ", with: "-").lowercased())")
                if app.navigationBars.buttons.element(boundBy: 0).exists {
                    app.navigationBars.buttons.element(boundBy: 0).tap()
                }
            } else {
                print("SKIP legal link \(label)")
            }
        }
        app.buttons["Revoke AI consent"].tap()
        snap("ul06-revoke-consent")

        for _ in 0..<6 {
            let back = app.navigationBars.buttons.element(boundBy: 0)
            if back.exists && back.isHittable { back.tap(); Thread.sleep(forTimeInterval: 0.3) }
            else { break }
        }
        app.tabBars.buttons["Sessions"].tap()
        Thread.sleep(forTimeInterval: 1)
        snap("ul04-sessions-after-keep")

        app.terminate()
        Thread.sleep(forTimeInterval: 1)
        app.launch()
        _ = app.wait(for: .runningForeground, timeout: 10)
        Thread.sleep(forTimeInterval: 1.5)
        snap("ul04-after-relaunch")
        let alive = app.staticTexts["Hands-free field cues"].exists
            || app.staticTexts["NightCue"].exists
            || app.buttons["cta-new-session"].exists
            || app.buttons["Play"].exists
        XCTAssertTrue(alive)
    }
}
