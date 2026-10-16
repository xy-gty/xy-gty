import SwiftUI
import BroodcheckDomain

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Turn review")
                    .font(.title2.bold())
                    .foregroundStyle(BroodcheckTheme.ink)

                if let turn = appModel.pendingTurn {
                    Text(turn.text)
                        .font(.body)
                        .foregroundStyle(BroodcheckTheme.ink)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(BroodcheckTheme.card)
                        )
                } else {
                    Text("No pending coach turn.")
                        .foregroundStyle(BroodcheckTheme.muted)
                }

                TextField("Optional feedback for next call", text: $appModel.userFeedback, axis: .vertical)
                    .lineLimit(2 ... 4)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(BroodcheckTheme.card)
                    )

                HStack(spacing: 12) {
                    Button(TurnReview.confirm) { appModel.keepPendingTurn() }
                        .buttonStyle(.borderedProminent)
                        .tint(BroodcheckTheme.accent)
                    Button(TurnReview.reject) { appModel.discardPendingTurn() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .broodcheckScreen()
        .navigationTitle("Review turn")
    }
}
