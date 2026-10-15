import SwiftUI
import CellarCueDomain

/// Dual compliance + 21+ strip — required on every alcohol-advice surface.
struct ComplianceBanner: View {
    var showAgeGate: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(CellarCueCompliance.sommelierCertificationDisclaimer)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CellarCueTheme.primary)
            Text(CellarCueCompliance.investmentAdviceDisclaimer)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CellarCueTheme.primary)
            if showAgeGate {
                Text(CellarCueCompliance.ageGateLabel)
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(CellarCueTheme.accent.opacity(0.15)))
                    .foregroundStyle(CellarCueTheme.accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CellarCueTheme.primary.opacity(0.2), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("ComplianceBanner")
    }
}

/// Signature UI: cellar row/bin grid (not bottle-rail / confidence-stack / field-card).
struct CellarRowBinGridView: View {
    let bins: [CellarBin]
    let bottlesByBin: [String: BottleEntry]
    var selectedBinId: String?
    var onSelect: ((CellarBin) -> Void)?

    private var rows: [[CellarBin]] {
        let grouped = Dictionary(grouping: bins, by: \.row)
        return grouped.keys.sorted().compactMap { grouped[$0]?.sorted { $0.column < $1.column } }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cellar rack")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CellarCueTheme.muted)
                .textCase(.uppercase)

            if bins.isEmpty {
                Text("Empty rack — Shoot or Import to place a bottle.")
                    .font(.subheadline)
                    .foregroundStyle(CellarCueTheme.muted)
                    .padding(.vertical, 12)
            } else {
                ForEach(rows, id: \.first?.row) { rowBins in
                    HStack(spacing: 8) {
                        ForEach(rowBins, id: \.id) { bin in
                            let filled = bottlesByBin[bin.id] != nil
                            let selected = selectedBinId == bin.id
                            Button {
                                onSelect?(bin)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(bin.label)
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(CellarCueTheme.ink)
                                    Text(filled ? "●" : "○")
                                        .font(.title3)
                                        .foregroundStyle(filled ? CellarCueTheme.accent : CellarCueTheme.muted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(filled ? CellarCueTheme.binFilled : CellarCueTheme.binEmpty)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(
                                                    selected ? CellarCueTheme.accent : CellarCueTheme.primary.opacity(0.2),
                                                    lineWidth: selected ? 2 : 1
                                                )
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Bin \(bin.label)\(filled ? ", occupied" : ", empty")")
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("CellarRowBinGrid")
    }
}

/// Large label-OCR hero card.
struct LabelOCRHeroCardView: View {
    let bottle: BottleEntry?
    let ocr: LabelOCRResult?
    var isBusy: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Label OCR")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CellarCueTheme.muted)
                .textCase(.uppercase)

            if isBusy {
                Text("Reading label…")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(CellarCueTheme.primary)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                    .padding(16)
                    .background(heroChrome)
            } else if let bottle {
                VStack(alignment: .leading, spacing: 6) {
                    Text(bottle.producer ?? "Unknown producer")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(CellarCueTheme.ink)
                        .lineLimit(2)
                    HStack(spacing: 12) {
                        Text(bottle.vintage ?? "—")
                            .font(.title3.weight(.semibold))
                        Text(bottle.varietal ?? "—")
                            .font(.title3)
                            .foregroundStyle(CellarCueTheme.muted)
                    }
                    if let region = bottle.region, !region.isEmpty {
                        Text(region)
                            .font(.subheadline)
                            .foregroundStyle(CellarCueTheme.muted)
                    }
                    if let ocr {
                        Text(String(format: "Confidence %.0f%%", ocr.confidence * 100))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CellarCueTheme.accent)
                    }
                    Text("Bin \(bottle.binId) · \(bottle.status)")
                        .font(.caption)
                        .foregroundStyle(CellarCueTheme.muted)
                }
                .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                .padding(16)
                .background(heroChrome)
            } else {
                Text("Large label-OCR hero — capture or import a still")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(CellarCueTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                    .padding(16)
                    .background(heroChrome)
            }
        }
        .accessibilityIdentifier("LabelOCRHeroCard")
    }

    private var heroChrome: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(CellarCueTheme.cardFill)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(CellarCueTheme.primary.opacity(0.25), lineWidth: 1.5)
            )
            .shadow(color: CellarCueTheme.primary.opacity(0.08), radius: 8, y: 3)
    }
}

/// Drinking-window aging timeline (horizontal).
struct DrinkingWindowTimelineView: View {
    let window: DrinkingWindow?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Drinking window")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CellarCueTheme.muted)
                .textCase(.uppercase)

            if let window, !window.timelinePoints.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(window.timelinePoints, id: \.self) { point in
                            let parts = point.split(separator: ":").map(String.init)
                            let label = parts.first ?? point
                            let year = parts.count > 1 ? parts[1] : ""
                            let isOpen = label == window.status || label == "open"
                            VStack(spacing: 4) {
                                Text(label.capitalized)
                                    .font(.caption.weight(.bold))
                                Text(year)
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isOpen ? CellarCueTheme.accent.opacity(0.2) : CellarCueTheme.binEmpty)
                                    .overlay(
                                        Capsule()
                                            .stroke(isOpen ? CellarCueTheme.accent : Color.clear, lineWidth: 2)
                                    )
                            )
                            .foregroundStyle(CellarCueTheme.ink)
                        }
                    }
                }
                Text("Status: \(window.status) · informational only — not investment timing")
                    .font(.caption2)
                    .foregroundStyle(CellarCueTheme.muted)
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(CellarCueTheme.binEmpty)
                    .frame(height: 44)
                    .overlay(
                        Text("Aging timeline empty — Identify a bottle first")
                            .font(.caption)
                            .foregroundStyle(CellarCueTheme.muted)
                    )
            }
        }
        .accessibilityIdentifier("DrinkingWindowTimeline")
    }
}
