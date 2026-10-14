import SwiftUI

enum ScoutCueTheme {
    static let indigo = Color(red: 0x43 / 255, green: 0x38 / 255, blue: 0xCA / 255)
    static let wash = Color(red: 0xEE / 255, green: 0xF2 / 255, blue: 0xFF / 255)
    static let rose = Color(red: 0xFB / 255, green: 0x71 / 255, blue: 0x85 / 255)
    static let mist = Color(red: 0xF8 / 255, green: 0xFA / 255, blue: 0xFC / 255)
    static let ink = Color(red: 0x1E / 255, green: 0x1B / 255, blue: 0x4B / 255)
    static let muted = Color(red: 0x64 / 255, green: 0x63 / 255, blue: 0x8B / 255)
    static let gold = Color(red: 0xF5 / 255, green: 0x9E / 255, blue: 0x0B / 255)
    static let sky = Color(red: 0x7D / 255, green: 0xD3 / 255, blue: 0xFC / 255)
}

extension View {
    func scoutCueScreen() -> some View {
        self
            .background(ScoutCueTheme.wash.ignoresSafeArea())
    }
}
