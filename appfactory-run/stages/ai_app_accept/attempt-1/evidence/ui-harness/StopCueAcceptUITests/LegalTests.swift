import XCTest

final class LegalTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261015T093242Z-0f4256a0/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication(bundleIdentifier: "com.lingguang.stopcue")
        app.terminate()
        app.launch()
        sleep(1)
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

    private func forceTap(_ e: XCUIElement) {
        if e.isHittable { e.tap() }
        else { e.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
    }

    func testSettingsLegalPages() throws {
        // Pop any pushed New project form
        for _ in 0..<3 {
            if app.navigationBars.buttons["Back"].waitForExistence(timeout: 1)
                || app.buttons["BackButton"].waitForExistence(timeout: 0.5) {
                let back = app.navigationBars.buttons.firstMatch
                if back.exists { forceTap(back); sleep(1) }
            } else { break }
        }
        let settings = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 6))
        forceTap(settings)
        sleep(1)
        shot("rt-settings-privacy.png")
        dump("rt-settings-legal.ax.txt")

        for (label, file) in [
            ("Privacy", "ul06-privacy"),
            ("Terms", "ul06-terms"),
            ("Support", "ul06-support"),
            ("Provider policy", "ul06-provider"),
        ] {
            let link = app.descendants(matching: .any).matching(
                NSPredicate(format: "label == %@", label)
            ).firstMatch
            if link.waitForExistence(timeout: 5) {
                forceTap(link)
                sleep(2)
                shot("\(file).png")
                dump("\(file).ax.txt")
                let back = app.navigationBars.buttons.firstMatch
                if back.waitForExistence(timeout: 2) { forceTap(back); sleep(1) }
            } else {
                dump("\(file)-missing.ax.txt")
            }
        }

        // Open existing project → Coach for sprocket/onion
        forceTap(app.tabBars.buttons["Projects"])
        sleep(1)
        shot("rt-projects-list.png")
        dump("rt-projects-list.ax.txt")
        let cell = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Accept Set")
        ).firstMatch
        let anyProj = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Stop-motion")
        ).firstMatch
        let follow = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Followup")
        ).firstMatch
        if cell.waitForExistence(timeout: 3) { forceTap(cell) }
        else if follow.waitForExistence(timeout: 2) { forceTap(follow) }
        else if anyProj.waitForExistence(timeout: 2) { forceTap(anyProj) }
        sleep(1)
        forceTap(app.tabBars.buttons["Coach"])
        sleep(1)
        shot("rt-stop-coach.png")
        dump("rt-stop-coach.ax.txt")
        let chat = app.buttons["Chat"]
        if chat.waitForExistence(timeout: 4) {
            forceTap(chat)
            sleep(1)
            shot("rt-coach-chat.png")
            dump("rt-coach-chat.ax.txt")
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }
        let onion = app.buttons["Onion"]
        if onion.waitForExistence(timeout: 4) {
            forceTap(onion)
            sleep(1)
            shot("rt-onion-overlay.png")
            dump("rt-onion-overlay.ax.txt")
        }
    }
}
