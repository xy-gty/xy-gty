import SwiftUI

/// Horizontal night-frame rail — distinct from HiveCue inspection rail / FormCue chip rail / YarnCue yarn strip.
struct NightFrameRail: View {
    let labels: [String]
    @Binding var selectedIndex: Int
    var onSelect: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                    Button {
                        selectedIndex = index
                        onSelect(index)
                    } label: {
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    index == selectedIndex
                                        ? NightCueTheme.accent.opacity(0.35)
                                        : NightCueTheme.primary.opacity(0.12)
                                )
                                .frame(width: 72, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(
                                            index == selectedIndex ? NightCueTheme.accent : NightCueTheme.primary.opacity(0.35),
                                            lineWidth: index == selectedIndex ? 2.5 : 1
                                        )
                                )
                                .overlay(
                                    Image(systemName: "moon.stars.fill")
                                        .foregroundStyle(index == selectedIndex ? NightCueTheme.primary : NightCueTheme.muted)
                                )
                            Text(label)
                                .font(.caption2.weight(index == selectedIndex ? .bold : .medium))
                                .foregroundStyle(NightCueTheme.ink)
                                .lineLimit(1)
                                .frame(width: 76)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Night frame \(label)")
                }
            }
            .padding(.horizontal, 4)
        }
        .accessibilityIdentifier("night-frame-rail")
    }
}
