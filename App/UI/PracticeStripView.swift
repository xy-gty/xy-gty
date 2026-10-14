import SwiftUI

/// Horizontal practice strip — not a CuePartner vertical script timeline.
struct PracticeStripView: View {
    let steps: [String]
    let currentIndex: Int
    var onSelect: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, raw in
                    let parsed = AppModel.parseStep(raw)
                    Button {
                        onSelect(index)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Step \(index + 1)")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(index == currentIndex ? PitchCueTheme.mint : PitchCueTheme.muted)
                            Text(parsed.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(PitchCueTheme.ink)
                                .lineLimit(2)
                                .frame(width: 120, alignment: .leading)
                        }
                        .padding(12)
                        .background(index == currentIndex ? PitchCueTheme.violet.opacity(0.12) : PitchCueTheme.softCloud)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(index == currentIndex ? PitchCueTheme.violet : Color.clear, lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .accessibilityLabel("Practice strip")
    }
}

struct WaveformView: View {
    let levels: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center, spacing: 2) {
                ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                    Capsule()
                        .fill(PitchCueTheme.mint)
                        .frame(width: max((geo.size.width / CGFloat(max(levels.count, 1))) - 2, 2),
                               height: max(geo.size.height * level, 4))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(8)
        .background(PitchCueTheme.softCloud)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityLabel("Continuous audio waveform")
    }
}
