import SwiftUI

enum PitchCueTheme {
    /// Operator-locked palette (#7C3AED / #F5F3FF / #10B981) + support ink/fill.
    static let violet = Color(hex: 0x7C3AED)
    static let lilac = Color(hex: 0xF5F3FF)
    static let mint = Color(hex: 0x10B981)
    static let ink = Color(hex: 0x1E293B)
    static let softCloud = Color(hex: 0xFFFFFF)
    static let muted = Color(hex: 0x64748B)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

struct PitchCueScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PitchCueTheme.lilac.ignoresSafeArea())
            .foregroundStyle(PitchCueTheme.ink)
    }
}

extension View {
    func pitchCueScreen() -> some View {
        modifier(PitchCueScreenBackground())
    }
}
