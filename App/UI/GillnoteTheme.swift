import SwiftUI
import GillnoteDomain

enum GillnoteTheme {
    static let primary = Color(hex: GillnotePalette.primary)
    static let secondary = Color(hex: GillnotePalette.secondary)
    static let accent = Color(hex: GillnotePalette.accent)
    static let ink = Color(red: 0.26, green: 0.09, blue: 0.03)
    static let muted = Color(red: 0.45, green: 0.28, blue: 0.18)
    static let barFace = Color(red: 0.98, green: 0.93, blue: 0.86)
    static let stackSlot = Color(red: 1.0, green: 0.97, blue: 0.94)
    static let chipFace = Color(red: 1.0, green: 0.95, blue: 0.90)

    static let disclaimer = GillnoteCompliance.requiredDisclaimer
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0x9A, 0x34, 0x12)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

struct SporeScreenModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(GillnoteTheme.secondary.ignoresSafeArea())
    }
}

extension View {
    func sporeScreen() -> some View {
        modifier(SporeScreenModifier())
    }
}

struct DisclaimerBanner: View {
    var body: some View {
        Text(GillnoteTheme.disclaimer)
            .font(.caption.weight(.bold))
            .foregroundStyle(GillnoteTheme.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(GillnoteTheme.barFace)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(GillnoteTheme.primary.opacity(0.35), lineWidth: 1)
                    )
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("DisclaimerBanner")
    }
}

struct StatusBanner: View {
    let text: String
    var isError = false

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(isError ? GillnoteTheme.primary : GillnoteTheme.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isError ? GillnoteTheme.primary.opacity(0.12) : GillnoteTheme.accent.opacity(0.12))
            )
    }
}
