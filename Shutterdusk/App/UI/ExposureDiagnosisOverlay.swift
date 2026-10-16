import SwiftUI

/// Exposure-diagnosis overlay layers — not Broodcheck heat maps / Workrest rest rings / Sunbrief solar shells.
struct ExposureDiagnosisOverlayCanvas: View {
    struct Mark: Identifiable {
        let id: String
        let xNorm: Double
        let yNorm: Double
        let diagnosisValue: Double
        let label: String
    }

    let marks: [Mark]
    var showOverlays: Bool = true

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if showOverlays {
                    ForEach(marks) { mark in
                        let x = CGFloat(mark.xNorm) * geo.size.width
                        let y = CGFloat(mark.yNorm) * geo.size.height
                        VStack(spacing: 2) {
                            Circle()
                                .strokeBorder(color(for: mark), lineWidth: 2)
                                .background(Circle().fill(color(for: mark).opacity(0.22)))
                                .frame(width: 28 + CGFloat(mark.diagnosisValue) * 18, height: 28 + CGFloat(mark.diagnosisValue) * 18)
                            Text(mark.label)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(ShutterduskTheme.card.opacity(0.92))
                                .clipShape(Capsule())
                                .foregroundStyle(ShutterduskTheme.ink)
                        }
                        .position(x: x, y: y)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityIdentifier("exposure-diagnosis-overlays")
    }

    private func color(for mark: Mark) -> Color {
        switch mark.label.lowercased() {
        case "underexposed", "under":
            return ShutterduskTheme.underexposed
        case "noise":
            return ShutterduskTheme.primary
        case "trail":
            return Color(red: 0.45, green: 0.55, blue: 0.95)
        case "highlight", "pass", "ok":
            return ShutterduskTheme.passZone
        default:
            return ShutterduskTheme.accent
        }
    }
}
