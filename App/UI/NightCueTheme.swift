import SwiftUI

enum NightCueTheme {
    /// night-navy #1E3A8A
    static let primary = Color(red: 0x1E / 255, green: 0x3A / 255, blue: 0x8A / 255)
    /// ice-wash #EFF6FF
    static let secondary = Color(red: 0xEF / 255, green: 0xF6 / 255, blue: 0xFF / 255)
    /// amber-cue #FBBF24
    static let accent = Color(red: 0xFB / 255, green: 0xBF / 255, blue: 0x24 / 255)
    /// ink #1E3A5F
    static let ink = Color(red: 0x1E / 255, green: 0x3A / 255, blue: 0x5F / 255)
    static let card = Color.white
    static let muted = ink.opacity(0.62)
    static let underexposed = primary.opacity(0.85)
    static let passZone = accent
}

extension View {
    func nightCueScreen() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(NightCueTheme.secondary.ignoresSafeArea())
    }
}
