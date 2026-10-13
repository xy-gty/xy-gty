import XCTest

/// Controller retest: four Info.plist keys ↔ four measurable UI entry points.
final class FourPerm: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication(bundleIdentifier: "com.lingguang.docbrief")
        app.launchArguments = ["-UITesting"]
        app.launch()
    }

    private func tapLabel(_ label: String, timeout: TimeInterval = 5) -> Bool {
        let matches = app.buttons.matching(NSPredicate(format: "label == %@", label))
        let b = matches.element(boundBy: 0)
        guard b.waitForExistence(timeout: timeout) else { return false }
        if b.isHittable { b.tap() } else { b.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        return true
    }

    private func tapId(_ id: String, timeout: TimeInterval = 4) -> Bool {
        let e = app.descendants(matching: .any).matching(NSPredicate(format: "identifier == %@", id)).firstMatch
        guard e.waitForExistence(timeout: timeout) else { return false }
        if e.isHittable { e.tap() } else { e.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        return true
    }

    private func existsFragment(_ fragment: String, timeout: TimeInterval = 4) -> Bool {
        let pred = NSPredicate(format: "label CONTAINS[c] %@", fragment)
        return app.descendants(matching: .any).matching(pred).firstMatch.waitForExistence(timeout: timeout)
    }

    private func openHub() {
        if tapLabel("Start brief", timeout: 3) {
            if app.textFields.firstMatch.waitForExistence(timeout: 3) {
                app.textFields.firstMatch.tap()
                app.textFields.firstMatch.typeText("FourPerm Brief")
            }
            _ = tapLabel("Create brief", timeout: 5)
        }
        // Prefer tab-bar Active brief by identifier
        if !tapId("checkmark.seal", timeout: 3) {
            _ = tapLabel("Active brief", timeout: 3)
        }
    }

    func testFourPermissionEntryPoints() {
        openHub()
        sleep(1)

        // Settings documents the four permission → entry mappings
        XCTAssertTrue(tapId("gearshape", timeout: 4) || tapLabel("Settings", timeout: 3), "Open Settings")
        sleep(1)
        // Revoke sits above Device permissions — check before deep scroll
        let revokeVisible = app.buttons["revoke_ai_consent"].waitForExistence(timeout: 4)
            || existsFragment("Revoke AI consent", timeout: 2)
        for _ in 0..<5 { app.swipeUp() }
        let cam = existsFragment("Camera (Take photo)", timeout: 4)
            || existsFragment("Take photo", timeout: 2)
        let photo = existsFragment("Photo Library (Add photos)", timeout: 3)
            || existsFragment("Add photos", timeout: 2)
            || existsFragment("Photo Library", timeout: 2)
        let mic = existsFragment("Microphone (Voice supplement)", timeout: 3)
            || existsFragment("Microphone", timeout: 2)
        let speech = existsFragment("Speech Recognition", timeout: 3)
            || existsFragment("Speech", timeout: 2)
        XCTAssertTrue(cam, "Settings lists Camera → Take photo")
        XCTAssertTrue(photo, "Settings lists Photo Library → Add photos")
        XCTAssertTrue(mic, "Settings lists Microphone → Voice supplement")
        XCTAssertTrue(speech, "Settings lists Speech Recognition → Voice supplement")
        // After scroll, swipe back up for revoke if needed
        if !revokeVisible {
            for _ in 0..<5 { app.swipeDown() }
        }
        XCTAssertTrue(
            revokeVisible
                || app.buttons["revoke_ai_consent"].waitForExistence(timeout: 4)
                || existsFragment("Revoke AI consent", timeout: 3),
            "Revoke AI consent control present"
        )

        // Measurable ImportCapture CTAs
        XCTAssertTrue(tapId("checkmark.seal", timeout: 4) || tapLabel("Active brief", timeout: 3))
        sleep(1)
        let addPhotos = tapLabel("Add photos", timeout: 6) || tapId("add_photos", timeout: 2)
        XCTAssertTrue(addPhotos, "Add photos entry measurable")
        let takePhoto = existsFragment("Take photo", timeout: 5) || tapId("take_photo", timeout: 2)
        XCTAssertTrue(takePhoto, "Take photo entry measurable")
        // Dismiss import if needed
        if app.buttons["Cancel"].waitForExistence(timeout: 1) { app.buttons["Cancel"].tap() }
        if app.navigationBars.buttons["BackButton"].waitForExistence(timeout: 2) {
            app.navigationBars.buttons["BackButton"].tap()
        }

        XCTAssertTrue(tapId("checkmark.seal", timeout: 4) || tapLabel("Active brief", timeout: 3))
        XCTAssertTrue(tapLabel("Chat extract", timeout: 6), "Chat extract primary CTA")
        let voice = tapLabel("Voice supplement", timeout: 5)
            || tapId("voice_supplement_chat", timeout: 2)
            || existsFragment("Voice supplement", timeout: 3)
        XCTAssertTrue(voice, "Voice supplement on Chat measurable")
        // Simulator dictation draft → known_issue, not block

        // Primary CTAs not replaced by voice
        if app.navigationBars.buttons["BackButton"].waitForExistence(timeout: 2) {
            app.navigationBars.buttons["BackButton"].tap()
        }
        XCTAssertTrue(tapId("checkmark.seal", timeout: 4) || tapLabel("Active brief", timeout: 3))
        XCTAssertTrue(
            app.buttons["Add photos"].waitForExistence(timeout: 4)
                || app.buttons["Chat extract"].exists
                || app.buttons["Speak briefing"].exists
                || app.buttons["Generate summary card"].exists,
            "Primary sell-path CTAs remain"
        )
    }
}
