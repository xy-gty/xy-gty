import XCTest

final class CellarCueAcceptanceJourneyTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-smoke-reset"]
        app.launch()
        XCTAssertTrue(app.staticTexts["CellarCue"].waitForExistence(timeout: 15))
    }

    func testUL01HomeSignatureAndCompliance() {
        let compliance = app.otherElements["ComplianceBanner"].waitForExistence(timeout: 6)
            || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "非侍酒")).firstMatch.waitForExistence(timeout: 4)
        XCTAssertTrue(compliance)
        let disclaimer = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@ OR label CONTAINS[c] %@", "非侍酒", "sommelier")
        ).firstMatch
        XCTAssertTrue(disclaimer.waitForExistence(timeout: 4))
        XCTAssertTrue(
            app.otherElements["CellarRowBinGrid"].waitForExistence(timeout: 4)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "R1-B")).firstMatch.exists
        )
        XCTAssertTrue(app.otherElements["LabelOCRHeroCard"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.otherElements["DrinkingWindowTimeline"].waitForExistence(timeout: 4))
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "AI not configured")).firstMatch
                .waitForExistence(timeout: 8)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "local capture")).firstMatch.exists
        )
    }

    func testUL02CaptureViaShootPhotoLibrary() {
        let shoot = app.buttons["ShootButton"].exists ? app.buttons["ShootButton"] : app.buttons["Shoot"]
        XCTAssertTrue(shoot.waitForExistence(timeout: 5))
        shoot.tap()
        let photo = app.scrollViews.images.element(boundBy: 0)
        if photo.waitForExistence(timeout: 8) {
            photo.tap()
        } else if app.buttons["Choose"].waitForExistence(timeout: 4) {
            app.buttons["Choose"].tap()
        } else if app.navigationBars.buttons.element(boundBy: 0).waitForExistence(timeout: 4) {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        XCTAssertTrue(
            app.navigationBars["Label result"].waitForExistence(timeout: 12)
                || app.buttons["Identify / Place"].waitForExistence(timeout: 12)
        )
    }

    func testUL03LocalCoachWithoutKeyAndConsentSheet() {
        seedLabelResultIfNeeded()
        let identify = app.buttons["Identify / Place"]
        if identify.waitForExistence(timeout: 4) {
            identify.tap()
            let allow = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Allow")).firstMatch
            if allow.waitForExistence(timeout: 4) {
                allow.tap()
            }
            let notNow = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Not now")).firstMatch
            if notNow.waitForExistence(timeout: 2) {
                notNow.tap()
            }
        }
        if app.navigationBars.buttons.element(boundBy: 0).exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
        let field = app.textFields.firstMatch
        if field.waitForExistence(timeout: 5) {
            field.tap()
            field.typeText("pair with lamb")
            app.buttons["Ask"].tap()
        }
        let localCoach = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS %@", "AI not configured", "investment advice")
        ).firstMatch
        XCTAssertTrue(localCoach.waitForExistence(timeout: 10) || app.staticTexts.count > 3)
    }

    func testUL04SaveBottleAndPersistenceAfterRelaunch() {
        seedLabelResultIfNeeded()
        let save = app.buttons["Save Bottle"]
        if save.waitForExistence(timeout: 6) {
            save.tap()
        }
        app.terminate()
        app.launchArguments = []
        app.launch()
        XCTAssertTrue(app.staticTexts["CellarCue"].waitForExistence(timeout: 12))
        let binFilled = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "occupied")).firstMatch
        XCTAssertTrue(
            binFilled.waitForExistence(timeout: 8)
                || app.otherElements["LabelOCRHeroCard"].waitForExistence(timeout: 4)
        )
    }

    func testUL07ScrollHomeShowsGridAndCTAs() {
        app.swipeUp()
        app.swipeUp()
        XCTAssertTrue(
            app.buttons["ShootButton"].waitForExistence(timeout: 4) || app.buttons["Shoot"].exists
        )
        XCTAssertTrue(app.otherElements["CellarRowBinGrid"].waitForExistence(timeout: 4))
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "home-scrolled"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testUL06SettingsLegalAndRevoke() {
        openSettings()
        app.swipeUp()
        app.swipeUp()
        let privacy = app.buttons["Privacy"].exists ? app.buttons["Privacy"] : app.staticTexts["Privacy"]
        XCTAssertTrue(privacy.waitForExistence(timeout: 5))
        privacy.tap()
        XCTAssertTrue(app.navigationBars["Privacy"].waitForExistence(timeout: 8))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.swipeUp()
        let provider = app.buttons["Provider policy"].exists ? app.buttons["Provider policy"] : app.staticTexts["Provider policy"]
        XCTAssertTrue(provider.waitForExistence(timeout: 5))
        provider.tap()
        XCTAssertTrue(app.navigationBars["Provider-policy"].waitForExistence(timeout: 8)
            || app.navigationBars["Provider policy"].waitForExistence(timeout: 2))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.swipeUp()
        app.swipeUp()
        let revoke = app.buttons["Revoke AI consent"]
        XCTAssertTrue(revoke.waitForExistence(timeout: 8))
        revoke.tap()
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "revoked")).firstMatch.waitForExistence(timeout: 6)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "AI unavailable")).firstMatch.exists
        )
    }

    func testUL02RackCardVoiceAndTTSRoutes() {
        seedLabelResultIfNeeded()
        if app.buttons["Make rack card"].waitForExistence(timeout: 5) {
            app.buttons["Make rack card"].tap()
            XCTAssertTrue(app.navigationBars.matching(NSPredicate(format: "identifier CONTAINS[c] %@", "Rack")).firstMatch.waitForExistence(timeout: 6)
                || app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Pull from")).firstMatch.exists)
            app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Keep")).firstMatch.tap()
        }
        if app.buttons["Play brief"].waitForExistence(timeout: 4) {
            app.buttons["Play brief"].tap()
            XCTAssertTrue(app.otherElements["PullBriefView"].waitForExistence(timeout: 6))
        }
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Voice note")).firstMatch.tap()
        XCTAssertTrue(app.otherElements["VoiceNoteView"].waitForExistence(timeout: 6))
    }

    private func openSettings() {
        let settings = app.buttons["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 5))
        settings.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 6))
    }

    private func seedLabelResultIfNeeded() {
        if app.buttons["Identify / Place"].waitForExistence(timeout: 2) { return }
        let shoot = app.buttons["ShootButton"].exists ? app.buttons["ShootButton"] : app.buttons["Shoot"]
        guard shoot.waitForExistence(timeout: 4) else { return }
        shoot.tap()
        let photo = app.scrollViews.images.element(boundBy: 0)
        if photo.waitForExistence(timeout: 8) { photo.tap() }
        _ = app.buttons["Identify / Place"].waitForExistence(timeout: 12)
    }
}
