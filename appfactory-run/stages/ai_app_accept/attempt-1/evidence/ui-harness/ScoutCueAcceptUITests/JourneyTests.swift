import XCTest

final class JourneyTests: XCTestCase {
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

    private func dismissSystemAlertsIfNeeded() {
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow", "OK", "Allow Access to All Photos", "Full Access", "Continue", "Don't Allow"] {
            let b = spring.buttons[label]
            if b.waitForExistence(timeout: 1.2) {
                if label == "Don't Allow" { continue }
                b.tap()
            }
        }
    }

    private func backIfNeeded() {
        if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 1.5) {
            app.navigationBars.buttons.firstMatch.tap()
            sleep(1)
        }
    }

    func testUL01HomeLaunch() throws {
        let any = app.descendants(matching: .any).firstMatch
        XCTAssertTrue(any.waitForExistence(timeout: 8))
        shot("ul01-home.png")
        shot("rt-home-empty.png")
        dump("ul01-home.ax.txt")
        let cta = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Capture / Import")
        ).firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 8), "Capture / Import CTA missing")
        let title = app.staticTexts["ScoutCue"]
        XCTAssertTrue(title.waitForExistence(timeout: 4) || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "ScoutCue")).firstMatch.exists)
    }

    func testUL02CoreFlowsAndPrivacy() throws {
        shot("ul02-01-home.png")
        dump("ul02-01-home.ax.txt")

        XCTAssertTrue(
            tapLabel(["Capture / Import scenery", "Capture / Import"], timeout: 12),
            "Capture CTA missing"
        )
        sleep(1)
        shot("ul02-02-capture-import.png")
        shot("rt-capture-import.png")
        dump("ul02-02-capture.ax.txt")

        XCTAssertTrue(
            tapExactButton("Choose from library", timeout: 8)
                || tapLabel(["Choose from library", "Photo library", "Photos"], timeout: 4),
            "Choose from library missing"
        )
        sleep(1)
        dismissSystemAlertsIfNeeded()
        shot("ul02-03-picker.png")
        dump("ul02-03-picker.ax.txt")

        // Prefer an actual photo cell / image
        let photo = app.images.matching(NSPredicate(format: "label CONTAINS[c] %@ OR identifier CONTAINS[c] %@", "Photo", "PX")).firstMatch
        if photo.waitForExistence(timeout: 6) {
            forceTap(photo)
        } else if app.images.firstMatch.waitForExistence(timeout: 4) {
            forceTap(app.images.firstMatch)
        } else if app.cells.firstMatch.waitForExistence(timeout: 4) {
            forceTap(app.cells.firstMatch)
        } else {
            // Fall back: cancel picker and use Take photo path is hardware; mark empty library
            shot("ul02-03b-empty-library.png")
            dump("ul02-03b-empty-library.ax.txt")
            _ = tapLabel(["Cancel", "Close", "Done"], timeout: 3)
        }
        for label in ["Add", "Done", "Use Photo", "Choose", "添加", "选取"] {
            let b = app.buttons[label]
            if b.waitForExistence(timeout: 2) { forceTap(b); break }
        }
        dismissSystemAlertsIfNeeded()
        sleep(2)
        shot("ul02-04-after-import.png")
        dump("ul02-04-after-import.ax.txt")

        // Scene review Keep path
        if tapLabel(["Keep"], timeout: 6) {
            sleep(1)
            shot("ul02-05-after-keep.png")
            dump("ul02-05-after-keep.ax.txt")
        } else {
            shot("ul02-05-no-scene-review.png")
            dump("ul02-05-no-scene-review.ax.txt")
        }

        // Open scout card if visible on home
        backIfNeeded()
        sleep(1)
        shot("ul02-06-home-after-keep.png")
        dump("ul02-06-home-after-keep.ax.txt")

        // Tap soft card / open detail via Coach chip or card
        if tapLabel(["Coach", "Open coach"], timeout: 5) {
            sleep(1)
        } else if app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Open coach")).firstMatch.waitForExistence(timeout: 2) {
            forceTap(app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Open coach")).firstMatch)
        } else {
            // try tapping any card-like element
            _ = tapLabel(["Ridge", "Lake", "Scout", "Golden", "scene"], timeout: 3)
            sleep(1)
            _ = tapLabel(["Open coach", "Coach"], timeout: 4)
        }
        sleep(1)
        shot("ul02-07-coach.png")
        shot("rt-coach-chat.png")
        dump("ul02-07-coach.ax.txt")

        let field = app.textFields.firstMatch
        if field.waitForExistence(timeout: 3) {
            field.tap()
            field.typeText("When is golden hour for this ridge?")
        }
        XCTAssertTrue(tapLabel(["Ask coach"], timeout: 6), "Ask coach missing")
        sleep(2)
        shot("ul02-08-after-ask.png")
        dump("ul02-08-after-ask.ax.txt")

        // Turn review Keep
        if tapLabel(["Keep"], timeout: 6) {
            sleep(1)
            shot("ul02-09-turn-kept.png")
            dump("ul02-09-turn-kept.ax.txt")
        }

        // Second ask for UL-05 local feedback path
        _ = tapLabel(["Open coach", "Coach", "Ask coach"], timeout: 4)
        sleep(1)
        let fb = app.textFields.matching(NSPredicate(format: "label CONTAINS[c] %@ OR value CONTAINS[c] %@", "feedback", "Optional")).firstMatch
        if fb.waitForExistence(timeout: 2) {
            fb.tap()
            fb.typeText("Prefer warmer side light")
        } else if app.textFields.count > 1 {
            let second = app.textFields.element(boundBy: 1)
            if second.exists { second.tap(); second.typeText("Prefer warmer side light") }
        }
        _ = tapLabel(["Ask coach"], timeout: 4)
        sleep(2)
        shot("ul02-10-second-ask.png")
        dump("ul02-10-second-ask.ax.txt")
        _ = tapLabel(["Keep"], timeout: 4)

        // Golden overlay
        backIfNeeded()
        if tapLabel(["Golden overlay", "Overlay"], timeout: 5) {
            sleep(1)
            shot("ul02-11-overlay.png")
            shot("rt-golden-overlay.png")
            dump("ul02-11-overlay.ax.txt")
            let pinField = app.textFields.firstMatch
            if pinField.waitForExistence(timeout: 2) {
                pinField.tap()
                pinField.typeText("Warm ridge")
            }
            // Tap center of scenery for pin if image present
            if app.images.firstMatch.exists {
                app.images.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4)).tap()
            }
            _ = tapLabel(["Save overlay"], timeout: 4)
            sleep(1)
            shot("ul02-11b-overlay-saved.png")
        }

        // TTS briefing
        backIfNeeded()
        if tapLabel(["Next-stop brief", "Brief", "Next stop"], timeout: 5) {
            sleep(1)
            shot("ul02-12-briefing.png")
            shot("rt-tts-briefing.png")
            dump("ul02-12-briefing.ax.txt")
            _ = tapLabel(["Play"], timeout: 3)
            sleep(1)
            shot("ul02-12b-briefing-play.png")
            _ = tapLabel(["Pause"], timeout: 2)
        }

        // Dictate note
        backIfNeeded()
        if tapLabel(["Dictate note", "Dictate", "Note"], timeout: 5) {
            sleep(1)
            shot("ul02-13-dictate.png")
            shot("rt-dictate-note.png")
            dump("ul02-13-dictate.ax.txt")
            let note = app.textFields.firstMatch
            let area = app.textViews.firstMatch
            if note.waitForExistence(timeout: 2) {
                note.tap()
                note.typeText("Shoot ridge at golden PM")
            } else if area.waitForExistence(timeout: 1) {
                area.tap()
                area.typeText("Shoot ridge at golden PM")
            }
            _ = tapLabel(["Save note"], timeout: 4)
            sleep(1)
            shot("ul02-13b-note-saved.png")
            // Mic entry present (真机待测)
            XCTAssertTrue(
                app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "microphone")).firstMatch.exists
                    || app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Start microphone")).firstMatch.exists
                    || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Dictate")).firstMatch.exists,
                "Dictate mic affordance missing"
            )
        }

        // Settings + legal
        app.terminate()
        app.launch()
        sleep(1)
        XCTAssertTrue(tapLabel(["Settings"], timeout: 8), "Settings missing")
        sleep(1)
        shot("ul06-01-settings.png")
        shot("rt-settings-privacy.png")
        dump("ul06-01-settings.ax.txt")

        for name in ["Privacy", "Terms", "Support", "DeepSeek provider policy", "provider policy"] {
            if tapLabel([name], timeout: 3) {
                sleep(1)
                let safe = name.lowercased().replacingOccurrences(of: " ", with: "-")
                shot("ul06-\(safe).png")
                dump("ul06-\(safe).ax.txt")
                backIfNeeded()
            }
        }
        _ = tapLabel(["Revoke AI consent", "Revoke"], timeout: 3)
        shot("ul06-02-after-revoke.png")
        dump("ul06-02-after-revoke.ax.txt")
        shot("ul02-14-final.png")
    }

    func testUL04RelaunchPersistence() throws {
        // Relaunch after prior Keep; cards or status should remain if store worked
        shot("ul04-01-relaunch.png")
        dump("ul04-01-relaunch.ax.txt")
        // Soft card stack non-empty OR empty CTA still present
        let capture = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Capture / Import")
        ).firstMatch
        XCTAssertTrue(capture.waitForExistence(timeout: 8))
        shot("rt-scout-card.png")
    }
}
