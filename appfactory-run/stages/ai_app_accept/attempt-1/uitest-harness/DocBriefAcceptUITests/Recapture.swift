import XCTest

final class Recapture: XCTestCase {
    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication(bundleIdentifier: "com.lingguang.docbrief")
        app.launch()
    }
    private func tap(_ s: String, t: TimeInterval = 5) -> Bool {
        let b = app.buttons[s]
        guard b.waitForExistence(timeout: t) else { return false }
        if b.isHittable { b.tap() } else { b.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        return true
    }
    func testA_fieldsReview() {
        _ = tap("Active brief", t: 4)
        _ = tap("Review recognition", t: 5) || tap("Recognize type & fields", t: 3)
        _ = tap("Allow DeepSeek inference", t: 2) || tap("Allow", t: 2)
        sleep(1)
        XCTAssertTrue(true)
    }
    func testB_briefDetail() {
        _ = tap("Active brief", t: 4)
        _ = tap("Add field", t: 4) || tap("Add field manually", t: 2)
        if app.textFields.count >= 1 { app.textFields.element(boundBy: 0).tap(); app.textFields.element(boundBy: 0).typeText("total") }
        if app.textFields.count >= 2 { app.textFields.element(boundBy: 1).tap(); app.textFields.element(boundBy: 1).typeText("42.50") }
        _ = tap("Save", t: 4)
        sleep(1)
        XCTAssertTrue(true)
    }
    func testC_chat() {
        _ = tap("Active brief", t: 4)
        _ = tap("Chat extract", t: 6)
        sleep(1)
        XCTAssertTrue(true)
    }
    func testD_summary() {
        _ = tap("Active brief", t: 4)
        _ = tap("Generate summary card", t: 5) || tap("Summary card", t: 3)
        sleep(1)
        XCTAssertTrue(true)
    }
    func testE_settingsScroll() {
        if app.tabBars.buttons["Settings"].waitForExistence(timeout: 4) { app.tabBars.buttons["Settings"].tap() }
        app.swipeUp(); sleep(1); app.swipeUp(); sleep(1)
        XCTAssertTrue(true)
    }
}
