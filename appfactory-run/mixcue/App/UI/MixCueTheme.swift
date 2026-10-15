import SwiftUI
import MixCueDomain

enum MixCueTheme {
    static let primary = Color(hex: MixCuePalette.primary)
    static let secondary = Color(hex: MixCuePalette.secondary)
    static let accent = Color(hex: MixCuePalette.accent)
    static let ink = Color(red: 0.22, green: 0.08, blue: 0.12)
    static let muted = Color(red: 0.45, green: 0.28, blue: 0.32)
    static let cardFace = Color.white.opacity(0.92)
    static let railSlot = Color.white.opacity(0.78)
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: Double
        switch cleaned.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 1; g = 0.12; b = 0.28
        }
        self.init(red: r, green: g, blue: b)
    }
}

extension View {
    func mixCueScreen() -> some View {
        self
            .background(MixCueTheme.secondary.ignoresSafeArea())
    }
}

struct StatusBanner: View {
    let text: String
    var isError = false

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isError ? Color.white : MixCueTheme.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isError ? MixCueTheme.primary : MixCueTheme.cardFace)
            )
            .accessibilityIdentifier("StatusBanner")
    }
}

/// Vertical bottle-rail — signature MixCue species (not field-card / mosaic / clapper / sprocket).
struct BottleRailView: View {
    let candidates: [SpiritCandidate]
    var emptyHint = false

    var body: some View {
        VStack(spacing: 10) {
            Text("Bottle rail")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MixCueTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            if candidates.isEmpty {
                ForEach(0..<3, id: \.self) { index in
                    railSlot(
                        title: emptyHint ? (index == 0 ? "Empty slot" : "—") : "—",
                        subtitle: emptyHint && index == 0 ? "Shoot or import a bottle" : "Waiting for ID",
                        confidence: nil
                    )
                }
            } else {
                ForEach(candidates.sorted(by: { $0.rank < $1.rank }), id: \.rank) { candidate in
                    railSlot(
                        title: candidate.displayName,
                        subtitle: candidate.baseSpirit + " · " + candidate.labelCues.prefix(2).joined(separator: " · "),
                        confidence: candidate.confidence
                    )
                }
            }
        }
        .frame(width: 118)
        .accessibilityIdentifier("BottleRail")
    }

    private func railSlot(title: String, subtitle: String, confidence: Double?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [MixCueTheme.primary.opacity(0.85), MixCueTheme.accent.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 72)
                .overlay(
                    Image(systemName: "wineglass.fill")
                        .font(.title2)
                        .foregroundStyle(Color.white.opacity(0.95))
                )
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(MixCueTheme.ink)
                .lineLimit(2)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(MixCueTheme.muted)
                .lineLimit(2)
            if let confidence {
                Text(String(format: "%.0f%%", confidence * 100))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MixCueTheme.accent)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(MixCueTheme.railSlot)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(MixCueTheme.primary.opacity(0.35), lineWidth: 1.5)
        )
    }
}

/// Large next-pour card — primary action surface.
struct NextPourCardView: View {
    let step: PourStep?
    var isActive = true
    var onNext: (() -> Void)?
    var onSpeak: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(step.map { "Step \($0.ordinal)" } ?? "Next pour")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MixCueTheme.accent)
                Spacer()
                if isActive {
                    Text("ACTIVE")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(MixCueTheme.accent.opacity(0.2)))
                        .foregroundStyle(MixCueTheme.accent)
                }
            }

            Text(step?.instruction ?? "Capture a bottle to unlock the next pour.")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(MixCueTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

            if let step {
                HStack(spacing: 12) {
                    Label(step.action.capitalized, systemImage: icon(for: step.action))
                    if let ml = step.amountMl {
                        Text("\(Int(ml)) ml")
                    }
                    if let sec = step.durationSec {
                        Text("\(Int(sec))s")
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MixCueTheme.muted)
            }

            HStack(spacing: 10) {
                if let onSpeak {
                    Button("Speak step", action: onSpeak)
                        .buttonStyle(.bordered)
                        .tint(MixCueTheme.primary)
                }
                if let onNext {
                    Button("Next step", action: onNext)
                        .buttonStyle(.borderedProminent)
                        .tint(MixCueTheme.accent)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(MixCueTheme.cardFace)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isActive ? MixCueTheme.accent : MixCueTheme.primary.opacity(0.2), lineWidth: isActive ? 3 : 1)
        )
        .accessibilityIdentifier("NextPourCard")
    }

    private func icon(for action: String) -> String {
        switch action {
        case "pour": return "drop.fill"
        case "shake": return "waveform"
        case "stir": return "arrow.triangle.2.circlepath"
        case "strain": return "line.3.horizontal.decrease"
        case "garnish": return "leaf.fill"
        default: return "list.bullet"
        }
    }
}

/// Horizontal garnish chip row under the pour card.
struct GarnishChipRowView: View {
    let chips: [GarnishChip]
    var onToggle: ((GarnishChip) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Garnish")
                .font(.caption.weight(.semibold))
                .foregroundStyle(MixCueTheme.muted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if chips.isEmpty {
                        chipLabel(name: "Twist", placed: false)
                        chipLabel(name: "Herb", placed: false)
                        chipLabel(name: "Bitters", placed: false)
                    } else {
                        ForEach(chips, id: \.name) { chip in
                            Button {
                                onToggle?(chip)
                            } label: {
                                chipLabel(name: chip.name, placed: chip.placed)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("GarnishChipRow")
    }

    private func chipLabel(name: String, placed: Bool) -> some View {
        Text(name)
            .font(.system(size: 16, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundStyle(placed ? Color.white : MixCueTheme.ink)
            .background(
                Capsule()
                    .fill(placed ? MixCueTheme.primary : MixCueTheme.secondary)
            )
            .overlay(
                Capsule()
                    .stroke(MixCueTheme.accent, lineWidth: placed ? 0 : 1.5)
            )
    }
}
