import SwiftUI
import RuleCueDomain

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review coach reply")
                    .font(.title2.bold())
                    .foregroundStyle(RuleCueTheme.ink)

                if let turn = appModel.pendingTurn {
                    Text(turn.text)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RuleCueTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Text("No pending reply.")
                        .foregroundStyle(RuleCueTheme.muted)
                }

                TextField("Optional feedback tip to reuse next call", text: $appModel.userFeedback, axis: .vertical)
                    .lineLimit(2 ... 4)
                    .padding(12)
                    .background(RuleCueTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                HStack(spacing: 12) {
                    Button(TurnReview.confirm) { appModel.keepTurn() }
                        .buttonStyle(.borderedProminent)
                        .tint(RuleCueTheme.accent)
                    Button(TurnReview.reject) { appModel.discardTurn() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .ruleCueScreen()
        .navigationTitle("Turn review")
    }
}
