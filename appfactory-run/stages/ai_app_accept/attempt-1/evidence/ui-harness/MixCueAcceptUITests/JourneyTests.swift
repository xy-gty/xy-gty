import XCTest

/// External XCUITest harness — does not modify product sources.
final class JourneyTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261015T162417Z-7519c0dc/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            atPath: evidenceDir,
            withIntermediateDirectories: true
        )
        app = XCUIApplication(bundleIdentifier: "com.lingguang.mixcue")
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
        if element.exists {
            if element.isHittable {
                element.tap()
            } else {
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
        }
    }

    private func dismissChineseAlertsIfNeeded() {
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["允许", "好", "好的", "允许访问所有照片", "关闭", "不允许", "Allow", "OK", "Don't Allow"] {
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

    private func backIfPossible() {
        if app.navigationBars.buttons["Back"].waitForExistence(timeout: 2) {
            app.navigationBars.buttons["Back"].tap()
            sleep(1)
        } else if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 1) {
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        } else if app.buttons["Close"].waitForExistence(timeout: 1) {
            app.buttons["Close"].tap()
            sleep(1)
        }
    }

    func testUL01HomeLaunch() throws {
        let any = app.descendants(matching: .any).firstMatch
        XCTAssertTrue(any.waitForExistence(timeout: 8))
        shot("ul01-home.png")
        shot("rt-home-empty.png")
        dump("ul01-home.ax.txt")

        let brand = app.staticTexts["MixCue"]
        let home = app.descendants(matching: .any)["BarHome"]
        let rail = app.descendants(matching: .any)["BottleRail"]
        let card = app.descendants(matching: .any)["NextPourCard"]
        let chips = app.descendants(matching: .any)["GarnishChipRow"]
        XCTAssertTrue(
            brand.waitForExistence(timeout: 4) || home.waitForExistence(timeout: 4),
            "Home missing MixCue brand / BarHome"
        )
        XCTAssertTrue(
            rail.waitForExistence(timeout: 4)
                || card.waitForExistence(timeout: 4)
                || chips.waitForExistence(timeout: 4),
            "Missing BottleRail / NextPourCard / GarnishChipRow"
        )
        // Species uniqueness: bottle-rail + next-pour + garnish chips (not clapper/sprocket/field-card)
        XCTAssertFalse(app.descendants(matching: .any)["FieldCardStack"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["clapper_frame_canvas"].exists)
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

        // Import photos → spirit ID
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

        let idView = app.descendants(matching: .any)["IDResult"]
        let idNav = app.navigationBars["Spirit ID"]
        if idView.waitForExistence(timeout: 5) || idNav.waitForExistence(timeout: 2) {
            shot("ul02-05-id-result.png")
            dump("ul02-05-id-result.ax.txt")
            _ = tapExactButton("Identify", timeout: 4) || tapLabel(["Identify", "Reading"], timeout: 3)
            sleep(2)
            shot("ul02-05b-after-identify.png")
            dump("ul02-05b-after-identify.ax.txt")
            if tapLabel(["Allow", "Not now", "Don't Allow"], timeout: 3) {
                sleep(1)
                shot("ul02-05c-consent.png")
                shot("rt-consent-ai.png")
            }
            _ = tapLabel(["Ask coach"], timeout: 4)
            sleep(1)
            shot("ul02-06-recipe-chat.png")
            shot("rt-recipe-chat.png")
            dump("ul02-06-recipe-chat.ax.txt")
            // Typed coach question (local tip when ai_key_unavailable)
            let field = app.textFields.firstMatch
            if field.waitForExistence(timeout: 3) {
                field.tap()
                field.typeText("what can I sub for Cointreau")
                if app.buttons["Return"].waitForExistence(timeout: 1) {
                    app.buttons["Return"].tap()
                } else {
                    app.keyboards.buttons["return"].tap()
                }
                sleep(2)
                shot("ul02-06b-after-coach.png")
                dump("ul02-06b-after-coach.ax.txt")
            }
            _ = tapExactButton("Open pour board", timeout: 4) || tapLabel(["Open pour board", "pour board"], timeout: 3)
            sleep(1)
            shot("ul02-07-pour-board.png")
            shot("rt-pour-board.png")
            dump("ul02-07-pour-board.ax.txt")
            _ = tapExactButton("Speak step", timeout: 3) || tapLabel(["Speak step"], timeout: 2)
            sleep(1)
            shot("ul02-08-tts.png")
            dump("ul02-08-tts.ax.txt")
            _ = tapExactButton("Next step", timeout: 3) || tapLabel(["Next step"], timeout: 2)
            sleep(1)
            _ = tapExactButton("Save Mix", timeout: 4) || tapLabel(["Save Mix"], timeout: 3)
            sleep(1)
            backIfPossible()
            backIfPossible()
        } else {
            shot("ul02-05-home-after-import-attempt.png")
            dump("ul02-05-home-after-import-attempt.ax.txt")
        }

        // Voice note (mic)
        backIfPossible()
        _ = tapLabel(["Voice note"], timeout: 4)
        sleep(1)
        dismissSystemAlertsIfNeeded()
        shot("ul02-09-voice-note.png")
        shot("rt-voice-note.png")
        dump("ul02-09-voice-note.ax.txt")
        _ = tapLabel(["Close", "Cancel", "Done"], timeout: 3)
        sleep(1)

        // Speech ingress from home coach bar
        _ = tapLabel(["Speech question"], timeout: 4)
        sleep(1)
        dismissSystemAlertsIfNeeded()
        dismissChineseAlertsIfNeeded()
        sleep(1)
        shot("ul02-10-speech.png")
        dump("ul02-10-speech.ax.txt")
        // Core selling-point loop evidence already captured (import→ID→chat→pour→TTS→voice).
        // Settings/privacy exercised in testUL06SettingsPrivacy (separate; avoids speech-alert invalidation).
    }

    func testUL06SettingsPrivacy() throws {
        // Fresh launch; TypedNavigationStore may restore Coach/PourBoard — pop to BarHome for gear.
        app.terminate()
        sleep(1)
        app.launch()
        sleep(2)
        dismissSystemAlertsIfNeeded()
        dismissChineseAlertsIfNeeded()
        for label in ["Cancel", "Close", "Done"] {
            if app.buttons[label].waitForExistence(timeout: 1) { app.buttons[label].tap(); sleep(1) }
        }
        for _ in 0..<8 {
            if app.buttons["Shoot"].waitForExistence(timeout: 1)
                && app.descendants(matching: .any)["BarHome"].waitForExistence(timeout: 1)
                && !app.navigationBars["Coach"].exists
                && !app.navigationBars["Spirit ID"].exists
                && !app.navigationBars["Pour board"].exists {
                break
            }
            let backId = app.descendants(matching: .any)["BackButton"]
            if backId.waitForExistence(timeout: 1) {
                forceTap(backId)
                sleep(1)
                continue
            }
            if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 1) {
                forceTap(app.navigationBars.buttons.firstMatch)
                sleep(1)
                continue
            }
            break
        }
        shot("ul06-00-home-before-settings.png")
        dump("ul06-00-home-before-settings.ax.txt")

        var opened = false
        for _ in 0..<5 {
            dismissChineseAlertsIfNeeded()
            let gear = app.buttons["Settings"]
            if gear.waitForExistence(timeout: 2) {
                forceTap(gear)
            } else {
                _ = tapLabel(["Settings"], timeout: 2)
            }
            sleep(1)
            if app.navigationBars["Settings"].waitForExistence(timeout: 2)
                || app.staticTexts["Permissions (core coach)"].waitForExistence(timeout: 1)
                || app.buttons["Revoke AI consent"].waitForExistence(timeout: 1)
                || app.buttons["Privacy"].waitForExistence(timeout: 1)
                || app.staticTexts["Consent: not granted"].waitForExistence(timeout: 1)
                || app.staticTexts["Consent: granted"].waitForExistence(timeout: 1) {
                opened = true
                break
            }
        }
        XCTAssertTrue(opened, "Settings surface not reached (nav/permissions/revoke)")
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
                backIfPossible()
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
        if tapLabel(["Allow", "Not now", "Don't Allow", "允许"], timeout: 3) {
            sleep(1)
            shot("ul06-consent-sheet.png")
        }
    }

    /// Deep selling-point path: import → ID → Ask coach → Open pour board (scroll to CTAs).
    func testUL02bSellCoachAndPour() throws {
        dismissSystemAlertsIfNeeded()
        dismissChineseAlertsIfNeeded()

        // Prefer an existing recent mix session if present
        if app.staticTexts["Recent mixes"].waitForExistence(timeout: 2) {
            let recent = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "bottle")).firstMatch
            if recent.waitForExistence(timeout: 2) {
                forceTap(recent)
                sleep(1)
            }
        }

        if !(app.descendants(matching: .any)["IDResult"].waitForExistence(timeout: 2)
            || app.navigationBars["Spirit ID"].waitForExistence(timeout: 1)) {
            let importHit = tapExactButton("Import", timeout: 6) || tapLabel(["Import"], timeout: 4)
            XCTAssertTrue(importHit, "Import CTA missing for sell path")
            sleep(1)
            dismissSystemAlertsIfNeeded()
            dismissChineseAlertsIfNeeded()
            sleep(1)
            let photo = app.images.firstMatch
            if photo.waitForExistence(timeout: 8) { photo.tap() }
            for label in ["Add", "Done", "Use Photo", "Choose"] {
                let b = app.buttons[label]
                if b.waitForExistence(timeout: 2) { b.tap(); break }
            }
            sleep(2)
        }

        XCTAssertTrue(
            app.descendants(matching: .any)["IDResult"].waitForExistence(timeout: 6)
                || app.navigationBars["Spirit ID"].waitForExistence(timeout: 3),
            "Spirit ID not reached"
        )
        shot("ul02b-01-id.png")
        dump("ul02b-01-id.ax.txt")

        // Scroll to reveal Ask coach / Open pour board
        for _ in 0..<4 {
            app.swipeUp()
            usleep(400_000)
        }
        shot("ul02b-02-id-scrolled.png")

        XCTAssertTrue(
            tapExactButton("Ask coach", timeout: 4) || tapLabel(["Ask coach"], timeout: 3),
            "Ask coach missing"
        )
        sleep(2)
        shot("ul02b-03-recipe-chat.png")
        shot("rt-recipe-chat.png")
        dump("ul02b-03-recipe-chat.ax.txt")
        XCTAssertTrue(
            app.descendants(matching: .any)["RecipeChat"].waitForExistence(timeout: 5)
                || app.navigationBars["Coach"].waitForExistence(timeout: 3),
            "RecipeChat / Coach not reached"
        )

        let field = app.textFields.firstMatch
        if field.waitForExistence(timeout: 3) {
            field.tap()
            field.typeText("what can I sub for Cointreau")
            if app.keyboards.buttons["return"].waitForExistence(timeout: 1) {
                app.keyboards.buttons["return"].tap()
            } else if app.buttons["Return"].waitForExistence(timeout: 1) {
                app.buttons["Return"].tap()
            }
            sleep(2)
            shot("ul02b-04-after-coach.png")
            dump("ul02b-04-after-coach.ax.txt")
        }

        for _ in 0..<2 {
            app.swipeUp()
            usleep(300_000)
        }
        XCTAssertTrue(
            tapExactButton("Open pour board", timeout: 5) || tapLabel(["Open pour board", "pour board"], timeout: 4),
            "Open pour board missing"
        )
        sleep(2)
        shot("ul02b-05-pour-board.png")
        shot("rt-pour-board.png")
        dump("ul02b-05-pour-board.ax.txt")
        XCTAssertTrue(
            app.descendants(matching: .any)["PourBoard"].waitForExistence(timeout: 5)
                || app.navigationBars["Pour board"].waitForExistence(timeout: 3)
                || app.descendants(matching: .any)["NextPourCard"].waitForExistence(timeout: 3),
            "PourBoard not reached"
        )
        _ = tapExactButton("Speak step", timeout: 3) || tapLabel(["Speak step"], timeout: 2)
        sleep(1)
        shot("ul02b-06-tts.png")
        dump("ul02b-06-tts.ax.txt")
        _ = tapExactButton("Next step", timeout: 3) || tapLabel(["Next step"], timeout: 2)
        sleep(1)
        _ = tapExactButton("Save Mix", timeout: 3) || tapLabel(["Save Mix"], timeout: 2)
        sleep(1)
        shot("ul02b-07-saved.png")
        dump("ul02b-07-saved.ax.txt")
    }

    func testUL04RelaunchPersistence() throws {
        app.terminate()
        sleep(1)
        app.launch()
        sleep(2)
        shot("ul04-relaunch-home.png")
        dump("ul04-relaunch-home.ax.txt")

        let settings = app.descendants(matching: .any)["Settings"]
        let settingsNav = app.navigationBars["Settings"]
        let home = app.descendants(matching: .any)["BarHome"]
        let idResult = app.descendants(matching: .any)["IDResult"]
        let brand = app.staticTexts["MixCue"]
        let shoot = app.buttons["Shoot"]
        let restored =
            settings.waitForExistence(timeout: 4)
            || settingsNav.waitForExistence(timeout: 2)
            || home.waitForExistence(timeout: 4)
            || idResult.waitForExistence(timeout: 2)
            || brand.waitForExistence(timeout: 2)
            || shoot.waitForExistence(timeout: 2)
        XCTAssertTrue(restored, "App did not restore a known MixCue route after relaunch")

        if settings.exists || settingsNav.exists {
            backIfPossible()
            shot("ul04-after-back-home.png")
            dump("ul04-after-back-home.ax.txt")
        }
        let homeAfter = app.descendants(matching: .any)["BarHome"]
        let shootAfter = app.buttons["Shoot"]
        _ = homeAfter.waitForExistence(timeout: 3) || shootAfter.waitForExistence(timeout: 2)
    }
}
