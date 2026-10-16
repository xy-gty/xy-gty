import SwiftUI

/// Circular tuner dial — optional pitch feedback, not the primary coaching shell.
struct TunerDialView: View {
    let centsOffset: Double
    let frequencyHz: Double

    private var needleDegrees: Double {
        max(min(centsOffset, 50), -50) / 50.0 * 60.0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(CountroomTheme.violet.opacity(0.25), lineWidth: 18)
                .frame(width: 220, height: 220)
            Circle()
                .trim(from: 0.15, to: 0.85)
                .stroke(
                    AngularGradient(
                        colors: [CountroomTheme.violet, CountroomTheme.mint, CountroomTheme.violet],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
                .frame(width: 220, height: 220)

            Capsule()
                .fill(CountroomTheme.ink)
                .frame(width: 4, height: 78)
                .offset(y: -40)
                .rotationEffect(.degrees(needleDegrees))

            VStack(spacing: 4) {
                Text(String(format: "%.1f¢", centsOffset))
                    .font(.title2.monospacedDigit().bold())
                    .foregroundStyle(abs(centsOffset) < 8 ? CountroomTheme.mint : CountroomTheme.violet)
                Text(String(format: "%.1f Hz", frequencyHz))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(CountroomTheme.muted)
            }
        }
        .frame(width: 240, height: 240)
        .accessibilityLabel("Circular tuner dial")
        .accessibilityValue(String(format: "%.0f cents", centsOffset))
    }
}
