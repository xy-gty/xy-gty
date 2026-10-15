import SwiftUI

/// Film-sprocket timeline — horizontal frame strip with sprocket-hole decorations.
/// Distinct from NightCue night-frame rail, CuePartner script axis, HiveCue/FormCue/YarnCue/ScoutCue.
struct FilmSprocketTimeline: View {
    let labels: [String]
    @Binding var selectedIndex: Int
    var onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            sprocketRow
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                        Button {
                            selectedIndex = index
                            onSelect(index)
                        } label: {
                            VStack(spacing: 6) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(index == selectedIndex ? StopCueTheme.accent.opacity(0.28) : StopCueTheme.card)
                                        .frame(width: 70, height: 54)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                .stroke(
                                                    index == selectedIndex ? StopCueTheme.accent : StopCueTheme.primary.opacity(0.45),
                                                    lineWidth: index == selectedIndex ? 2.5 : 1.5
                                                )
                                        )
                                    Image(systemName: "film")
                                        .foregroundStyle(index == selectedIndex ? StopCueTheme.accent : StopCueTheme.primary)
                                }
                                Text(label)
                                    .font(.caption2.weight(index == selectedIndex ? .bold : .medium))
                                    .foregroundStyle(StopCueTheme.ink)
                                    .lineLimit(1)
                                    .frame(width: 74)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Frame \(label)")
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(StopCueTheme.primary.opacity(0.08))
            )
            sprocketRow
        }
        .accessibilityIdentifier("film-sprocket-timeline")
    }

    private var sprocketRow: some View {
        HStack(spacing: 10) {
            ForEach(0..<12, id: \.self) { _ in
                Capsule()
                    .fill(StopCueTheme.primary.opacity(0.55))
                    .frame(width: 8, height: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(StopCueTheme.primary.opacity(0.18))
    }
}
