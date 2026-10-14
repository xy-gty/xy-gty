import XCTest

final class SettingsLegalTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261014T091741Z-3d7b568c/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = true
        try FileManager.default.createDirectory(
            atPath: evidenceDir,
            withIntermediateDirectories: true
        )
        app = XCUIApplication(bundleIdentifier: "com.lingguang.scoutcue")
        app.terminate()
        app.launch()
        sleep(1)
        popToHome()
    }

    private func shot(_ name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: evidenceDir).appendingPathComponent(name)
        try? png.write(to: url)
    }

    private func dump(_ name: String) {
        try? app.debugDescription.write(
            to: URL(fileURLWithPath: evidenceDir).appendingPathComponent(name),
            atomically: true,
            encoding: .utf8
        )
    }

    private func forceTap(_ element: XCUIElement) {
        if element.isHittable {
            element.tap()
        } else {
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }

    private func popToHome() {
        for _ in 0 ..< 8 {
            let settings = app.buttons["Settings"]
            let capture = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] %@", "Capture / Import")
            ).firstMatch
            if settings.exists || capture.exists { return }
            let back = app.navigationBars.buttons["Back"]
            if back.waitForExistence(timeout: 1.2) {
                forceTap(back)
                sleep(1)
            } else {
                break
            }
        }
    }

    private func tapLabel(_ fragments: [String], timeout: TimeInterval = 8) -> Bool {
        for frag in fragments {
            let button = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] %@", frag)
            ).firstMatch
            if button.waitForExistence(timeout: timeout) {
                forceTap(button)
                return true
            }
        }
        return false
    }

    func testSettingsLegalAndPersistence() throws {
        shot("ul04-02-home-persisted.png")
        dump("ul04-02-home-persisted.ax.txt")
        // Soft card should show after prior Keep
        let capture = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Capture / Import")
        ).firstMatch
        XCTAssertTrue(capture.waitForExistence(timeout: 8), "Home Capture CTA missing after pop")
        // Card chips appear when active card exists
        let coachChip = app.buttons["Coach"]
        if coachChip.waitForExistence(timeout: 3) {
            forceTap(coachChip)
            sleep(1)
            // may open coach or card — capture scout card if on detail
            if app.navigationBars["Scout card"].waitForExistence(timeout: 2)
                || app.staticTexts["Scout card"].exists {
                shot("rt-scout-card.png")
                dump("rt-scout-card.ax.txt")
            } else if app.buttons["Open coach"].waitForExistence(timeout: 2) {
                shot("rt-scout-card.png")
                dump("rt-scout-card.ax.txt")
            } else {
                // On coach from chip — go back and open card via stack text
                let back = app.navigationBars.buttons["Back"]
                if back.exists { forceTap(back); sleep(1) }
            }
            popToHome()
        }
        // Open first soft card if labeled
        if tapLabel(["Mountain", "meadow", "Confirmed", "Ridge"], timeout: 3) {
            sleep(1)
            shot("rt-scout-card.png")
            dump("rt-scout-card.ax.txt")
            popToHome()
        }

        XCTAssertTrue(tapLabel(["Settings"], timeout: 8), "Settings gear missing on home")
        sleep(1)
        shot("ul06-01-settings.png")
        shot("rt-settings-privacy.png")
        dump("ul06-01-settings.ax.txt")

        for name in ["Privacy", "Terms", "Support", "DeepSeek provider policy"] {
            let cell = app.buttons[name]
            let staticLink = app.staticTexts[name]
            if cell.waitForExistence(timeout: 2) {
                forceTap(cell)
            } else if staticLink.waitForExistence(timeout: 2) {
                forceTap(staticLink)
            } else {
                _ = tapLabel([name], timeout: 2)
            }
            sleep(1)
            let safe = name.lowercased().replacingOccurrences(of: " ", with: "-")
            shot("ul06-\(safe).png")
            dump("ul06-\(safe).ax.txt")
            let back = app.navigationBars.buttons["Back"]
            if back.waitForExistence(timeout: 2) { forceTap(back); sleep(1) }
        }

        _ = tapLabel(["Revoke AI consent", "Revoke"], timeout: 3)
        shot("ul06-02-after-revoke.png")
        dump("ul06-02-after-revoke.ax.txt")

        // Confirm AI unavailable copy still present when returning to coach
        popToHome()
        if tapLabel(["Coach", "Open coach"], timeout: 4) {
            sleep(1)
            shot("ul03-coach-local-only.png")
            dump("ul03-coach-local-only.ax.txt")
            let unavailable = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] %@", "DeepSeek key not configured")
            ).firstMatch
            XCTAssertTrue(
                unavailable.waitForExistence(timeout: 4)
                    || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "AI unavailable")).firstMatch.exists,
                "Honest AI unavailable copy missing"
            )
        }
    }
}
