import XCTest

final class LegalTests: XCTestCase {
    var app: XCUIApplication!
    let evidenceDir =
        "/Users/a2026/work/factory-prod-1/runs/kf-20261015T111031Z-ed6f1861/stages/ai_app_accept/attempt-1/evidence/runtime"

    override func setUpWithError() throws {
        continueAfterFailure = true
        try FileManager.default.createDirectory(atPath: evidenceDir, withIntermediateDirectories: true)
        app = XCUIApplication(bundleIdentifier: "com.lingguang.rulecue")
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

    private func tapLabel(_ frag: String, timeout: TimeInterval = 6) -> Bool {
        let button = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", frag)).firstMatch
        if button.waitForExistence(timeout: timeout) {
            if button.isHittable { button.tap() } else {
                button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
            return true
        }
        return false
    }

    func testOpenLocalLegalPages() throws {
        let settings = app.tabBars.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "Settings")).firstMatch
        XCTAssertTrue(settings.waitForExistence(timeout: 6))
        settings.tap()
        sleep(1)
        app.swipeUp()
        sleep(1)
        XCTAssertTrue(tapLabel("Open local legal pages"), "Legal entry missing")
        sleep(1)
        shot("ul06-legal-index.png")
        dump("ul06-legal-index.ax.txt")
        for label in ["Privacy", "Terms", "Support", "Provider policy"] {
            if tapLabel(label) {
                sleep(1)
                let slug = label.lowercased().replacingOccurrences(of: " ", with: "-")
                shot("ul06-\(slug).png")
                dump("ul06-\(slug).ax.txt")
                if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
                    app.navigationBars.buttons.firstMatch.tap()
                    sleep(1)
                }
            }
        }
    }
}
