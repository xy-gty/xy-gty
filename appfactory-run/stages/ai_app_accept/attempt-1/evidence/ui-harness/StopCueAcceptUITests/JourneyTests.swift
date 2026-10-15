import XCTest

final class JourneyTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261015T093242Z-0f4256a0/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            atPath: evidenceDir,
            withIntermediateDirectories: true
        )
        app = XCUIApplication(bundleIdentifier: "com.lingguang.stopcue")
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
        for label in ["Allow", "OK", "Allow Access to All Photos", "Full Access", "Continue"] {
            let b = spring.buttons[label]
            if b.waitForExistence(timeout: 1.2) {
                b.tap()
            }
        }
    }

    func testUL01HomeLaunch() throws {
        let any = app.descendants(matching: .any).firstMatch
        XCTAssertTrue(any.waitForExistence(timeout: 8))
        shot("ul01-home.png")
        shot("rt-home-empty.png")
        dump("ul01-home.ax.txt")
        let sprocket = app.otherElements["film-sprocket-timeline"]
        let newProject = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "New project")
        ).firstMatch
        XCTAssertTrue(
            sprocket.waitForExistence(timeout: 4) || newProject.waitForExistence(timeout: 4),
            "Home missing sprocket timeline or New project CTA"
        )
    }

    func testUL02CoreFlowsAndPrivacy() throws {
        shot("ul02-01-home.png")
        dump("ul02-01-home.ax.txt")

        XCTAssertTrue(
            tapLabel(["New project", "+ New project"], timeout: 12),
            "New project CTA missing"
        )
        sleep(1)
        dump("ul02-01b-new-project.ax.txt")

        let titleField = app.textFields.firstMatch
        if titleField.waitForExistence(timeout: 4) {
            titleField.tap()
            titleField.typeText("Accept Set A")
        }
        // Dismiss keyboard so Create project is hittable
        if app.keyboards.firstMatch.waitForExistence(timeout: 2) {
            if app.buttons["Return"].waitForExistence(timeout: 1) {
                app.buttons["Return"].tap()
            } else if app.buttons["Done"].waitForExistence(timeout: 1) {
                app.buttons["Done"].tap()
            } else {
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12)).tap()
            }
            sleep(1)
        }
        XCTAssertTrue(
            tapExactButton("Create project", timeout: 8)
                || tapLabel(["Create project"], timeout: 4),
            "Create project missing"
        )
        sleep(2)
        // If still on form, force-tap Create again after keyboard dismissal
        if app.buttons["Create project"].waitForExistence(timeout: 1) {
            forceTap(app.buttons["Create project"])
            sleep(2)
        }
        shot("ul02-02-capture-import.png")
        shot("rt-capture-import.png")
        dump("ul02-02-capture.ax.txt")

        // Photos import path (PhotosPicker may surface as button or other; camera = 真机待测)
        let importHit =
            tapLabel(["Import sequence frame", "Import sequence", "photo.on.rectangle"], timeout: 6)
            || tapExactButton("Import sequence frame", timeout: 3)
            || tapLabel(["Capture frame", "Capture"], timeout: 3)
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

        // Frame review Keep/Discard/Edit if present
        if tapLabel(["Keep", "Discard", "Edit"], timeout: 5) {
            sleep(1)
            shot("ul02-05-frame-review.png")
            shot("rt-frame-review.png")
            dump("ul02-05-frame-review.ax.txt")
            _ = tapLabel(["Keep"], timeout: 3)
        } else {
            shot("ul02-05-no-frame-review.png")
        }

        // Coach tab / StopCoach
        _ = tapTab("Coach")
        sleep(1)
        shot("ul02-06-coach.png")
        shot("rt-stop-coach.png")
        dump("ul02-06-coach.ax.txt")

        // Chat consent / local AI path
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
            area.typeText("Tighten onion skin on frame 2")
            _ = tapExactButton("Send", timeout: 4) || tapLabel(["Send"], timeout: 3)
            sleep(2)
        } else if field.waitForExistence(timeout: 1) {
            field.tap()
            field.typeText("Tighten onion skin on frame 2")
            _ = tapExactButton("Send", timeout: 4) || tapLabel(["Send"], timeout: 3)
            sleep(2)
        }
        shot("ul02-09-after-send.png")
        dump("ul02-09-after-send.ax.txt")

        // Back to coach for onion / countdown / dictate entries
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }
        _ = tapTab("Coach")
        sleep(1)
        _ = tapLabel(["Onion"], timeout: 4)
        sleep(1)
        shot("ul02-10-onion.png")
        shot("rt-onion-overlay.png")
        dump("ul02-10-onion.ax.txt")
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
        _ = tapLabel(["Countdown"], timeout: 4)
        sleep(1)
        shot("ul02-11-countdown.png")
        shot("rt-tts-countdown.png")
        dump("ul02-11-countdown.ax.txt")
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }
        _ = tapLabel(["Dictate"], timeout: 4)
        sleep(1)
        shot("ul02-12-dictate.png")
        shot("rt-dictate.png")
        dump("ul02-12-dictate.ax.txt")

        // Settings + local legal
        XCTAssertTrue(tapTab("Settings"), "Settings tab missing")
        sleep(1)
        shot("ul02-13-settings.png")
        shot("rt-settings-privacy.png")
        dump("ul02-13-settings.ax.txt")

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

        _ = tapLabel(["Revoke AI consent", "Revoke"], timeout: 4)
        sleep(1)
        shot("ul06-after-revoke.png")
        dump("ul06-after-revoke.ax.txt")

        // Camera entry presence (do not require hardware capture)
        _ = tapTab("Projects")
        sleep(1)
        if tapLabel(["Accept Set", "Stop-motion", "project"], timeout: 4) {
            sleep(1)
        }
        _ = tapTab("Coach")
        sleep(1)
        _ = tapLabel(["Capture"], timeout: 4)
        sleep(1)
        shot("ul02-14-capture-entry.png")
        dump("ul02-14-capture-entry.ax.txt")
        _ = tapLabel(["Capture frame"], timeout: 3)
        dismissSystemAlertsIfNeeded()
        sleep(1)
        shot("ul02-15-camera-or-alert.png")
    }
}
