import SwiftUI

enum HiveCueTheme {
    static let primary = Color(red: 0x9F / 255, green: 0x12 / 255, blue: 0x39 / 255)
    static let secondary = Color(red: 0xFD / 255, green: 0xF2 / 255, blue: 0xF8 / 255)
    static let accent = Color(red: 0x4D / 255, green: 0x7C / 255, blue: 0x0F / 255)
    static let ink = Color(red: 0x88 / 255, green: 0x13 / 255, blue: 0x37 / 255)
    static let card = Color.white
    static let muted = ink.opacity(0.62)
    static let heatHot = Color(red: 0xBE / 255, green: 0x12 / 255, blue: 0x3C / 255)
    static let heatCool = accent.opacity(0.35)
}

extension View {
    func hiveCueScreen() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(HiveCueTheme.secondary.ignoresSafeArea())
    }
}
