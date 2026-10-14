import SwiftUI
import DuctCueDomain

extension DuctCueRoute: Hashable {}

enum DuctCueTheme {
    static let primary = Color(red: 14 / 255, green: 116 / 255, blue: 144 / 255)
    static let secondary = Color(red: 240 / 255, green: 249 / 255, blue: 255 / 255)
    static let accent = Color(red: 245 / 255, green: 158 / 255, blue: 11 / 255)
    static let ink = Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255)

    static let cardBackground = Color.white.opacity(0.92)
    static let canvasLine = primary.opacity(0.85)

    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(primary.opacity(configuration.isPressed ? 0.85 : 1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(secondary.opacity(configuration.isPressed ? 0.7 : 1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(primary.opacity(0.35), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    struct AccentChipStyle: ButtonStyle {
        var selected: Bool

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(selected ? Color.white : ink)
                .background(selected ? accent : secondary)
                .clipShape(Capsule())
                .opacity(configuration.isPressed ? 0.85 : 1)
        }
    }
}

struct IsometricDuctCanvas: View {
    var lineWidth: CGFloat = 4
    var accentChip: String?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DuctCueTheme.secondary)
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: size.width * 0.12, y: size.height * 0.72))
                path.addLine(to: CGPoint(x: size.width * 0.38, y: size.height * 0.42))
                path.addLine(to: CGPoint(x: size.width * 0.62, y: size.height * 0.48))
                path.addLine(to: CGPoint(x: size.width * 0.82, y: size.height * 0.28))
                context.stroke(path, with: .color(DuctCueTheme.canvasLine), lineWidth: lineWidth)
            }
            if let accentChip {
                Text(accentChip)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DuctCueTheme.accent.opacity(0.15))
                    .foregroundStyle(DuctCueTheme.accent)
                    .clipShape(Capsule())
                    .padding(12)
            }
        }
        .frame(height: 180)
        .accessibilityLabel("Isometric duct canvas")
    }
}
