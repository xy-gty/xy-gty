import SwiftUI
import YarnCueDomain

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review coach turn")
                    .font(.title2.bold())
                    .foregroundStyle(YarnCueTheme.ink)

                if let turn = appModel.pendingTurn {
                    Text(turn.text)
                        .foregroundStyle(YarnCueTheme.ink)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16).fill(YarnCueTheme.card))
                }

                HStack(spacing: 12) {
                    Button(TurnReview.confirm) { appModel.keepPendingTurn() }
                        .buttonStyle(.borderedProminent)
                        .tint(YarnCueTheme.lime)
                    Button(TurnReview.reject) { appModel.discardPendingTurn() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .yarnCueScreen()
        .navigationTitle("Turn review")
    }
}
