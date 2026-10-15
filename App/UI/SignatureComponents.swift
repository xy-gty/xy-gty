import SwiftUI
import UIKit
import SporeCueDomain

/// Vertical species-confidence stack — signature UI (not bottle-rail / field-card / mosaic).
struct SpeciesConfidenceStackView: View {
    let candidates: [SpeciesCandidate]
    var emptyHint = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Species confidence")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SporeCueTheme.muted)
                .textCase(.uppercase)

            if candidates.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(0 ..< 2, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(SporeCueTheme.stackSlot)
                            .frame(height: 52)
                            .overlay(
                                HStack {
                                    Text(emptyHint ? "Rank \(idx + 1) · waiting for still" : "—")
                                        .font(.subheadline)
                                        .foregroundStyle(SporeCueTheme.muted)
                                    Spacer()
                                    Text(emptyHint ? "—" : "")
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(SporeCueTheme.primary.opacity(0.35))
                                }
                                .padding(.horizontal, 14)
                            )
                    }
                }
            } else {
                ForEach(candidates, id: \.rank) { candidate in
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(candidate.displayName)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(SporeCueTheme.ink)
                                .lineLimit(2)
                            if let sci = candidate.scientificName, !sci.isEmpty {
                                Text(sci)
                                    .font(.caption)
                                    .italic()
                                    .foregroundStyle(SporeCueTheme.muted)
                            }
                        }
                        Spacer(minLength: 8)
                        Text("\(Int((candidate.confidence * 100).rounded()))%")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(SporeCueTheme.primary)
                            .accessibilityLabel("Confidence \(Int(candidate.confidence * 100)) percent")
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(SporeCueTheme.stackSlot)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        candidate.rank == 1 ? SporeCueTheme.accent : SporeCueTheme.primary.opacity(0.15),
                                        lineWidth: candidate.rank == 1 ? 2 : 1
                                    )
                            )
                    )
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("SpeciesConfidenceStack")
    }
}

/// Oversized gill/pore closeup bar — dominant mid-screen morphology strip.
struct GillPoreCloseupBarView: View {
    let subject: String
    let callouts: [MorphologyCallout]
    var photoPath: String?
    var onAnnotate: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(subjectLabel) closeup")
                    .font(.headline)
                    .foregroundStyle(SporeCueTheme.ink)
                Spacer()
                if let onAnnotate {
                    Button("Annotate", action: onAnnotate)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SporeCueTheme.accent)
                }
            }

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                SporeCueTheme.primary.opacity(0.85),
                                SporeCueTheme.accent.opacity(0.55),
                                SporeCueTheme.barFace,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 168)
                    .overlay {
                        if let photoPath, let ui = UIImage(contentsOfFile: photoPath) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 168)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }

                HStack(spacing: 8) {
                    ForEach(Array(callouts.prefix(3).enumerated()), id: \.offset) { _, callout in
                        Text(callout.label)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(SporeCueTheme.primary.opacity(0.85)))
                    }
                    if callouts.isEmpty {
                        Text("Shoot a gill or pore still to pin morphology")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(8)
                    }
                }
                .padding(12)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(SporeCueTheme.accent, lineWidth: 2.5)
            )
        }
        .accessibilityIdentifier("GillPoreCloseupBar")
    }

    private var subjectLabel: String {
        switch subject.lowercased() {
        case "pore": return "Pore"
        case "cap": return "Cap"
        default: return "Gill / pore"
        }
    }
}

/// Informational edible/warning chip rail — never certification.
struct CautionChipRailView: View {
    let chips: [CautionChip]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Caution chips · informational only")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SporeCueTheme.muted)
                .textCase(.uppercase)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if chips.isEmpty {
                        chipLabel("No chips yet", kind: "unknown")
                    } else {
                        ForEach(Array(chips.enumerated()), id: \.offset) { _, chip in
                            chipLabel(chip.title, kind: chip.kind)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("CautionChipRail")
    }

    private func chipLabel(_ title: String, kind: String) -> some View {
        let tint: Color = {
            switch kind {
            case "toxic_lookalike": return SporeCueTheme.primary
            case "warning_lookalike": return SporeCueTheme.accent
            case "info_edible_look": return SporeCueTheme.primary.opacity(0.75)
            default: return SporeCueTheme.muted
            }
        }()
        return Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(SporeCueTheme.chipFace)
                    .overlay(Capsule().stroke(tint.opacity(0.45), lineWidth: 1))
            )
    }
}
