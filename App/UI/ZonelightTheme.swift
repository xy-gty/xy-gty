import SwiftUI

enum ZonelightTheme {
    static let primary = Color(red: 0x1D / 255, green: 0x4E / 255, blue: 0xD8 / 255)
    static let secondary = Color(red: 0xF0 / 255, green: 0xF9 / 255, blue: 0xFF / 255)
    static let accent = Color(red: 0xEA / 255, green: 0xB3 / 255, blue: 0x08 / 255)
    static let ink = Color(red: 0x1E / 255, green: 0x3A / 255, blue: 0x8A / 255)
    static let muted = Color(red: 0x64 / 255, green: 0x74 / 255, blue: 0x8B / 255)
    static let card = Color.white.opacity(0.92)
}

extension View {
    func luxScreen() -> some View {
        self.background(
            LinearGradient(
                colors: [ZonelightTheme.secondary, Color.white, ZonelightTheme.secondary.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
