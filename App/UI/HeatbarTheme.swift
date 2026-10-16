import SwiftUI

enum HeatbarTheme {
    static let primary = Color(hex: 0xBE185D)
    static let secondary = Color(hex: 0xECFEFF)
    static let accent = Color(hex: 0x65A30D)
    static let ink = Color(red: 0.12, green: 0.08, blue: 0.14)
    static let muted = Color(red: 0.35, green: 0.32, blue: 0.38)
    static let iceField = LinearGradient(
        colors: [Color(hex: 0xECFEFF), Color.white, Color(hex: 0xECFEFF).opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension View {
    func heatbarScreen() -> some View {
        self
            .background(HeatbarTheme.iceField.ignoresSafeArea())
    }
}

struct ComplianceBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Training aid & amateur meet photo timing")
                .font(.caption.weight(.semibold))
            Text("Not an official FAT timing device · Not betting or anti-doping")
                .font(.caption2)
            Text("辅助训练/业余会合影计时；非官方 FAT；非博彩/反兴奋剂")
                .font(.caption2)
        }
        .foregroundStyle(HeatbarTheme.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(HeatbarTheme.secondary.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(HeatbarTheme.primary.opacity(0.35), lineWidth: 1)
                )
        )
        .accessibilityIdentifier("ComplianceBanner")
    }
}
