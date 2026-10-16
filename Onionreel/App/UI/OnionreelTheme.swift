import SwiftUI

enum OnionreelTheme {
    /// sprocket-green #16A34A
    static let primary = Color(red: 0x16 / 255, green: 0xA3 / 255, blue: 0x4A / 255)
    /// mint-wash #F0FDF4
    static let secondary = Color(red: 0xF0 / 255, green: 0xFD / 255, blue: 0xF4 / 255)
    /// magenta-cue #DB2777
    static let accent = Color(red: 0xDB / 255, green: 0x27 / 255, blue: 0x77 / 255)
    /// ink #14532D
    static let ink = Color(red: 0x14 / 255, green: 0x53 / 255, blue: 0x2D / 255)
    static let card = Color.white
    static let muted = ink.opacity(0.62)
}

extension View {
    func onionreelScreen() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(OnionreelTheme.secondary.ignoresSafeArea())
    }
}
