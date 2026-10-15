import SwiftUI

/// Horizontal inspection rail — advance brood frames / next-action hint.
struct InspectionRail: View {
    let steps: [String]
    let currentIndex: Int
    var nextHint: String
    var onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Inspection rail")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(HiveCueTheme.muted)
                Spacer()
                Text(nextHint)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(HiveCueTheme.accent)
                    .lineLimit(1)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        Button {
                            onSelect(index)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Step \(index + 1)")
                                    .font(.caption2)
                                    .foregroundStyle(index == currentIndex ? Color.white.opacity(0.85) : HiveCueTheme.muted)
                                Text(step)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(index == currentIndex ? Color.white : HiveCueTheme.ink)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .frame(width: 132, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(index == currentIndex ? HiveCueTheme.primary : HiveCueTheme.card)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        index == currentIndex ? HiveCueTheme.primary : HiveCueTheme.primary.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Rail step \(step)")
                        .accessibilityAddTraits(index == currentIndex ? .isSelected : [])
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(HiveCueTheme.secondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HiveCueTheme.primary.opacity(0.12), lineWidth: 1)
        )
    }
}
