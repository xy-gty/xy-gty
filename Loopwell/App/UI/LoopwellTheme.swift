import SwiftUI

enum LoopwellTheme {
    static let fuchsia = Color(red: 0xA2 / 255, green: 0x1C / 255, blue: 0xAF / 255)
    static let softWash = Color(red: 0xFD / 255, green: 0xF4 / 255, blue: 0xFF / 255)
    static let lime = Color(red: 0x84 / 255, green: 0xCC / 255, blue: 0x16 / 255)
    static let ink = Color(red: 0x3B / 255, green: 0x07 / 255, blue: 0x64 / 255)
    static let card = Color.white
    static let muted = Color(red: 0x6B / 255, green: 0x21 / 255, blue: 0xA8 / 255).opacity(0.72)

    static let defaultSwatches: [String] = [
        "#A21CAF", "#EC4899", "#F472B6", "#84CC16", "#22D3EE", "#FBBF24", "#FB7185",
    ]
}

extension View {
    func loopwellScreen() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LoopwellTheme.softWash.ignoresSafeArea())
    }
}

struct YarnBallSwatchStrip: View {
    let hexes: [String]
    var title: String = "Yarn ball swatches"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(LoopwellTheme.muted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(hexes.enumerated()), id: \.offset) { _, hex in
                        Circle()
                            .fill(Color(hex: hex) ?? LoopwellTheme.fuchsia)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle().strokeBorder(LoopwellTheme.ink.opacity(0.15), lineWidth: 1)
                            )
                            .accessibilityLabel("Yarn swatch \(hex)")
                    }
                }
                .padding(.vertical, 2)
            }
            .accessibilityIdentifier("YarnBallSwatchStrip")
        }
    }
}

struct NextRowStepBand: View {
    let cues: [String]
    let currentIndex: Int
    var onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("下一行 · Next row")
                .font(.caption.weight(.semibold))
                .foregroundStyle(LoopwellTheme.muted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(cues.enumerated()), id: \.offset) { idx, label in
                        Button {
                            onSelect(idx)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Step \(idx + 1)")
                                    .font(.caption2.weight(.bold))
                                Text(label)
                                    .font(.subheadline.weight(.semibold))
                                    .lineLimit(2)
                            }
                            .foregroundStyle(idx == currentIndex ? LoopwellTheme.ink : LoopwellTheme.muted)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .frame(minWidth: 140, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(idx == currentIndex ? LoopwellTheme.lime.opacity(0.35) : LoopwellTheme.card)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(
                                        idx == currentIndex ? LoopwellTheme.lime : LoopwellTheme.fuchsia.opacity(0.25),
                                        lineWidth: idx == currentIndex ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .accessibilityIdentifier("NextRowStepBand")
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
