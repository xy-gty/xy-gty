import SwiftUI
import FolioCueDomain

enum FolioCueTheme {
    static let primary = Color(hex: FolioCuePalette.primary)
    static let secondary = Color(hex: FolioCuePalette.secondary)
    static let accent = Color(hex: FolioCuePalette.accent)
    static let ink = Color(hex: "#064E3B")
    static let muted = Color(hex: "#047857").opacity(0.72)
    static let cardFace = Color.white.opacity(0.92)
    static let railWood = Color(hex: "#0F766E")
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
            (r, g, b) = (6, 95, 70)
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

struct FolioCueScreenModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    FolioCueTheme.secondary,
                    Color(hex: "#ECFDF5"),
                    FolioCueTheme.secondary.opacity(0.85),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func folioCueScreen() -> some View {
        modifier(FolioCueScreenModifier())
    }
}

struct StatusBanner: View {
    let text: String
    var isError = false

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isError ? Color.white : FolioCueTheme.ink)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isError ? FolioCueTheme.accent.opacity(0.9) : FolioCueTheme.cardFace)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(FolioCueTheme.primary.opacity(0.25), lineWidth: 1)
            )
    }
}

struct ComplianceRibbon: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(FolioCueCompliance.requiredDisclaimers, id: \.self) { line in
                Text(line)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(FolioCueTheme.secondary)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(FolioCueTheme.primary)
        )
        .accessibilityIdentifier("ComplianceRibbon")
    }
}

/// Horizontal spine-rail — distinct from bottle-rail / bin-grid twins.
struct SpineRailView: View {
    let items: [SpineRailItem]
    var onSelect: ((SpineRailItem) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spine rail")
                .font(.caption.weight(.bold))
                .foregroundStyle(FolioCueTheme.muted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    if items.isEmpty {
                        ForEach(0 ..< 4, id: \.self) { idx in
                            emptySpine(height: CGFloat(90 + idx * 12))
                        }
                    } else {
                        ForEach(items.sorted(by: { $0.position < $1.position }), id: \.bookId) { item in
                            Button {
                                onSelect?(item)
                            } label: {
                                spine(for: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(FolioCueTheme.railWood.opacity(0.18))
            )
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(FolioCueTheme.primary)
                    .frame(height: 6)
                    .clipShape(Capsule())
                    .padding(.horizontal, 8)
                    .padding(.bottom, 4)
            }
        }
        .accessibilityIdentifier("SpineRail")
    }

    private func spine(for item: SpineRailItem) -> some View {
        let height = CGFloat(96 + (item.position % 5) * 10)
        return Text(item.spineLabel)
            .font(.system(size: 11, weight: .bold, design: .serif))
            .foregroundStyle(FolioCueTheme.secondary)
            .rotationEffect(.degrees(-90))
            .frame(width: height, height: 28)
            .frame(width: 28, height: height)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [FolioCueTheme.primary, FolioCueTheme.accent.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .accessibilityLabel(item.spineLabel)
    }

    private func emptySpine(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .strokeBorder(FolioCueTheme.primary.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            .frame(width: 28, height: height)
    }
}

/// Large cover OCR card — hero identification surface.
struct CoverOCRCardView: View {
    let title: String
    let author: String
    let rationale: String
    let confidence: Double?
    let pending: Bool
    var onIdentify: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(pending ? "Cover OCR card" : "Identified cover")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FolioCueTheme.accent)
                Spacer()
                if let confidence {
                    Text("\(Int(confidence * 100))%")
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(FolioCueTheme.primary)
                }
            }
            Text(title.isEmpty ? "Awaiting cover / spine still" : title)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(FolioCueTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(author.isEmpty ? "Snap or import to fill this card" : author)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(FolioCueTheme.muted)
            if !rationale.isEmpty {
                Text(rationale)
                    .font(.footnote)
                    .foregroundStyle(FolioCueTheme.ink.opacity(0.8))
            }
            if let onIdentify {
                Button("Identify Book", action: onIdentify)
                    .buttonStyle(.borderedProminent)
                    .tint(FolioCueTheme.accent)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(FolioCueTheme.cardFace)
                .shadow(color: FolioCueTheme.primary.opacity(0.12), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(FolioCueTheme.accent.opacity(0.45), lineWidth: 2)
        )
        .accessibilityIdentifier("CoverOCRCard")
    }
}

/// Reading progress bar under the cover card.
struct ReadingProgressBarView: View {
    let progress: ReadingProgress?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Reading progress")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(FolioCueTheme.muted)
                Spacer()
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FolioCueTheme.primary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(FolioCueTheme.primary.opacity(0.15))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [FolioCueTheme.primary, FolioCueTheme.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * CGFloat(percent) / 100))
                }
            }
            .frame(height: 12)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(FolioCueTheme.cardFace)
        )
        .accessibilityIdentifier("ReadingProgressBar")
    }

    private var percent: Int {
        min(100, max(0, progress?.percent ?? 0))
    }

    private var label: String {
        guard let progress else { return "TBR · 0%" }
        return "\(progress.state.uppercased()) · \(progress.percent)%"
    }
}
