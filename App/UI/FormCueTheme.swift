import SwiftUI

enum FormCueTheme {
    /// #DC2626
    static let primary = Color(red: 0xDC / 255, green: 0x26 / 255, blue: 0x26 / 255)
    /// #FEF2F2
    static let softWash = Color(red: 0xFE / 255, green: 0xF2 / 255, blue: 0xF2 / 255)
    /// #22D3EE
    static let accent = Color(red: 0x22 / 255, green: 0xD3 / 255, blue: 0xEE / 255)
    /// #7F1D1D
    static let ink = Color(red: 0x7F / 255, green: 0x1D / 255, blue: 0x1D / 255)
    static let card = Color.white
    static let muted = Color(red: 0x7F / 255, green: 0x1D / 255, blue: 0x1D / 255).opacity(0.72)
}

extension View {
    func formCueScreen() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FormCueTheme.softWash.ignoresSafeArea())
    }
}

/// Horizontal interval chip rail — FormCue unique UI (hard).
struct IntervalChipRail: View {
    let blocks: [String]
    let currentIndex: Int
    var onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Interval chips")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FormCueTheme.muted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { idx, label in
                        Button {
                            onSelect(idx)
                        } label: {
                            Text(label)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(2)
                                .foregroundStyle(idx == currentIndex ? FormCueTheme.ink : FormCueTheme.muted)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .frame(minWidth: 120, alignment: .leading)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(idx == currentIndex ? FormCueTheme.accent.opacity(0.35) : FormCueTheme.card)
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .strokeBorder(
                                            idx == currentIndex ? FormCueTheme.accent : FormCueTheme.primary.opacity(0.3),
                                            lineWidth: idx == currentIndex ? 2 : 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .accessibilityIdentifier("IntervalChipRail")
        }
    }
}

/// Large rest ring — FormCue unique UI (hard).
struct RestRing: View {
    let phaseLabel: String
    let secondsRemaining: Int
    let totalSeconds: Int
    let isRest: Bool

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(1, max(0, Double(secondsRemaining) / Double(totalSeconds)))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(FormCueTheme.primary.opacity(0.15), lineWidth: 18)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    isRest ? FormCueTheme.accent : FormCueTheme.primary,
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: secondsRemaining)
            VStack(spacing: 4) {
                Text(phaseLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FormCueTheme.muted)
                Text("\(secondsRemaining)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(FormCueTheme.ink)
                    .monospacedDigit()
                Text(isRest ? "REST" : "WORK")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(isRest ? FormCueTheme.accent : FormCueTheme.primary)
            }
        }
        .frame(width: 220, height: 220)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("RestRing")
    }
}

/// Polaroid-style form-correction strip — FormCue unique UI (hard).
struct PolaroidFormStrip: View {
    let titles: [String]
    let selectedIndex: Int?
    var onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Polaroid form strip")
                .font(.caption.weight(.semibold))
                .foregroundStyle(FormCueTheme.muted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Array(titles.enumerated()), id: \.offset) { idx, title in
                        Button {
                            onSelect(idx)
                        } label: {
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(FormCueTheme.softWash)
                                    .frame(width: 96, height: 96)
                                    .overlay(
                                        Image(systemName: "figure.strengthtraining.traditional")
                                            .font(.title)
                                            .foregroundStyle(FormCueTheme.primary)
                                    )
                                Text(title)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(FormCueTheme.ink)
                                    .lineLimit(2)
                                    .frame(width: 100)
                            }
                            .padding(10)
                            .background(FormCueTheme.card)
                            .shadow(color: FormCueTheme.ink.opacity(0.12), radius: 4, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .strokeBorder(
                                        selectedIndex == idx ? FormCueTheme.accent : FormCueTheme.primary.opacity(0.2),
                                        lineWidth: selectedIndex == idx ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .accessibilityIdentifier("PolaroidFormStrip")
        }
    }
}

extension Color {
    init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
