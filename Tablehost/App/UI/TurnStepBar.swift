import SwiftUI
import TablehostDomain

/// Horizontal turn step bar — current step highlighted in cue-cyan (#0891B2).
struct TurnStepBar: View {
    let steps: [PhaseStep]
    let currentIndex: Int
    var onSelect: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(displaySteps.enumerated()), id: \.offset) { index, step in
                    if index > 0 {
                        Rectangle()
                            .fill(TablehostTheme.primary.opacity(0.25))
                            .frame(width: 18, height: 2)
                            .padding(.horizontal, 2)
                    }
                    Button {
                        onSelect(index)
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(index == currentIndex ? TablehostTheme.accent : TablehostTheme.card)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                index == currentIndex ? TablehostTheme.accent : TablehostTheme.primary.opacity(0.45),
                                                lineWidth: 2
                                            )
                                    )
                                Text("\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundStyle(index == currentIndex ? .white : TablehostTheme.ink)
                            }
                            Text(step.title)
                                .font(.caption2.weight(index == currentIndex ? .semibold : .regular))
                                .foregroundStyle(index == currentIndex ? TablehostTheme.accent : TablehostTheme.ink)
                                .lineLimit(1)
                                .frame(maxWidth: 88)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Turn step \(step.title)")
                    .accessibilityAddTraits(index == currentIndex ? .isSelected : [])
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(TablehostTheme.card)
                    .shadow(color: TablehostTheme.primary.opacity(0.1), radius: 3, y: 1)
            )
        }
    }

    private var displaySteps: [PhaseStep] {
        if steps.isEmpty {
            return [
                PhaseStep(id: "p1", sessionId: "", order: 1, title: "Setup", hint: "Place board", confirmedAt: Date()),
                PhaseStep(id: "p2", sessionId: "", order: 2, title: "Deal", hint: "Deal hands", confirmedAt: Date()),
                PhaseStep(id: "p3", sessionId: "", order: 3, title: "Turn", hint: "Play actions", confirmedAt: Date()),
                PhaseStep(id: "p4", sessionId: "", order: 4, title: "Score", hint: "Tally points", confirmedAt: Date()),
            ]
        }
        return steps.sorted { $0.order < $1.order }
    }
}
