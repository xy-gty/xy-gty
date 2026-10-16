import SwiftUI
import BrewCueDomain

enum BrewCueTheme {
    static let primary = Color(hex: 0xA16207)
    static let secondary = Color(hex: 0xECFDF5)
    static let accent = Color(hex: 0x4F46E5)
    static let ink = Color(red: 0.18, green: 0.14, blue: 0.08)
    static let muted = Color(red: 0.38, green: 0.34, blue: 0.28)
    static let mintField = LinearGradient(
        colors: [Color(hex: 0xECFDF5), Color.white, Color(hex: 0xECFDF5).opacity(0.9)],
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
    func brewCueScreen() -> some View {
        self.background(BrewCueTheme.mintField.ignoresSafeArea())
    }
}

struct ComplianceBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(BrewCueCompliance.bannerEN)
                .font(.caption.weight(.semibold))
            Text(BrewCueCompliance.bannerZH)
                .font(.caption2)
        }
        .foregroundStyle(BrewCueTheme.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(BrewCueTheme.secondary.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(BrewCueTheme.primary.opacity(0.4), lineWidth: 1)
                )
        )
        .accessibilityIdentifier("ComplianceBanner")
    }
}
