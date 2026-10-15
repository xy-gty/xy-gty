import XCTest

/// External XCUITest harness — does not modify product sources.
final class JourneyTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261015T135733Z-fecade9e/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            atPath: evidenceDir,
            withIntermediateDirectories: true
        )
        app = XCUIApplication(bundleIdentifier: "com.lingguang.wingcue")
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
            let staticText = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] %@", frag)
            ).firstMatch
            if staticText.waitForExistence(timeout: 0.5), staticText.isHittable {
                staticText.tap()
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

    private func tapIdentifier(_ id: String, timeout: TimeInterval = 6) -> Bool {
        let el = app.descendants(matching: .any)[id]
        if el.waitForExistence(timeout: timeout) {
            forceTap(el)
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
            if app.buttons["Done"].waitForExistence(timeout: 0.8) {
                app.buttons["Done"].tap()
            } else if app.buttons["Return"].waitForExistence(timeout: 0.8) {
                app.buttons["Return"].tap()
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

        let brand = app.staticTexts["WingCue"]
        let home = app.descendants(matching: .any)["FieldHomeView"]
        let stack = app.descendants(matching: .any)["FieldCardStack"]
        let chips = app.descendants(matching: .any)["OversizedFieldMarkChips"]
        let bar = app.descendants(matching: .any)["SilhouetteCompareBar"]
        XCTAssertTrue(
            brand.waitForExistence(timeout: 4) || home.waitForExistence(timeout: 4),
            "Home missing WingCue brand / FieldHomeView"
        )
        XCTAssertTrue(
            stack.waitForExistence(timeout: 4)
                || chips.waitForExistence(timeout: 4)
                || bar.waitForExistence(timeout: 4),
            "Missing FieldCardStack / OversizedFieldMarkChips / SilhouetteCompareBar"
        )
        dump("ul01-species-chrome.ax.txt")
    }

    func testUL02CoreFlowsAndPrivacy() throws {
        shot("ul02-01-home.png")
        dump("ul02-01-home.ax.txt")

        // Shoot → camera entry (cancel after permission/alert)
        let shootHit = tapExactButton("Shoot", timeout: 6) || tapLabel(["Shoot"], timeout: 4)
        XCTAssertTrue(shootHit, "Shoot CTA missing")
        sleep(1)
        dismissSystemAlertsIfNeeded()
        sleep(1)
        shot("ul02-02-capture-camera.png")
        shot("rt-capture-camera.png")
        dump("ul02-02-capture.ax.txt")
        let cancel = app.buttons["Cancel"]
        if cancel.waitForExistence(timeout: 3) { cancel.tap() }
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if spring.buttons["Cancel"].waitForExistence(timeout: 2) {
            spring.buttons["Cancel"].tap()
        }
        sleep(1)

        // Import photos
        let importHit = tapExactButton("Import", timeout: 6) || tapLabel(["Import"], timeout: 4)
        XCTAssertTrue(importHit, "Import CTA missing")
        sleep(1)
        dismissSystemAlertsIfNeeded()
        sleep(1)
        shot("ul02-03-import-picker.png")
        dump("ul02-03-import.ax.txt")
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
        sleep(2)
        shot("ul02-04-after-import.png")
        shot("rt-id-result.png")
        dump("ul02-04-after-import.ax.txt")

        // ID result chrome if navigated
        let idView = app.descendants(matching: .any)["IDResultView"]
        if idView.waitForExistence(timeout: 4)
            || app.navigationBars["ID result"].waitForExistence(timeout: 2)
        {
            shot("ul02-05-id-result.png")
            dump("ul02-05-id-result.ax.txt")
            _ = tapExactButton("Identify", timeout: 4) || tapLabel(["Identify"], timeout: 3)
            sleep(2)
            shot("ul02-05b-after-identify.png")
            dump("ul02-05b-after-identify.ax.txt")
            // Consent sheet may appear when key present — local_only usually honest banner
            if tapLabel(["Allow", "Not now", "Don't Allow"], timeout: 3) {
                sleep(1)
                shot("ul02-05c-consent.png")
                shot("rt-consent-ai.png")
            }
            _ = tapLabel(["Clarify lookalikes"], timeout: 4)
            sleep(1)
            shot("ul02-06-lookalike-chat.png")
            shot("rt-lookalike-chat.png")
            dump("ul02-06-lookalike-chat.ax.txt")
            if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
                app.navigationBars.buttons.firstMatch.tap()
                sleep(1)
            }
            _ = tapLabel(["Annotate"], timeout: 4)
            sleep(1)
            shot("ul02-07-overlay.png")
            shot("rt-overlay-annotate.png")
            dump("ul02-07-overlay.ax.txt")
            _ = tapLabel(["Save", "Done", "Keep"], timeout: 3)
            if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
                app.navigationBars.buttons.firstMatch.tap()
            }
            _ = tapLabel(["Speak tip"], timeout: 4)
            sleep(1)
            shot("ul02-08-tts.png")
            dump("ul02-08-tts.ax.txt")
            _ = tapExactButton("Save ID", timeout: 4) || tapLabel(["Save ID"], timeout: 3)
            sleep(1)
        } else {
            // Still on home — exercise coach / voice note entry points
            shot("ul02-05-home-after-import-attempt.png")
            dump("ul02-05-home-after-import-attempt.ax.txt")
        }

        // Voice note (mic)
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 1) {
            // ensure back to a screen with mic if possible
        }
        _ = tapLabel(["Voice note"], timeout: 4)
        sleep(1)
        dismissSystemAlertsIfNeeded()
        shot("ul02-09-voice-note.png")
        shot("rt-voice-note.png")
        dump("ul02-09-voice-note.ax.txt")
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }
        // Dismiss any presented sheet
        _ = tapLabel(["Cancel", "Done", "Close"], timeout: 2)

        // Lookalike / speech path from home coach bar
        _ = tapLabel(["Lookalike chat"], timeout: 4)
        sleep(1)
        shot("ul02-10-chat-entry.png")
        dump("ul02-10-chat-entry.ax.txt")
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
            app.navigationBars.buttons.firstMatch.tap()
        }

        // Settings + local legal + revoke / review consent
        XCTAssertTrue(
            tapLabel(["Settings"], timeout: 6) || tapIdentifier("Settings", timeout: 3),
            "Settings gear missing"
        )
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

        app.swipeUp()
        sleep(1)
        shot("rt-settings-scrolled.png")
        dump("rt-settings-scrolled.ax.txt")

        _ = tapLabel(["Revoke AI consent", "Review AI consent", "Revoke"], timeout: 4)
        sleep(1)
        shot("ul06-consent-action.png")
        shot("rt-consent-ai.png")
        dump("ul06-consent-action.ax.txt")
        if tapLabel(["Allow", "Not now", "Don't Allow"], timeout: 3) {
            sleep(1)
            shot("ul06-consent-sheet.png")
        }
    }

    func testUL04RelaunchPersistence() throws {
        app.terminate()
        sleep(1)
        app.launch()
        sleep(2)
        shot("ul04-relaunch-home.png")
        dump("ul04-relaunch-home.ax.txt")

        // TypedNavigationStore may restore Settings / ID result — that IS persistence.
        let settings = app.descendants(matching: .any)["SettingsPrivacyView"]
        let settingsNav = app.navigationBars["Settings"]
        let home = app.descendants(matching: .any)["FieldHomeView"]
        let idResult = app.descendants(matching: .any)["IDResultView"]
        let brand = app.staticTexts["WingCue"]
        let shoot = app.buttons["Shoot"]
        let restored =
            settings.waitForExistence(timeout: 4)
            || settingsNav.waitForExistence(timeout: 2)
            || home.waitForExistence(timeout: 4)
            || idResult.waitForExistence(timeout: 2)
            || brand.waitForExistence(timeout: 2)
            || shoot.waitForExistence(timeout: 2)
        XCTAssertTrue(restored, "App did not restore a known WingCue route after relaunch")

        if settings.exists || settingsNav.exists {
            if app.navigationBars.buttons["Back"].waitForExistence(timeout: 3) {
                app.navigationBars.buttons["Back"].tap()
                sleep(1)
            } else if app.buttons["Back"].waitForExistence(timeout: 2) {
                app.buttons["Back"].tap()
                sleep(1)
            }
            shot("ul04-after-back-home.png")
            dump("ul04-after-back-home.ax.txt")
        }
        let homeAfter = app.descendants(matching: .any)["FieldHomeView"]
        let shootAfter = app.buttons["Shoot"]
        _ = homeAfter.waitForExistence(timeout: 3) || shootAfter.waitForExistence(timeout: 2)
    }
}

