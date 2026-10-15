import SwiftUI

enum RuleCueTheme {
    /// table-amber #854D0E
    static let primary = Color(red: 0x85 / 255, green: 0x4D / 255, blue: 0x0E / 255)
    /// parchment-wash #FEFCE8
    static let secondary = Color(red: 0xFE / 255, green: 0xFC / 255, blue: 0xE8 / 255)
    /// cue-cyan #0891B2
    static let accent = Color(red: 0x08 / 255, green: 0x91 / 255, blue: 0xB2 / 255)
    /// ink #422006
    static let ink = Color(red: 0x42 / 255, green: 0x20 / 255, blue: 0x06 / 255)
    static let card = Color.white
    static let muted = ink.opacity(0.62)
}

extension View {
    func ruleCueScreen() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RuleCueTheme.secondary.ignoresSafeArea())
    }
}
