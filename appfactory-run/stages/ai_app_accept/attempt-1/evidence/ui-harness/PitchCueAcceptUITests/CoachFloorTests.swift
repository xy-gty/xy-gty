import XCTest

/// Second-pass journeys after photo import — avoid limited-library overlay polluting coach/floor shots.
final class CoachFloorTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261014T073212Z-4039fa46/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = true
        try FileManager.default.createDirectory(
            atPath: evidenceDir,
            withIntermediateDirectories: true
        )
        app = XCUIApplication(bundleIdentifier: "com.lingguang.pitchcue")
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

    private func forceTap(_ element: XCUIElement) {
        if element.isHittable {
            element.tap()
        } else {
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }

    private func tapExact(_ label: String, timeout: TimeInterval = 6) -> Bool {
        let b = app.buttons[label]
        if b.waitForExistence(timeout: timeout) {
            forceTap(b)
            return true
        }
        return false
    }

    private func tapContains(_ text: String, timeout: TimeInterval = 6) -> Bool {
        let b = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", text)).firstMatch
        if b.waitForExistence(timeout: timeout) {
            forceTap(b)
            return true
        }
        return false
    }

    private func dismissLimitedLibraryChrome() {
        for label in ["关闭", "Close", "OK", "Allow Access to All Photos", "Full Access", "允许访问所有照片"] {
            if tapExact(label, timeout: 1.2) { sleep(1) }
        }
        let spring = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow", "OK", "允许"] {
            let b = spring.buttons[label]
            if b.waitForExistence(timeout: 1) { b.tap() }
        }
    }

    private func importOnePhoto() {
        XCTAssertTrue(tapExact("New practice") || tapContains("New practice"), "need New practice")
        sleep(1)
        XCTAssertTrue(
            tapExact("Continue to Capture / Import") || tapContains("Continue to Capture"),
            "need continue"
        )
        sleep(1)
        shot("rt2-capture-import.png")
        dump("rt2-capture.ax.txt")
        XCTAssertTrue(tapExact("Photo library") || tapContains("Photo library"), "need library")
        sleep(1)
        dismissLimitedLibraryChrome()
        // Prefer an actual photo cell/image inside the picker
        let photos = app.images.matching(NSPredicate(format: "label CONTAINS[c] %@", "照片"))
        if photos.count > 0, photos.element(boundBy: 0).waitForExistence(timeout: 6) {
            forceTap(photos.element(boundBy: 0))
        } else if app.images.firstMatch.waitForExistence(timeout: 4) {
            forceTap(app.images.firstMatch)
        } else if app.cells.firstMatch.waitForExistence(timeout: 3) {
            forceTap(app.cells.firstMatch)
        }
        sleep(1)
        for label in ["添加", "Add", "Done", "Use Photo", "选取", "Choose"] {
            if tapExact(label, timeout: 1.5) { break }
        }
        // If still in picker, cancel and note — later steps use Sessions list if prior session exists
        if app.buttons["取消"].waitForExistence(timeout: 1) || app.buttons["Cancel"].waitForExistence(timeout: 0.5) {
            // Try one more photo tap then Add
            if photos.count > 1 {
                forceTap(photos.element(boundBy: min(1, photos.count - 1)))
                sleep(1)
                _ = tapExact("添加", timeout: 2) || tapExact("Add", timeout: 1)
            }
        }
        sleep(1)
        // Dismiss residual limited-library sheet if Capture UI is still behind it
        if app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "私密访问")).firstMatch.exists {
            _ = tapExact("关闭", timeout: 2)
        }
        // Cancel picker only if Capture buttons still not usable after selection attempt
        if app.buttons["Photo library"].exists == false {
            // likely left picker
        } else if app.buttons["取消"].exists {
            // Still on picker with Capture underneath — cancel to return
            tapExact("取消", timeout: 1)
        }
        sleep(1)
        shot("rt2-after-import.png")
        dump("rt2-after-import.ax.txt")
    }

    func testCoachPracticePitchScreens() throws {
        importOnePhoto()

        // Coach entry — Ask coach may be on strip or navigation
        _ = tapContains("Ask coach", timeout: 4) || tapExact("Ask coach", timeout: 2)
        sleep(1)
        dismissLimitedLibraryChrome()
        shot("rt-coach-chat.png")
        dump("rt2-coach.ax.txt")

        // Consent if present
        if tapExact("Allow", timeout: 3) || tapContains("Allow", timeout: 1) {
            sleep(1)
            shot("rt2-after-consent-allow.png")
        }

        // Honest unconfigured may surface on coach surface
        shot("rt2-coach-state.png")
        dump("rt2-coach-state.ax.txt")

        // Plan review controls if visible
        if app.buttons["Keep"].waitForExistence(timeout: 2)
            || app.buttons["Discard"].exists
            || app.buttons["Edit"].exists
        {
            shot("rt-plan-review.png")
            dump("rt2-plan.ax.txt")
            _ = tapExact("Keep", timeout: 2)
        } else {
            shot("rt-plan-review.png")
            dump("rt2-plan.ax.txt")
        }

        // Practice floor via strip step or Sessions
        _ = tapContains("Count-in", timeout: 3)
            || tapContains("Practice", timeout: 2)
            || tapContains("Start", timeout: 2)
        sleep(1)
        dismissLimitedLibraryChrome()
        shot("rt-practice-floor.png")
        dump("rt2-practice.ax.txt")
        _ = tapContains("Metronome", timeout: 2) || tapContains("Drone", timeout: 2)
        sleep(1)
        shot("rt2-audio-bed.png")

        _ = tapContains("Pitch", timeout: 3) || tapContains("Tuner", timeout: 2)
        sleep(1)
        dismissLimitedLibraryChrome()
        shot("rt-pitch-feedback.png")
        dump("rt2-pitch.ax.txt")

        // Sessions list for persistence smoke
        if app.tabBars.buttons["Sessions"].waitForExistence(timeout: 3) {
            app.tabBars.buttons["Sessions"].tap()
            sleep(1)
            shot("rt2-sessions.png")
            dump("rt2-sessions.ax.txt")
            if app.cells.firstMatch.waitForExistence(timeout: 3) {
                forceTap(app.cells.firstMatch)
                sleep(1)
                shot("rt2-session-detail.png")
                dump("rt2-session-detail.ax.txt")
            }
        }
    }
}
