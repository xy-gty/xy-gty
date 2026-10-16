import SwiftUI
import FieldmarkDomain

enum FieldmarkTheme {
    static let primary = Color(hex: FieldmarkPalette.primary)
    static let secondary = Color(hex: FieldmarkPalette.secondary)
    static let accent = Color(hex: FieldmarkPalette.accent)
    static let ink = Color(red: 0.08, green: 0.16, blue: 0.15)
    static let muted = Color(red: 0.28, green: 0.38, blue: 0.36)
    static let cardFace = secondary
    static let cardEdge = primary
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
            r = 0.06; g = 0.46; b = 0.43
        }
        self.init(red: r, green: g, blue: b)
    }
}

extension View {
    func fieldmarkScreen() -> some View {
        self.background(FieldmarkTheme.secondary.ignoresSafeArea())
    }
}

/// Signature UI: stacked species field-cards (NOT Hemline mosaic / Mattebox clapper / Sunbrief sky-arc / Tablehost table / Onionreel sprocket).
struct FieldCardStack: View {
    let candidates: [SpeciesCandidate]
    let emptyHint: Bool

    var body: some View {
        ZStack {
            if emptyHint && candidates.isEmpty {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(FieldmarkTheme.cardFace)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(FieldmarkTheme.cardEdge.opacity(0.35), lineWidth: 2)
                        )
                        .shadow(color: FieldmarkTheme.primary.opacity(0.18), radius: 8, y: 4)
                        .frame(height: 140)
                        .offset(y: CGFloat(index) * 14)
                        .opacity(1.0 - Double(index) * 0.18)
                }
                VStack(spacing: 8) {
                    Text("Fieldmark")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(FieldmarkTheme.primary)
                    Text("Stack a bird still to open field cards")
                        .font(.subheadline)
                        .foregroundStyle(FieldmarkTheme.muted)
                }
                .padding(.top, 28)
            } else {
                ForEach(Array(candidates.enumerated()), id: \.element.rank) { index, candidate in
                    FieldCard(candidate: candidate)
                        .offset(y: CGFloat(index) * 18)
                        .zIndex(Double(candidates.count - index))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: emptyHint && candidates.isEmpty ? 200 : CGFloat(max(1, candidates.count)) * 90 + 80)
        .accessibilityIdentifier("FieldCardStack")
    }
}

struct FieldCard: View {
    let candidate: SpeciesCandidate

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(candidate.commonName)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(FieldmarkTheme.ink)
            Text(candidate.scientificName)
                .font(.system(size: 15, weight: .medium, design: .serif))
                .italic()
                .foregroundStyle(FieldmarkTheme.muted)
            HStack {
                Text(String(format: "%.0f%% match", candidate.confidence * 100))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FieldmarkTheme.primary)
                Spacer()
                Text("#\(candidate.rank)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FieldmarkTheme.accent)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(FieldmarkTheme.cardFace)
                .shadow(color: FieldmarkTheme.primary.opacity(0.22), radius: 10, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(FieldmarkTheme.cardEdge, lineWidth: 2.5)
        )
    }
}

/// Oversized field-mark chips (≥22pt) — glanceable in bright field light.
struct OversizedFieldMarkChips: View {
    let marks: [FieldMark]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                if marks.isEmpty {
                    chip(label: "Waiting for marks", emphasized: false, accented: false)
                } else {
                    ForEach(Array(marks.enumerated()), id: \.offset) { _, mark in
                        chip(
                            label: mark.label,
                            emphasized: mark.chipEmphasis,
                            accented: mark.salience >= 0.7
                        )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .accessibilityIdentifier("OversizedFieldMarkChips")
    }

    private func chip(label: String, emphasized: Bool, accented: Bool) -> some View {
        Text(label)
            .font(.system(size: emphasized ? 24 : 22, weight: .bold, design: .rounded))
            .foregroundStyle(accented ? Color.white : FieldmarkTheme.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(accented ? FieldmarkTheme.accent : FieldmarkTheme.cardFace)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(FieldmarkTheme.primary.opacity(accented ? 0 : 0.55), lineWidth: 2)
            )
    }
}

/// Horizontal silhouette comparison bar for lookalikes.
struct SilhouetteCompareBar: View {
    let leftKey: String
    let rightKey: String
    let contrastNotes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                silhouetteCell(key: leftKey, side: "A")
                Rectangle()
                    .fill(FieldmarkTheme.accent)
                    .frame(width: 3)
                    .padding(.vertical, 8)
                silhouetteCell(key: rightKey, side: "B")
            }
            .frame(height: 72)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(FieldmarkTheme.primary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(FieldmarkTheme.primary.opacity(0.35), lineWidth: 1.5)
            )

            if !contrastNotes.isEmpty {
                Text(contrastNotes)
                    .font(.footnote)
                    .foregroundStyle(FieldmarkTheme.muted)
                    .lineLimit(3)
            }
        }
        .accessibilityIdentifier("SilhouetteCompareBar")
    }

    private func silhouetteCell(key: String, side: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "bird.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(FieldmarkTheme.primary)
                .symbolRenderingMode(.hierarchical)
            Text(key.isEmpty ? "—" : key)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(FieldmarkTheme.ink)
                .lineLimit(1)
            Text(side)
                .font(.caption2)
                .foregroundStyle(FieldmarkTheme.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatusBanner: View {
    let text: String
    var isError: Bool = false

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isError ? Color.white : FieldmarkTheme.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isError ? FieldmarkTheme.accent : FieldmarkTheme.primary.opacity(0.12))
            )
    }
}
