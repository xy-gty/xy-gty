import SwiftUI

/// Hexagonal brood-frame comb grid — HiveCue signature control (not FormCue chip rail).
struct HexCombGrid: View {
    let labels: [String]
    let selectedIndex: Int
    var onSelect: (Int) -> Void

    private let columns = 4

    var body: some View {
        let cells = labels.isEmpty ? ["F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8"] : labels
        VStack(spacing: 10) {
            Text("Comb grid")
                .font(.caption.weight(.semibold))
                .foregroundStyle(HiveCueTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columns), spacing: 8) {
                ForEach(Array(cells.enumerated()), id: \.offset) { index, label in
                    Button {
                        onSelect(index)
                    } label: {
                        HexCell(label: label, selected: index == selectedIndex)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Frame \(label)")
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(HiveCueTheme.card.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HiveCueTheme.primary.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct HexCell: View {
    let label: String
    let selected: Bool

    var body: some View {
        ZStack {
            HexagonShape()
                .fill(selected ? HiveCueTheme.accent : HiveCueTheme.primary.opacity(0.12))
            HexagonShape()
                .stroke(selected ? HiveCueTheme.accent : HiveCueTheme.primary.opacity(0.45), lineWidth: 1.5)
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(selected ? Color.white : HiveCueTheme.ink)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .padding(.horizontal, 4)
        }
        .frame(height: 54)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w, y: h * 0.25))
        path.addLine(to: CGPoint(x: w, y: h * 0.75))
        path.addLine(to: CGPoint(x: w * 0.5, y: h))
        path.addLine(to: CGPoint(x: 0, y: h * 0.75))
        path.addLine(to: CGPoint(x: 0, y: h * 0.25))
        path.closeSubpath()
        return path
    }
}
