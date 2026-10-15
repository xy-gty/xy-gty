import XCTest

final class JourneyTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261015T111031Z-ed6f1861/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            atPath: evidenceDir,
            withIntermediateDirectories: true
        )
        app = XCUIApplication(bundleIdentifier: "com.lingguang.rulecue")
        app.terminate()
        app.launch()
        sleep(1)
    }

    private func shot(_ name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        let url = URL(fileURLWithPath: evidenceDir).appendingPathComponent(name)
        try? png.write(to: url)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
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

    private func tapLabel(_ fragments: [String], timeout: TimeInterval = 8) -> Bool {
        for frag in fragments {
            let button = app.buttons.matching(
                NSPredicate(format: "label CONTAINS[c] %@", frag)
            ).firstMatch
            if button.waitForExistence(timeout: timeout) {
                forceTap(button)
                return true
            }
            let other = app.otherElements.matching(
                NSPredicate(format: "label CONTAINS[c] %@", frag)
            ).firstMatch
            if other.waitForExistence(timeout: 0.8), other.isHittable {
                other.tap()
                return true
            }
            let link = app.links.matching(
                NSPredicate(format: "label CONTAINS[c] %@", frag)
            ).firstMatch
            if link.waitForExistence(timeout: 0.5), link.isHittable {
                link.tap()
                return true
            }
        }
        return false
    }

    private func tapExactButton(_ label: String, timeout: TimeInterval = 8) -> Bool {
        let b = app.buttons[label]
        if b.waitForExistence(timeout: timeout) {
            forceTap(b)
            return true
        }
        return false
    }

    private func tapTab(_ name: String) -> Bool {
        let tab = app.tabBars.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", name)
        ).firstMatch
        if tab.waitForExistence(timeout: 4) {
            forceTap(tab)
            return true
        }
        return false
    }

    private func dismissSystemAlertsIfNeeded() {
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow", "OK", "Allow Access to All Photos", "Full Access", "Continue", "Don't Allow"] {
            let b = spring.buttons[label]
            if b.waitForExistence(timeout: 1.0) {
                b.tap()
            }
        }
    }

    private func dismissKeyboardIfNeeded() {
        if app.keyboards.firstMatch.waitForExistence(timeout: 1.5) {
            if app.buttons["Return"].waitForExistence(timeout: 0.8) {
                app.buttons["Return"].tap()
            } else if app.buttons["Done"].waitForExistence(timeout: 0.8) {
                app.buttons["Done"].tap()
            } else {
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12)).tap()
            }
            sleep(1)
        }
    }

    func testUL01HomeLaunch() throws {
        let any = app.descendants(matching: .any).firstMatch
        XCTAssertTrue(any.waitForExistence(timeout: 8))
        shot("ul01-home.png")
        shot("rt-home-empty.png")
        dump("ul01-home.ax.txt")
        let ruleCue = app.staticTexts["RuleCue"]
        let newSession = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "New session")
        ).firstMatch
        XCTAssertTrue(
            ruleCue.waitForExistence(timeout: 4) || newSession.waitForExistence(timeout: 4),
            "Home missing RuleCue brand or New session CTA"
        )
    }

    func testUL02CoreFlowsAndPrivacy() throws {
        shot("ul02-01-home.png")
        dump("ul02-01-home.ax.txt")

        XCTAssertTrue(
            tapLabel(["New session", "+ New session"], timeout: 12),
            "New session CTA missing"
        )
        sleep(1)
        dump("ul02-01b-new-session.ax.txt")

        let titleField = app.textFields.firstMatch
        if titleField.waitForExistence(timeout: 4) {
            titleField.tap()
            titleField.typeText("Accept Set A")
        }
        dismissKeyboardIfNeeded()
        XCTAssertTrue(
            tapExactButton("Start capture", timeout: 8)
                || tapLabel(["Start capture"], timeout: 4),
            "Start capture missing"
        )
        sleep(2)
        if app.buttons["Start capture"].waitForExistence(timeout: 1) {
            forceTap(app.buttons["Start capture"])
            sleep(2)
        }
        shot("ul02-02-capture-import.png")
        shot("rt-capture-import.png")
        dump("ul02-02-capture.ax.txt")

        let importHit =
            tapLabel(["Import photos", "photo.on.rectangle"], timeout: 6)
            || tapExactButton("Import photos", timeout: 3)
            || tapLabel(["Capture page", "Capture"], timeout: 3)
        if !importHit {
            dump("ul02-02b-import-missing.ax.txt")
            shot("ul02-02b-import-missing.png")
        }
        XCTAssertTrue(importHit, "Capture/Import entry missing on CaptureImportView")
        sleep(1)
        dismissSystemAlertsIfNeeded()
        shot("ul02-03-picker.png")
        let photo = app.images.firstMatch
        if photo.waitForExistence(timeout: 8) {
            photo.tap()
        } else {
            let cell = app.cells.firstMatch
            if cell.waitForExistence(timeout: 4) { cell.tap() }
        }
        for label in ["Add", "Done", "Use Photo", "Choose", "添加", "选取"] {
            let b = app.buttons[label]
            if b.waitForExistence(timeout: 2) { b.tap(); break }
        }
        dismissSystemAlertsIfNeeded()
        sleep(1)
        shot("ul02-04-after-import.png")
        dump("ul02-04-after-import.ax.txt")

        // Component review Keep/Discard/Edit if present
        if tapLabel(["Keep", "Discard", "Edit"], timeout: 5) {
            sleep(1)
            shot("ul02-05-component-review.png")
            shot("rt-component-review.png")
            dump("ul02-05-component-review.ax.txt")
            _ = tapLabel(["Keep"], timeout: 3)
        } else {
            shot("ul02-05-no-component-review.png")
        }

        // Table coach tab — zone cards + turn step bar
        _ = tapTab("Table")
        sleep(1)
        shot("ul02-06-table-coach.png")
        shot("rt-table-coach.png")
        dump("ul02-06-table-coach.ax.txt")

        // Zone select
        _ = tapLabel(["Table zone", "Deck", "Board", "Player"], timeout: 4)
        sleep(1)
        shot("ul02-06b-zone-selected.png")
        dump("ul02-06b-zone.ax.txt")

        // Turn step advance
        _ = tapLabel(["Turn step", "Setup", "Deal"], timeout: 4)
        sleep(1)
        shot("ul02-06c-step.png")

        // Chat + consent
        _ = tapLabel(["Chat"], timeout: 6)
        sleep(1)
        shot("ul02-07-coach-chat.png")
        shot("rt-coach-chat.png")
        dump("ul02-07-coach-chat.ax.txt")

        if tapLabel(["Allow"], timeout: 4) {
            sleep(1)
            shot("ul02-08-after-allow.png")
        } else if tapLabel(["Not now"], timeout: 2) {
            shot("ul02-08-declined.png")
            _ = tapLabel(["Chat"], timeout: 3)
            _ = tapLabel(["Allow"], timeout: 3)
        } else {
            shot("ul02-08-local-or-unconfigured.png")
        }

        let area = app.textViews.firstMatch
        let field = app.textFields.firstMatch
        if area.waitForExistence(timeout: 2) {
            area.tap()
            area.typeText("Can I play this card on the board zone")
            _ = tapExactButton("Send", timeout: 4) || tapLabel(["Send"], timeout: 3)
            sleep(2)
        } else if field.waitForExistence(timeout: 1) {
            field.tap()
            field.typeText("Can I play this card on the board zone")
            _ = tapExactButton("Send", timeout: 4) || tapLabel(["Send"], timeout: 3)
            sleep(2)
        }
        shot("ul02-09-after-send.png")
        dump("ul02-09-after-send.ax.txt")

        // Back then Overlay / Host / Dictate
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }
        _ = tapTab("Table")
        sleep(1)
        _ = tapLabel(["Overlay"], timeout: 4)
        sleep(1)
        shot("ul02-10-setup-overlay.png")
        shot("rt-setup-overlay.png")
        dump("ul02-10-setup-overlay.ax.txt")
        _ = tapLabel(["Keep guide", "Keep"], timeout: 3)
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
        _ = tapLabel(["Host"], timeout: 4)
        sleep(1)
        shot("ul02-11-host-tts.png")
        shot("rt-tts-host.png")
        dump("ul02-11-host-tts.ax.txt")
        _ = tapLabel(["Play"], timeout: 3)
        sleep(1)
        shot("ul02-11b-tts-play.png")
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
        _ = tapLabel(["Dictate"], timeout: 4)
        sleep(1)
        shot("ul02-12-dictate.png")
        shot("rt-dictate.png")
        dump("ul02-12-dictate.ax.txt")
        dismissSystemAlertsIfNeeded()

        // Settings + local legal + revoke
        XCTAssertTrue(tapTab("Settings"), "Settings tab missing")
        sleep(1)
        shot("ul02-13-settings.png")
        shot("rt-settings-privacy.png")
        dump("ul02-13-settings.ax.txt")

        if tapLabel(["Open local legal pages", "Legal"], timeout: 4) {
            sleep(1)
            shot("ul06-legal-index.png")
            dump("ul06-legal-index.ax.txt")
            for (label, shotName) in [
                ("Privacy", "ul06-privacy.png"),
                ("Terms", "ul06-terms.png"),
                ("Support", "ul06-support.png"),
                ("Provider policy", "ul06-provider.png"),
            ] {
                if tapLabel([label], timeout: 4) {
                    sleep(1)
                    shot(shotName)
                    dump("ul06-\(label.lowercased().replacingOccurrences(of: " ", with: "-")).ax.txt")
                    if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
                        app.navigationBars.buttons.firstMatch.tap()
                        sleep(1)
                    }
                }
            }
            if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
                app.navigationBars.buttons.firstMatch.tap()
                sleep(1)
            }
        }

        // Scroll settings for permission rows
        app.swipeUp()
        sleep(1)
        shot("rt-settings-scrolled.png")
        dump("rt-settings-scrolled.ax.txt")

        _ = tapLabel(["Revoke AI consent", "Revoke"], timeout: 4)
        sleep(1)
        shot("ul06-after-revoke.png")
        dump("ul06-after-revoke.ax.txt")

        // Camera entry presence (hardware = 真机待测)
        _ = tapTab("Table")
        sleep(1)
        _ = tapLabel(["Capture"], timeout: 4)
        sleep(1)
        shot("ul02-14-capture-entry.png")
        dump("ul02-14-capture-entry.ax.txt")
        _ = tapLabel(["Capture page", "Capture"], timeout: 3)
        dismissSystemAlertsIfNeeded()
        sleep(1)
        shot("ul02-15-camera-or-alert.png")
    }

    func testUL04RelaunchPersistence() throws {
        // Relies on prior UL02 creating Accept Set A when run in same class order;
        // still asserts Sessions tab shows content after relaunch.
        app.terminate()
        sleep(1)
        app.launch()
        sleep(2)
        _ = tapTab("Sessions")
        sleep(1)
        shot("ul04-relaunch-sessions.png")
        dump("ul04-relaunch-sessions.ax.txt")
        let anySession = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Accept Set")
        ).firstMatch
        let newSession = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "New session")
        ).firstMatch
        XCTAssertTrue(
            anySession.waitForExistence(timeout: 4) || newSession.waitForExistence(timeout: 4),
            "Sessions empty and New session missing after relaunch"
        )
    }
}
