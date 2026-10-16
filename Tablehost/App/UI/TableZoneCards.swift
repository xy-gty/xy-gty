import SwiftUI

/// Board-game table zone cards — distinct from film-sprocket / night-frame / hex / chip / yarn / solar shells.
struct TableZoneCards: View {
    let zones: [String]
    let selectedIndex: Int
    var onSelect: (Int) -> Void

    private let icons = ["rectangle.stack.fill", "map.fill", "person.3.fill", "cube.fill", "flag.fill", "star.fill"]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Array(zones.enumerated()), id: \.offset) { index, zone in
                Button {
                    onSelect(index)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: icons[index % icons.count])
                                .font(.title3)
                                .foregroundStyle(index == selectedIndex ? TablehostTheme.accent : TablehostTheme.primary)
                            Spacer()
                            if index == selectedIndex {
                                Circle()
                                    .fill(TablehostTheme.accent)
                                    .frame(width: 10, height: 10)
                            }
                        }
                        Text(zone)
                            .font(.headline)
                            .foregroundStyle(TablehostTheme.ink)
                            .multilineTextAlignment(.leading)
                        Text(index == selectedIndex ? "Active zone" : "Tap to focus")
                            .font(.caption)
                            .foregroundStyle(TablehostTheme.muted)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
                    .background(TablehostTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                index == selectedIndex ? TablehostTheme.accent : TablehostTheme.primary.opacity(0.35),
                                lineWidth: index == selectedIndex ? 2.5 : 1
                            )
                    )
                    .shadow(color: TablehostTheme.primary.opacity(0.08), radius: 4, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Table zone \(zone)")
            }
        }
    }
}

struct TableZoneSilhouette: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(["Deck", "Board", "Player A", "Player B"], id: \.self) { label in
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TablehostTheme.primary.opacity(0.22), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(TablehostTheme.card.opacity(0.45))
                    )
                    .frame(height: 72)
                    .overlay(
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(TablehostTheme.muted)
                    )
            }
        }
        .accessibilityHidden(true)
    }
}
