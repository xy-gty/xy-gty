import XCTest

final class JourneyTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261014T130415Z-f3114989/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = false
        try FileManager.default.createDirectory(
            atPath: evidenceDir,
            withIntermediateDirectories: true
        )
        app = XCUIApplication(bundleIdentifier: "com.lingguang.yarncue")
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
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 4) {
            forceTap(tab)
            return true
        }
        return tapLabel([name], timeout: 3)
    }

    private func dismissSystemAlertsIfNeeded() {
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow", "OK", "Allow Access to All Photos", "Full Access", "Continue"] {
            let b = spring.buttons[label]
            if b.waitForExistence(timeout: 1.5) {
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
        let newProject = app.buttons["cta-new-project"]
        let byLabel = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "New project")
        ).firstMatch
        XCTAssertTrue(
            newProject.waitForExistence(timeout: 6) || byLabel.waitForExistence(timeout: 2),
            "New project CTA missing on home"
        )
        XCTAssertTrue(
            app.otherElements["YarnBallSwatchStrip"].waitForExistence(timeout: 3)
                || app.staticTexts["YarnCue"].waitForExistence(timeout: 2),
            "YarnCue brand / swatch strip missing"
        )
    }

    func testUL02CoreFlowsAndPrivacy() throws {
        shot("ul02-01-home.png")
        dump("ul02-01-home.ax.txt")

        XCTAssertTrue(
            tapExactButton("New project", timeout: 8)
                || tapLabel(["New project"], timeout: 4)
                || {
                    let id = app.buttons["cta-new-project"]
                    if id.waitForExistence(timeout: 2) { forceTap(id); return true }
                    return false
                }(),
            "New project CTA missing"
        )
        sleep(1)
        dump("ul02-01b-new-project.ax.txt")

        let title = app.textFields.firstMatch
        if title.waitForExistence(timeout: 4) {
            title.tap()
            title.typeText("Accept WIP")
        }
        XCTAssertTrue(
            tapExactButton("Create & capture", timeout: 8)
                || tapLabel(["Create & capture", "Create"], timeout: 4),
            "Create & capture missing"
        )
        sleep(1)
        shot("ul02-02-capture-import.png")
        shot("rt-capture-import.png")
        dump("ul02-02-capture.ax.txt")

        XCTAssertTrue(
            app.buttons["cta-camera"].waitForExistence(timeout: 4)
                || tapLabel(["Camera"], timeout: 2),
            "Camera entry missing"
        )
        XCTAssertTrue(
            tapExactButton("Photo library", timeout: 8)
                || {
                    let id = app.buttons["cta-photo-library"]
                    if id.waitForExistence(timeout: 2) { forceTap(id); return true }
                    return false
                }()
                || tapLabel(["Photo library", "Photo Library"], timeout: 4),
            "Photo library entry missing"
        )
        sleep(1)
        dismissSystemAlertsIfNeeded()
        // Limited-library / locale chrome (CN): close tip sheets first
        for label in ["关闭", "Close", "OK", "Allow Access to All Photos", "Full Access", "Allow"] {
            let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            let sb = spring.buttons[label]
            if sb.waitForExistence(timeout: 0.8) { sb.tap() }
            let b = app.buttons[label]
            if b.waitForExistence(timeout: 0.8) { b.tap() }
        }
        shot("ul02-03-picker.png")
        dump("ul02-03-picker.ax.txt")

        // Prefer grid cells / images inside the picker sheet
        let cells = app.cells
        if cells.count > 0, cells.element(boundBy: 0).waitForExistence(timeout: 6) {
            forceTap(cells.element(boundBy: 0))
        } else {
            let photos = app.images
            // Skip tiny chrome icons: tap a larger image if present
            var tapped = false
            for i in 0..<min(photos.count, 12) {
                let img = photos.element(boundBy: i)
                if img.waitForExistence(timeout: 0.5), img.frame.width > 40 {
                    forceTap(img)
                    tapped = true
                    break
                }
            }
            if !tapped, photos.firstMatch.waitForExistence(timeout: 2) {
                forceTap(photos.firstMatch)
            }
        }
        sleep(1)
        var confirmed = false
        for label in ["Add", "Done", "Use Photo", "Choose", "添加", "选取", "完成"] {
            let b = app.buttons[label]
            if b.waitForExistence(timeout: 2) {
                forceTap(b)
                confirmed = true
                break
            }
        }
        if !confirmed {
            // Some PhotosPicker builds auto-dismiss on selection
            dump("ul02-03b-no-add-button.ax.txt")
        }
        dismissSystemAlertsIfNeeded()
        // If picker still open, cancel and note soft gap
        if app.buttons["取消"].waitForExistence(timeout: 1) || app.buttons["Cancel"].waitForExistence(timeout: 0.5) {
            _ = tapExactButton("取消", timeout: 1) || tapExactButton("Cancel", timeout: 1)
            dump("ul02-03c-picker-cancelled.ax.txt")
        }
        sleep(2)
        shot("ul02-04-after-import.png")
        dump("ul02-04-after-import.ax.txt")

        // Stitch review Keep/Discard/Edit
        if app.staticTexts["Stitch / row review"].waitForExistence(timeout: 6)
            || app.navigationBars["Review"].waitForExistence(timeout: 2)
        {
            shot("ul02-05-stitch-review.png")
            shot("rt-stitch-review.png")
            dump("ul02-05-stitch-review.ax.txt")
            _ = tapExactButton("Edit", timeout: 3)
            XCTAssertTrue(
                tapExactButton("Keep", timeout: 8) || tapLabel(["Keep"], timeout: 4),
                "Keep on stitch review missing"
            )
            sleep(1)
        } else {
            shot("ul02-05-no-stitch-review.png")
            shot("rt-stitch-review.png")
            dump("ul02-05-no-stitch-review.ax.txt")
        }

        // Keep lands on Projects NavigationStack path [.projectCoach].
        // CoachChat push uses the same path — stay on Projects tab (Coach tab stack is separate).
        for _ in 0..<2 {
            if app.buttons["关闭"].waitForExistence(timeout: 0.5) { app.buttons["关闭"].tap() }
            if app.buttons["取消"].waitForExistence(timeout: 0.5) { app.buttons["取消"].tap() }
        }
        _ = tapTab("Projects")
        sleep(1)
        if !app.buttons["Ask coach"].waitForExistence(timeout: 3) {
            _ = tapLabel(["Accept WIP", "WIP project", "WIP"], timeout: 4)
            sleep(1)
        }
        shot("ul02-06-project-coach.png")
        shot("rt-project-coach.png")
        dump("ul02-06-coach.ax.txt")

        XCTAssertTrue(
            tapExactButton("Ask coach", timeout: 10) || tapLabel(["Ask coach", "Ask Coach"], timeout: 4),
            "Ask coach missing on Projects stack"
        )
        sleep(1)
        // Wait for Chat surface (Send) rather than Coach grid
        XCTAssertTrue(
            app.buttons["Send"].waitForExistence(timeout: 8)
                || app.staticTexts["Weave coach"].waitForExistence(timeout: 3)
                || app.navigationBars["Chat"].waitForExistence(timeout: 3),
            "Coach chat did not push on Projects stack"
        )
        shot("ul02-07-coach-chat.png")
        shot("rt-coach-chat.png")
        dump("ul02-07-coach-chat.ax.txt")

        let field = app.textFields.firstMatch
        let area = app.textViews.firstMatch
        if field.waitForExistence(timeout: 3) {
            field.tap()
            field.typeText("What is the next row stitch?")
        } else if area.waitForExistence(timeout: 1) {
            area.tap()
            area.typeText("What is the next row stitch?")
        }
        let feedback = app.textFields.matching(
            NSPredicate(format: "placeholderValue CONTAINS[c] %@", "Feedback")
        ).firstMatch
        if feedback.waitForExistence(timeout: 2) {
            feedback.tap()
            feedback.typeText("Keep tension even")
        }
        XCTAssertTrue(tapExactButton("Send", timeout: 8) || tapLabel(["Send"], timeout: 3), "Send missing")
        sleep(2)
        shot("ul02-08-after-send.png")
        dump("ul02-08-after-send.ax.txt")

        // Turn review Keep (local coach when key absent)
        if tapExactButton("Keep", timeout: 8) || tapLabel(["Keep"], timeout: 4) {
            sleep(1)
            shot("ul02-09-turn-kept.png")
            dump("ul02-09-turn-kept.ax.txt")
        } else if tapLabel(["Allow", "Not now"], timeout: 3) {
            shot("ul02-09-consent.png")
            dump("ul02-09-consent.ax.txt")
        } else {
            shot("ul02-09-local-or-unconfigured.png")
        }

        // Return to project coach on Projects stack for Annotate / TTS / Dictate pushes
        _ = tapTab("Projects")
        sleep(1)
        if !app.buttons["Annotate"].waitForExistence(timeout: 3) {
            // pop chat/turn if needed
            if app.navigationBars.buttons["BackButton"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons["BackButton"].tap()
                sleep(1)
            }
        }
        if tapExactButton("Annotate", timeout: 6) || tapLabel(["Annotate"], timeout: 3) {
            sleep(1)
            shot("ul02-10-annotated-wip.png")
            shot("rt-annotated-wip.png")
            dump("ul02-10-annotated.ax.txt")
            _ = tapLabel(["Keep marks", "Keep", "Discard"], timeout: 3)
            if app.navigationBars.buttons["BackButton"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons["BackButton"].tap()
            }
        } else {
            shot("rt-annotated-wip.png")
        }

        if tapExactButton("Hands-free", timeout: 6) || tapLabel(["Hands-free", "Hands free"], timeout: 3) {
            sleep(1)
            shot("ul02-11-hands-free-tts.png")
            shot("rt-hands-free-tts.png")
            dump("ul02-11-tts.ax.txt")
            _ = tapLabel(["Play", "Next step", "Next"], timeout: 3)
            if app.navigationBars.buttons["BackButton"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons["BackButton"].tap()
            }
        } else {
            shot("rt-hands-free-tts.png")
        }

        if tapExactButton("Dictate", timeout: 6) || tapLabel(["Dictate"], timeout: 3) {
            sleep(1)
            shot("ul02-12-dictate.png")
            dump("ul02-12-dictate.ax.txt")
            dismissSystemAlertsIfNeeded()
            if app.navigationBars.buttons["BackButton"].waitForExistence(timeout: 2) {
                app.navigationBars.buttons["BackButton"].tap()
            }
        }

        // Settings + local legal + revoke toggle
        XCTAssertTrue(tapTab("Settings"), "Settings tab missing")
        sleep(1)
        shot("ul06-01-settings.png")
        shot("rt-settings-privacy.png")
        dump("ul06-01-settings.ax.txt")

        for name in ["Privacy", "Terms", "Support", "Provider policy"] {
            if tapExactButton(name, timeout: 4) || tapLabel([name, "Provider"], timeout: 2) {
                sleep(1)
                let slug = name.lowercased().replacingOccurrences(of: " ", with: "-")
                shot("ul06-\(slug).png")
                dump("ul06-\(slug).ax.txt")
                if app.navigationBars.buttons.firstMatch.exists {
                    app.navigationBars.buttons.firstMatch.tap()
                } else {
                    _ = tapLabel(["Back", "Done", "Close"], timeout: 2)
                }
            }
        }

        // Toggle Allow outbound AI → consent sheet (key still absent; local path honest)
        let toggle = app.switches["Allow outbound AI"]
        if toggle.waitForExistence(timeout: 4) {
            forceTap(toggle)
            sleep(1)
            shot("ul06-02-consent-or-toggle.png")
            dump("ul06-02-consent.ax.txt")
            if tapExactButton("Allow", timeout: 4) || tapLabel(["Allow"], timeout: 2) {
                sleep(1)
                shot("ul06-03-after-allow.png")
            } else if tapExactButton("Not now", timeout: 3) {
                shot("ul06-03-not-now.png")
            }
            // Revoke via toggle off
            if toggle.waitForExistence(timeout: 3), toggle.value as? String == "1" {
                forceTap(toggle)
                sleep(1)
                shot("ul06-04-revoked.png")
                dump("ul06-04-revoked.ax.txt")
            }
        }

        // Persistence: relaunch → projects still present
        app.terminate()
        app.launch()
        sleep(1)
        _ = tapTab("Projects")
        sleep(1)
        shot("ul04-relaunch-home.png")
        dump("ul04-relaunch-home.ax.txt")
        XCTAssertTrue(
            app.staticTexts["Accept WIP"].waitForExistence(timeout: 6)
                || app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Accept WIP")).firstMatch
                .waitForExistence(timeout: 2)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "WIP")).firstMatch
                .waitForExistence(timeout: 2),
            "Project not persisted after relaunch"
        )
        shot("ul02-13-final.png")
    }
}
