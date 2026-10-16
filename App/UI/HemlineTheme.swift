import SwiftUI

enum HemlineTheme {
    static let bg = Color(red: 0x2A / 255, green: 0x2E / 255, blue: 0x34 / 255)
    static let surface = Color(red: 0x3A / 255, green: 0x40 / 255, blue: 0x48 / 255)
    static let ink = Color(red: 0xF5 / 255, green: 0xF1 / 255, blue: 0xEA / 255)
    static let muted = Color(red: 0xA3 / 255, green: 0x9E / 255, blue: 0x96 / 255)
    static let cta = Color(red: 0xD4 / 255, green: 0xA5 / 255, blue: 0x74 / 255)
    static let accent = Color(red: 0x7A / 255, green: 0x9E / 255, blue: 0x8A / 255)
    static let line = Color(red: 0x4A / 255, green: 0x50 / 255, blue: 0x58 / 255)
    static let warn = Color(red: 0xE0 / 255, green: 0xB3 / 255, blue: 0x5A / 255)

    static func heroTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundStyle(ink)
    }

    static func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline.weight(.semibold))
            .foregroundStyle(ink)
    }

    static func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(ink)
    }

    static func mutedText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(muted)
    }
}

struct CCPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(HemlineTheme.bg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(HemlineTheme.cta.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct CCSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.medium))
            .foregroundStyle(HemlineTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(HemlineTheme.surface.opacity(configuration.isPressed ? 0.85 : 1))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(HemlineTheme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct CCTagChip: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption.weight(.medium))
            .foregroundStyle(HemlineTheme.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(HemlineTheme.accent.opacity(0.35))
            .clipShape(Capsule())
    }
}

struct CCStatusBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote.weight(.medium))
            .foregroundStyle(HemlineTheme.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(HemlineTheme.surface)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(HemlineTheme.line),
                alignment: .top
            )
    }
}

struct CCSceneBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(HemlineTheme.bg.ignoresSafeArea())
    }
}

extension View {
    func hemlineScene() -> some View {
        modifier(CCSceneBackground())
    }
}
