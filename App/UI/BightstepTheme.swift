import SwiftUI
import BightstepDomain

extension BightstepRoute: Hashable {}

enum BightstepTheme {
    // Primary #B45309 · Secondary #FFFBEB · Accent #0EA5E9 · ink #1C1917
    static let primary = Color(red: 180 / 255, green: 83 / 255, blue: 9 / 255)
    static let secondary = Color(red: 255 / 255, green: 251 / 255, blue: 235 / 255)
    static let accent = Color(red: 14 / 255, green: 165 / 255, blue: 233 / 255)
    static let ink = Color(red: 28 / 255, green: 25 / 255, blue: 23 / 255)
    static let muted = Color(red: 120 / 255, green: 113 / 255, blue: 108 / 255)
    static let surface = Color.white
    static let warn = Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255)

    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(accent.opacity(configuration.isPressed ? 0.85 : 1))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(surface.opacity(configuration.isPressed ? 0.7 : 1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(primary.opacity(0.35), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

/// Vertical rope-diameter step carousel motif (required UI uniqueness).
struct RopeDiameterCarousel: View {
    var diameters: [String]
    var selected: String?
    var stages: [KnotStage]
    var onSelectDiameter: (String) -> Void
    var onSelectStage: (KnotStage) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(diameters, id: \.self) { mm in
                        Button(mm) { onSelectDiameter(mm) }
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundStyle(selected == mm ? Color.white : BightstepTheme.ink)
                            .background(selected == mm ? BightstepTheme.accent : BightstepTheme.surface)
                            .clipShape(Capsule())
                    }
                }
            }
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                        Button {
                            onSelectStage(stage)
                        } label: {
                            HStack(alignment: .top, spacing: 14) {
                                ZStack {
                                    Circle()
                                        .stroke(BightstepTheme.primary, lineWidth: 4)
                                        .frame(width: 44, height: 44)
                                    Text("\(index + 1)")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(BightstepTheme.primary)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(stage.stageTags.first ?? "Knot stage")
                                        .font(.headline)
                                        .foregroundStyle(BightstepTheme.ink)
                                    if let d = stage.ropeDiameterMM {
                                        Text("\(Int(d)) mm rope")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(BightstepTheme.accent)
                                    }
                                    if let wrong = stage.wrongHauls.first {
                                        Text(wrong)
                                            .font(.caption)
                                            .foregroundStyle(BightstepTheme.warn)
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(16)
                            .background(BightstepTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(BightstepTheme.primary.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(minHeight: 220)
        }
        .accessibilityLabel("Vertical rope diameter step carousel")
    }
}
