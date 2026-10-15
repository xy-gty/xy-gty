import SwiftUI

enum FrameCueTheme {
    static let primary = Color(red: 0x7E / 255, green: 0x22 / 255, blue: 0xCE / 255)
    static let secondary = Color(red: 0xFA / 255, green: 0xF5 / 255, blue: 0xFF / 255)
    static let accent = Color(red: 0xF5 / 255, green: 0x9E / 255, blue: 0x0B / 255)
    static let ink = Color(red: 0x4C / 255, green: 0x1D / 255, blue: 0x95 / 255)
    static let card = Color.white
    static let muted = Color(red: 0x4C / 255, green: 0x1D / 255, blue: 0x95 / 255).opacity(0.65)
}

extension View {
    func frameCueScreen() -> some View {
        self.background(FrameCueTheme.secondary.ignoresSafeArea())
    }
}

/// Clapper / slate frame canvas — FrameCue signature chrome (not film sprocket / table cards / night rail).
struct ClapperFrameCanvas<Content: View>: View {
    var title: String
    var shotLabel: String
    var pulse: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(FrameCueTheme.accent)
                    .frame(width: 28, height: 10)
                    .rotationEffect(.degrees(-12))
                Text(title.uppercased())
                    .font(.caption.weight(.heavy))
                    .tracking(1.2)
                    .foregroundStyle(FrameCueTheme.secondary)
                Spacer()
                Text(shotLabel)
                    .font(.caption.bold())
                    .foregroundStyle(FrameCueTheme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.black.opacity(0.25)))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    colors: [FrameCueTheme.primary, FrameCueTheme.ink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            ZStack {
                FrameCueTheme.card
                content()
            }
            .frame(minHeight: 220)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .padding(10)
            .background(FrameCueTheme.primary.opacity(0.12))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(pulse ? FrameCueTheme.accent : FrameCueTheme.primary, lineWidth: pulse ? 3 : 2)
        )
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(FrameCueTheme.card)
                .shadow(color: FrameCueTheme.primary.opacity(0.18), radius: 8, y: 4)
        )
        .accessibilityIdentifier("clapper_frame_canvas")
    }
}

/// Bottom shot-size chip bar — FrameCue signature chrome.
struct ShotSizeChipBar: View {
    let chips: [String]
    let selected: String
    var onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips, id: \.self) { chip in
                    let isOn = chip == selected
                    Button {
                        onSelect(chip)
                    } label: {
                        Text(chip)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isOn ? Color.white : FrameCueTheme.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isOn ? FrameCueTheme.accent : FrameCueTheme.card)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(isOn ? FrameCueTheme.accent : FrameCueTheme.primary.opacity(0.35), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("shot_chip_\(chip)")
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
        }
        .accessibilityIdentifier("shot_size_chip_bar")
    }
}
