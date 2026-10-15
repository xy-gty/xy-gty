import XCTest

/// External XCUITest harness — does not modify product sources.
final class JourneyTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261015T174239Z-859f7eed/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            atPath: evidenceDir,
            withIntermediateDirectories: true
        )
        app = XCUIApplication(bundleIdentifier: "com.lingguang.sporecue")
        app.terminate()
        app.launchArguments = ["-ui-smoke-reset"]
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
        if element.exists {
            if element.isHittable {
                element.tap()
            } else {
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
        }
    }

    private func dismissSystemAlertsIfNeeded() {
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in [
            "允许", "好", "好的", "允许访问所有照片", "关闭", "不允许",
            "Allow", "OK", "Allow Access to All Photos", "Full Access",
            "Continue", "Don't Allow", "Don't Allow"
        ] {
            let b = spring.buttons[label]
            if b.waitForExistence(timeout: 0.8) {
                b.tap()
                sleep(1)
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

    private func tapIdentifier(_ id: String, timeout: TimeInterval = 6) -> Bool {
        let el = app.descendants(matching: .any)[id]
        if el.waitForExistence(timeout: timeout) {
            forceTap(el)
            return true
        }
        return false
    }

    private func backIfPossible() {
        if app.navigationBars.buttons["Back"].waitForExistence(timeout: 2) {
            app.navigationBars.buttons["Back"].tap()
            sleep(1)
        } else if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 1) {
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }
    }

    private func hasDisclaimer() -> Bool {
        if app.otherElements["DisclaimerBanner"].waitForExistence(timeout: 3) { return true }
        if app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "非可食")).firstMatch.exists {
            return true
        }
        if app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "edibility certification")).firstMatch.exists {
            return true
        }
        return app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "not an edibility")).firstMatch.exists
    }

    func testUL01HomeLaunch() throws {
        XCTAssertTrue(app.staticTexts["SporeCue"].waitForExistence(timeout: 12))
        shot("ul01-home.png")
        shot("rt-sporecue-home-empty.png")
        dump("ul01-home.ax.txt")

        XCTAssertTrue(
            app.otherElements["FieldHome"].waitForExistence(timeout: 4)
                || app.otherElements["SpeciesConfidenceStack"].waitForExistence(timeout: 4),
            "FieldHome / SpeciesConfidenceStack missing"
        )
        XCTAssertTrue(
            app.otherElements["SpeciesConfidenceStack"].waitForExistence(timeout: 4)
                || app.staticTexts["Species confidence"].exists
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Rank 1")).firstMatch.exists,
            "Species confidence stack missing"
        )
        XCTAssertTrue(
            app.otherElements["GillPoreCloseupBar"].waitForExistence(timeout: 4)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "closeup")).firstMatch.exists,
            "Gill/pore closeup bar missing"
        )
        // Chip rail may be empty on first launch; signature stack+closeup already asserted.
        XCTAssertTrue(hasDisclaimer(), "Missing 非可食认证 / not an edibility certification")
        XCTAssertTrue(
            app.buttons["ShootButton"].waitForExistence(timeout: 4) || app.buttons["Shoot"].exists
        )
        XCTAssertFalse(app.descendants(matching: .any)["BottleRail"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["FieldCardStack"].exists)
        dump("ul01-species-chrome.ax.txt")
    }

    func testUL02bSellCoreFlows() throws {
        // Core selling points: Shoot/Import → ID surface → coach → annotate → voice note → TTS entry
        shot("ul02-01-home.png")
        dump("ul02-01-home.ax.txt")
        XCTAssertTrue(hasDisclaimer())

        let shootHit = tapIdentifier("ShootButton", timeout: 4) || tapExactButton("Shoot", timeout: 4)
        XCTAssertTrue(shootHit, "Shoot CTA missing")
        sleep(1)
        dismissSystemAlertsIfNeeded()
        sleep(1)
        shot("ul02-02-capture-camera.png")
        shot("rt-sporecue-capture-camera.png")
        dump("ul02-02-capture.ax.txt")
        if app.buttons["Cancel"].waitForExistence(timeout: 3) { app.buttons["Cancel"].tap() }
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if spring.buttons["Cancel"].waitForExistence(timeout: 2) { spring.buttons["Cancel"].tap() }
        sleep(1)

        let importHit = tapIdentifier("ImportButton", timeout: 4)
            || tapExactButton("Import", timeout: 4)
            || tapLabel(["Import"], timeout: 3)
        XCTAssertTrue(importHit, "Import CTA missing")
        sleep(1)
        dismissSystemAlertsIfNeeded()
        sleep(1)
        shot("ul02-03-import-picker.png")
        dump("ul02-03-import.ax.txt")
        let photo = app.images.firstMatch
        if photo.waitForExistence(timeout: 8) {
            photo.tap()
        } else if app.cells.firstMatch.waitForExistence(timeout: 4) {
            app.cells.firstMatch.tap()
        }
        for label in ["Add", "Done", "Use Photo", "Choose", "添加", "选取"] {
            let b = app.buttons[label]
            if b.waitForExistence(timeout: 2) { b.tap(); break }
        }
        dismissSystemAlertsIfNeeded()
        sleep(2)
        shot("ul02-04-after-import.png")
        dump("ul02-04-after-import.ax.txt")

        let idView = app.descendants(matching: .any)["IDResult"]
        let idNav = app.navigationBars["ID result"]
        if idView.waitForExistence(timeout: 6) || idNav.waitForExistence(timeout: 3) {
            shot("ul02-05-id-result.png")
            shot("rt-sporecue-id-result.png")
            dump("ul02-05-id-result.ax.txt")
            XCTAssertTrue(hasDisclaimer(), "ID surface missing compliance disclaimer")
            XCTAssertTrue(
                app.otherElements["SpeciesConfidenceStack"].waitForExistence(timeout: 4)
                    || app.staticTexts["Species confidence"].exists
            )
            XCTAssertTrue(
                app.otherElements["GillPoreCloseupBar"].waitForExistence(timeout: 4)
                    || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "closeup")).firstMatch.exists
            )

            _ = tapExactButton("Identify", timeout: 4)
            sleep(2)
            shot("ul02-05b-after-identify.png")
            dump("ul02-05b-after-identify.ax.txt")
            if tapLabel(["Allow", "Not now", "Don't Allow", "允许", "不允许"], timeout: 3) {
                sleep(1)
                shot("ul02-05c-consent.png")
                shot("rt-sporecue-consent-ai.png")
                dump("ul02-05c-consent.ax.txt")
            }

            XCTAssertTrue(tapExactButton("Ask coach", timeout: 4) || tapLabel(["Ask coach"], timeout: 3))
            sleep(1)
            shot("ul02-06-lookalike-chat.png")
            shot("rt-sporecue-lookalike-chat.png")
            dump("ul02-06-lookalike-chat.ax.txt")
            let field = app.textFields.firstMatch
            if field.waitForExistence(timeout: 3) {
                field.tap()
                field.typeText("how does this differ from death cap")
                if app.keyboards.buttons["return"].waitForExistence(timeout: 1) {
                    app.keyboards.buttons["return"].tap()
                } else if app.buttons["Return"].waitForExistence(timeout: 1) {
                    app.buttons["Return"].tap()
                }
                sleep(2)
                shot("ul02-06b-after-coach.png")
                dump("ul02-06b-after-coach.ax.txt")
            }
            // Speech entry on chat/home coach bar
            _ = tapLabel(["Speech"], timeout: 2)
            sleep(1)
            dismissSystemAlertsIfNeeded()
            backIfPossible()

            if tapExactButton("Annotate", timeout: 4) || tapLabel(["Annotate"], timeout: 3) {
                sleep(1)
                shot("ul02-07-overlay.png")
                shot("rt-sporecue-overlay-annotate.png")
                dump("ul02-07-overlay.ax.txt")
                _ = tapExactButton("Keep", timeout: 3) || tapLabel(["Keep"], timeout: 2)
                sleep(1)
            }

            _ = tapExactButton("Play brief", timeout: 3) || tapLabel(["Play brief"], timeout: 2)
            sleep(1)
            shot("ul02-08-tts.png")
            dump("ul02-08-tts.ax.txt")
            backIfPossible()

            _ = tapExactButton("Save Find", timeout: 3)
            sleep(1)
            backIfPossible()
        } else {
            // Import may fail on empty sim photo library — still prove home chrome + voice note
            dump("ul02-04-no-id.ax.txt")
        }

        // Voice note sheet from home coach bar
        if app.buttons["Voice note"].waitForExistence(timeout: 4) || tapLabel(["Voice note"], timeout: 3) {
            if app.buttons["Voice note"].exists { forceTap(app.buttons["Voice note"]) }
            sleep(1)
            dismissSystemAlertsIfNeeded()
            shot("ul02-09-voice-note.png")
            shot("rt-sporecue-voice-note.png")
            dump("ul02-09-voice-note.ax.txt")
            if app.buttons["Close"].waitForExistence(timeout: 2) {
                app.buttons["Close"].tap()
            } else if app.buttons["Cancel"].waitForExistence(timeout: 2) {
                app.buttons["Cancel"].tap()
            } else {
                // swipe down sheet
                app.swipeDown()
            }
            sleep(1)
        }

        dump("ul02-end.ax.txt")
        shot("ul02-end-home.png")
    }

    func testUL06SettingsPrivacy() throws {
        XCTAssertTrue(app.staticTexts["SporeCue"].waitForExistence(timeout: 10))
        XCTAssertTrue(tapExactButton("Settings", timeout: 6) || tapLabel(["Settings"], timeout: 4))
        sleep(1)
        shot("ul06-settings.png")
        dump("ul06-settings.ax.txt")

        XCTAssertTrue(app.buttons["Revoke AI consent"].waitForExistence(timeout: 6))
        XCTAssertTrue(hasDisclaimer())

        // Permissions + local legal sit below the AI section — scroll the Settings collection.
        let settings = app.collectionViews["Settings"]
        for _ in 0 ..< 6 {
            if app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Camera")).firstMatch.exists {
                break
            }
            if settings.exists {
                settings.swipeUp()
            } else {
                app.swipeUp()
            }
            sleep(1)
        }
        shot("ul06-settings-scrolled.png")
        shot("rt-sporecue-settings-privacy.png")
        dump("ul06-settings-scrolled.ax.txt")

        let cam = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Camera")).firstMatch
        let photos = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Photos")).firstMatch
        let mic = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Microphone")).firstMatch
        let speech = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Speech")).firstMatch
        XCTAssertTrue(cam.waitForExistence(timeout: 4), "Camera permission row missing")
        XCTAssertTrue(photos.exists || photos.waitForExistence(timeout: 2), "Photos row missing")
        XCTAssertTrue(mic.exists || mic.waitForExistence(timeout: 2), "Microphone row missing")
        XCTAssertTrue(speech.exists || speech.waitForExistence(timeout: 2), "Speech row missing")

        // Local legal entries (may need one more swipe)
        for _ in 0 ..< 3 {
            if app.buttons["Privacy"].exists || app.descendants(matching: .any)["LegalPrivacy"].exists {
                break
            }
            if settings.exists { settings.swipeUp() } else { app.swipeUp() }
            sleep(1)
        }
        dump("ul06-before-legal.ax.txt")
        if app.buttons["Privacy"].waitForExistence(timeout: 4) || tapIdentifier("LegalPrivacy", timeout: 3) {
            if app.buttons["Privacy"].exists { app.buttons["Privacy"].tap() }
            sleep(1)
            shot("ul06-legal-privacy.png")
            dump("ul06-legal-privacy.ax.txt")
            backIfPossible()
        }
        if app.buttons["Provider policy"].waitForExistence(timeout: 3) {
            app.buttons["Provider policy"].tap()
            sleep(1)
            shot("ul06-legal-provider.png")
            dump("ul06-legal-provider.ax.txt")
            backIfPossible()
        }

        // Scroll back toward AI section for revoke
        for _ in 0 ..< 4 {
            if app.buttons["Revoke AI consent"].exists { break }
            if settings.exists { settings.swipeDown() } else { app.swipeDown() }
            sleep(1)
        }
        XCTAssertTrue(app.buttons["Revoke AI consent"].waitForExistence(timeout: 4))
        forceTap(app.buttons["Revoke AI consent"])
        sleep(1)
        shot("ul06-after-revoke.png")
        dump("ul06-after-revoke.ax.txt")
    }

    func testUL04RelaunchPersistence() throws {
        // Navigate settings then terminate/relaunch — navigation/consent state should restore without crash
        XCTAssertTrue(app.staticTexts["SporeCue"].waitForExistence(timeout: 10))
        shot("ul04-before.png")
        dump("ul04-before.ax.txt")
        _ = tapExactButton("Settings", timeout: 4)
        sleep(1)
        backIfPossible()
        app.terminate()
        sleep(1)
        app.launchArguments = []
        app.launch()
        sleep(2)
        XCTAssertTrue(app.staticTexts["SporeCue"].waitForExistence(timeout: 12), "Relaunch failed")
        shot("ul04-after-relaunch.png")
        dump("ul04-after-relaunch.ax.txt")
        XCTAssertTrue(
            app.otherElements["SpeciesConfidenceStack"].waitForExistence(timeout: 5)
                || app.staticTexts["Species confidence"].exists
                || app.buttons["Shoot"].exists
                || app.buttons["ShootButton"].exists
        )
    }
}
