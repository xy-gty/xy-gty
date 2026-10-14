import ScoutCueDomain
import SwiftUI

struct SkyArcTimelineView: View {
    let windows: [TimingWindow]
    var selectedId: String?
    var onSelect: (TimingWindow) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sky-arc timing")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ScoutCueTheme.muted)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                ZStack {
                    // Soft arc wash (not black shell)
                    Path { path in
                        path.move(to: CGPoint(x: 8, y: h * 0.85))
                        path.addQuadCurve(
                            to: CGPoint(x: w - 8, y: h * 0.85),
                            control: CGPoint(x: w / 2, y: h * 0.05)
                        )
                    }
                    .stroke(
                        LinearGradient(
                            colors: [ScoutCueTheme.sky, ScoutCueTheme.gold, ScoutCueTheme.rose],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )

                    ForEach(Array(windows.enumerated()), id: \.element.id) { index, window in
                        let t = windows.count <= 1 ? 0.5 : CGFloat(index) / CGFloat(windows.count - 1)
                        let x = 16 + t * (w - 32)
                        let y = arcY(t: t, width: w, height: h)
                        Button {
                            onSelect(window)
                        } label: {
                            VStack(spacing: 2) {
                                Circle()
                                    .fill(window.id == selectedId ? ScoutCueTheme.rose : ScoutCueTheme.indigo)
                                    .frame(width: window.id == selectedId ? 14 : 10, height: window.id == selectedId ? 14 : 10)
                                    .shadow(color: ScoutCueTheme.indigo.opacity(0.25), radius: 3, y: 1)
                                Text(shortLabel(window))
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(ScoutCueTheme.ink)
                                    .lineLimit(1)
                            }
                        }
                        .buttonStyle(.plain)
                        .position(x: x, y: y)
                        .accessibilityLabel(window.label)
                    }
                }
            }
            .frame(height: 88)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(ScoutCueTheme.mist.opacity(0.9))
            )
        }
    }

    private func arcY(t: CGFloat, width: CGFloat, height: CGFloat) -> CGFloat {
        // Approximate quadratic arc y for node placement
        let base = height * 0.85
        let peak = height * 0.18
        let parabola = 4 * t * (1 - t)
        return base - parabola * (base - peak)
    }

    private func shortLabel(_ window: TimingWindow) -> String {
        switch window.kind {
        case "sunrise": return "Rise"
        case "golden": return "Gold"
        case "blue": return "Blue"
        case "moon": return "Moon"
        default: return String(window.label.prefix(4))
        }
    }
}
