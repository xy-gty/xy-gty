import SwiftUI

/// Horizontal slit-scan finish-bar scrubber — distinct from Onionreel onion-skin / Workrest HIIT bricks.
struct SlitScanScrubber: View {
    @Binding var position: Double
    var isReading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Finish bar scrubber")
                .font(.caption.weight(.semibold))
                .foregroundStyle(HeatbarTheme.muted)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    HeatbarTheme.primary.opacity(0.25),
                                    HeatbarTheme.secondary,
                                    HeatbarTheme.accent.opacity(0.35),
                                    HeatbarTheme.primary.opacity(0.2),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    // Slit-scan hash marks
                    HStack(spacing: 0) {
                        ForEach(0..<24, id: \.self) { i in
                            Rectangle()
                                .fill(i % 2 == 0 ? HeatbarTheme.ink.opacity(0.12) : Color.clear)
                                .frame(width: geo.size.width / 24)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Capsule()
                        .fill(HeatbarTheme.primary)
                        .frame(width: 4, height: geo.size.height)
                        .offset(x: CGFloat(position) * max(geo.size.width - 4, 0))
                        .shadow(color: HeatbarTheme.primary.opacity(0.4), radius: 4, y: 1)

                    if isReading {
                        Capsule()
                            .fill(HeatbarTheme.primary.opacity(0.55))
                            .frame(width: 10, height: 10)
                            .offset(x: CGFloat(position) * max(geo.size.width - 10, 0), y: -geo.size.height / 2 - 8)
                            .accessibilityLabel("Reading lanes")
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let x = min(max(0, value.location.x), geo.size.width)
                            position = Double(x / max(geo.size.width, 1))
                        }
                )
            }
            .frame(height: 72)
            .accessibilityIdentifier("SlitScanScrubber")
        }
    }
}

struct LaneScaleRail: View {
    @Binding var laneMarks: [Int]
    var onToggle: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lane scale rail")
                .font(.caption.weight(.semibold))
                .foregroundStyle(HeatbarTheme.muted)
            HStack(spacing: 6) {
                ForEach(1...8, id: \.self) { lane in
                    let selected = laneMarks.contains(lane)
                    Button {
                        onToggle(lane)
                    } label: {
                        Text("L\(lane)")
                            .font(.caption.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(selected ? HeatbarTheme.primary : HeatbarTheme.secondary)
                            )
                            .foregroundStyle(selected ? Color.white : HeatbarTheme.ink)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(HeatbarTheme.accent.opacity(selected ? 0.9 : 0.35), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("LaneMark-\(lane)")
                }
            }
        }
        .accessibilityIdentifier("LaneScaleRail")
    }
}

struct TimeCalloutChips: View {
    var chips: [String]
    var onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Time callout chips")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HeatbarTheme.muted)
                Spacer()
                Button("Add chip", action: onAdd)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HeatbarTheme.accent)
            }
            if chips.isEmpty {
                Text("No chips yet — add a read time")
                    .font(.caption)
                    .foregroundStyle(HeatbarTheme.muted)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(chips.enumerated()), id: \.offset) { _, chip in
                            Text(chip)
                                .font(.subheadline.monospacedDigit().weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(HeatbarTheme.accent.opacity(0.2))
                                )
                                .overlay(Capsule().stroke(HeatbarTheme.accent, lineWidth: 1))
                                .foregroundStyle(HeatbarTheme.ink)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("TimeCalloutChips")
    }
}
