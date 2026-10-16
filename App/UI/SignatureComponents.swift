import SwiftUI
import ZonelightDomain

struct ComplianceBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(ZonelightCompliance.requiredDisclaimers, id: \.self) { line in
                Text(line)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ZonelightTheme.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(ZonelightTheme.accent.opacity(0.45), lineWidth: 1.5)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("ComplianceBanner")
    }
}

/// Zone-system dial — circular zone ring with large zone numeral (not safe-frame / timeline / sun path).
struct ZoneSystemDialView: View {
    var selectedZone: String
    var onSelect: ((String) -> Void)?

    private let zones = ["0", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

    var body: some View {
        VStack(spacing: 10) {
            Text("Zone dial")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ZonelightTheme.muted)
                .textCase(.uppercase)

            ZStack {
                Circle()
                    .stroke(ZonelightTheme.primary.opacity(0.25), lineWidth: 18)
                    .frame(width: 168, height: 168)
                Circle()
                    .trim(from: 0, to: dialProgress)
                    .stroke(ZonelightTheme.accent, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 168, height: 168)
                VStack(spacing: 2) {
                    Text("ZONE")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(ZonelightTheme.muted)
                    Text(selectedZone.isEmpty ? "—" : selectedZone)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(ZonelightTheme.primary)
                        .minimumScaleFactor(0.5)
                }
                .accessibilityIdentifier("ZoneDialNumeral")
            }
            .accessibilityIdentifier("ZoneSystemDial")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(zones, id: \.self) { zone in
                        Button {
                            onSelect?(zone)
                        } label: {
                            Text(zone)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(selectedZone == zone ? .white : ZonelightTheme.ink)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle().fill(selectedZone == zone ? ZonelightTheme.primary : ZonelightTheme.card)
                                )
                                .overlay(Circle().stroke(ZonelightTheme.primary.opacity(0.25), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Zone \(zone)")
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ZonelightTheme.card)
                .shadow(color: ZonelightTheme.primary.opacity(0.08), radius: 8, y: 3)
        )
    }

    private var dialProgress: CGFloat {
        guard let idx = zones.firstIndex(of: selectedZone) else { return 0 }
        return CGFloat(idx) / CGFloat(max(zones.count - 1, 1))
    }
}

/// Oversized EV readout bar — full-width hero EV number.
struct OversizedEVReadoutBar: View {
    var evText: String
    var shimmer: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("EV")
                .font(.title3.weight(.bold))
                .foregroundStyle(ZonelightTheme.accent)
            Text(evText)
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundStyle(ZonelightTheme.primary)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .accessibilityIdentifier("EVReadoutValue")
            Spacer(minLength: 0)
            if shimmer {
                ProgressView()
                    .tint(ZonelightTheme.accent)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [ZonelightTheme.primary.opacity(0.12), ZonelightTheme.secondary, ZonelightTheme.accent.opacity(0.18)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(ZonelightTheme.primary.opacity(0.35), lineWidth: 1.5)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("OversizedEVReadoutBar")
    }
}

/// Spot-meter cross card — crosshair card for subject / gray-card mark.
struct SpotMeterCrossCard: View {
    var crossX: Double
    var crossY: Double
    var zoneHint: String
    var empty: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spot-meter cross")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ZonelightTheme.muted)
                .textCase(.uppercase)

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(ZonelightTheme.secondary)
                // Crosshair
                Rectangle()
                    .fill(ZonelightTheme.primary.opacity(0.55))
                    .frame(width: 2)
                Rectangle()
                    .fill(ZonelightTheme.primary.opacity(0.55))
                    .frame(height: 2)
                Circle()
                    .stroke(ZonelightTheme.accent, lineWidth: 2)
                    .frame(width: 28, height: 28)
                    .offset(
                        x: empty ? 0 : CGFloat((crossX - 0.5) * 120),
                        y: empty ? 0 : CGFloat((crossY - 0.5) * 80)
                    )
                if empty {
                    Text("Mark subject / gray card")
                        .font(.subheadline)
                        .foregroundStyle(ZonelightTheme.muted)
                } else {
                    VStack {
                        Spacer()
                        Text(zoneHint.isEmpty ? "Zone —" : "Hint \(zoneHint)")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(ZonelightTheme.accent.opacity(0.2)))
                            .foregroundStyle(ZonelightTheme.ink)
                            .padding(.bottom, 10)
                    }
                }
            }
            .frame(height: 160)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(ZonelightTheme.primary.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(ZonelightTheme.card)
        )
        .accessibilityIdentifier("SpotMeterCrossCard")
    }
}
