import XCTest
final class LegalScrollTests: XCTestCase {
    func testScrollOpenLegal() throws {
        let evidenceDir = "/Users/a2026/work/factory-prod-1/runs/kf-20261015T093242Z-0f4256a0/stages/ai_app_accept/attempt-1/evidence/runtime"
        let app = XCUIApplication(bundleIdentifier: "com.lingguang.stopcue")
        app.terminate(); app.launch(); sleep(1)
        app.tabBars.buttons["Settings"].tap(); sleep(1)
        let table = app.collectionViews.firstMatch.exists ? app.collectionViews.firstMatch : app.tables.firstMatch
        for _ in 0..<6 { table.swipeUp(); usleep(400_000) }
        let png = XCUIScreen.main.screenshot().pngRepresentation
        try? png.write(to: URL(fileURLWithPath: evidenceDir).appendingPathComponent("rt-settings-scrolled.png"))
        try? app.debugDescription.write(to: URL(fileURLWithPath: evidenceDir).appendingPathComponent("rt-settings-scrolled.ax.txt"), atomically: true, encoding: .utf8)
        for (label, file) in [("Privacy","ul06-privacy"),("Terms","ul06-terms"),("Support","ul06-support"),("Provider policy","ul06-provider")] {
            let el = app.staticTexts[label]
            let btn = app.buttons[label]
            let cell = app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", label)).firstMatch
            if el.waitForExistence(timeout: 2) { el.tap() }
            else if btn.waitForExistence(timeout: 1) { btn.tap() }
            else if cell.waitForExistence(timeout: 1) { cell.tap() }
            else { continue }
            sleep(2)
            let p = XCUIScreen.main.screenshot().pngRepresentation
            try? p.write(to: URL(fileURLWithPath: evidenceDir).appendingPathComponent("\(file).png"))
            try? app.debugDescription.write(to: URL(fileURLWithPath: evidenceDir).appendingPathComponent("\(file).ax.txt"), atomically: true, encoding: .utf8)
            if app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 2) {
                app.navigationBars.buttons.firstMatch.tap(); sleep(1)
            }
            for _ in 0..<3 { table.swipeUp(); usleep(300_000) }
        }
    }
}
