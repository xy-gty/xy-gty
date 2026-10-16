import SwiftUI

enum RacknoteTheme {
    static let primary = Color(hex: 0x3730A3)
    static let secondary = Color(hex: 0xEEF2FF)
    static let accent = Color(hex: 0xEA580C)
    static let ink = Color(hex: 0x1E1B4B)
    static let muted = Color(hex: 0x4C4A6A)
    static let binEmpty = Color(hex: 0xE0E7FF)
    static let binFilled = Color(hex: 0xC7D2FE)
    static let cardFill = Color.white.opacity(0.92)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

extension View {
    func cellarScreen() -> some View {
        self.background(RacknoteTheme.secondary.ignoresSafeArea())
    }
}
