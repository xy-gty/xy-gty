import XCTest

final class LegalPagesOnly: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261014T091741Z-3d7b568c/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication(bundleIdentifier: "com.lingguang.scoutcue")
        app.terminate()
        app.launch()
        sleep(1)
        for _ in 0 ..< 8 {
            if app.buttons["Settings"].exists { break }
            let back = app.navigationBars.buttons["Back"]
            if back.waitForExistence(timeout: 1) { back.tap(); sleep(1) } else { break }
        }
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

    func testOpenEachLegalPage() throws {
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 8))
        app.buttons["Settings"].tap()
        sleep(1)
        shot("rt-settings-privacy.png")
        dump("ul06-01-settings.ax.txt")

        let pages: [(String, String, String)] = [
            ("Privacy", "ul06-privacy.png", "ul06-privacy.ax.txt"),
            ("Terms", "ul06-terms.png", "ul06-terms.ax.txt"),
            ("Support", "ul06-support.png", "ul06-support.ax.txt"),
            ("DeepSeek provider policy", "ul06-provider.png", "ul06-provider.ax.txt"),
        ]
        for (label, shotName, dumpName) in pages {
            // Ensure on Settings list
            for _ in 0 ..< 4 {
                if app.buttons[label].exists || app.staticTexts[label].exists { break }
                let back = app.navigationBars.buttons["Back"]
                if back.exists { back.tap(); sleep(1) } else { break }
            }
            let btn = app.buttons[label]
            XCTAssertTrue(btn.waitForExistence(timeout: 6), "\(label) row missing")
            btn.tap()
            sleep(2)
            shot(shotName)
            dump(dumpName)
            // iOS shows parent title on the back control ("Settings"), not "Back"
            let back = app.navigationBars.buttons.matching(
                NSPredicate(format: "label == %@ OR identifier == %@", "Settings", "BackButton")
            ).firstMatch
            XCTAssertTrue(back.waitForExistence(timeout: 3), "Back/Settings missing after \(label)")
            back.tap()
            sleep(1)
        }
    }
}
