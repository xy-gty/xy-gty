import ScoutCueDomain
import SwiftUI

struct SoftCardStackView: View {
    let cards: [SceneCard]
    var activeId: String?
    var onSelect: (SceneCard) -> Void

    var body: some View {
        ZStack {
            if cards.isEmpty {
                emptyStack
            } else {
                ForEach(Array(cards.prefix(4).enumerated().reversed()), id: \.element.id) { index, card in
                    let offset = CGFloat(index) * 10
                    SoftSceneCard(card: card, highlighted: card.id == activeId)
                        .offset(y: offset)
                        .scaleEffect(1 - CGFloat(index) * 0.03)
                        .zIndex(Double(4 - index))
                        .onTapGesture { onSelect(card) }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
    }

    private var emptyStack: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(ScoutCueTheme.mist)
                .frame(height: 160)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "rectangle.stack")
                            .font(.largeTitle)
                            .foregroundStyle(ScoutCueTheme.indigo.opacity(0.7))
                        Text("Capture or import your first scout")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(ScoutCueTheme.muted)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                )
                .shadow(color: ScoutCueTheme.indigo.opacity(0.12), radius: 12, y: 6)
        }
        .padding(.horizontal, 8)
    }
}

struct SoftSceneCard: View {
    let card: SceneCard
    var highlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(card.placeLabel)
                .font(.title3.bold())
                .foregroundStyle(ScoutCueTheme.ink)
            HStack {
                Label(card.lightQuality, systemImage: "sun.max.fill")
                Spacer()
                Text(card.facingHint)
                    .font(.caption)
            }
            .font(.subheadline)
            .foregroundStyle(ScoutCueTheme.muted)
            Text(card.status.capitalized)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(ScoutCueTheme.rose.opacity(0.2))
                .foregroundStyle(ScoutCueTheme.rose)
                .clipShape(Capsule())
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white)
                .shadow(color: ScoutCueTheme.indigo.opacity(highlighted ? 0.22 : 0.12), radius: highlighted ? 16 : 10, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(highlighted ? ScoutCueTheme.indigo : ScoutCueTheme.indigo.opacity(0.12), lineWidth: highlighted ? 2 : 1)
        )
        .padding(.horizontal, 12)
    }
}
