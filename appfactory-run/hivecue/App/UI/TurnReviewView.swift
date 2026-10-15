import SwiftUI
import HiveCueDomain

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Turn review")
                    .font(.title2.bold())
                    .foregroundStyle(HiveCueTheme.ink)

                if let turn = appModel.pendingTurn {
                    Text(turn.text)
                        .font(.body)
                        .foregroundStyle(HiveCueTheme.ink)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(HiveCueTheme.card)
                        )
                } else {
                    Text("No pending coach turn.")
                        .foregroundStyle(HiveCueTheme.muted)
                }

                TextField("Optional feedback for next call", text: $appModel.userFeedback, axis: .vertical)
                    .lineLimit(2 ... 4)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(HiveCueTheme.card)
                    )

                HStack(spacing: 12) {
                    Button(TurnReview.confirm) { appModel.keepPendingTurn() }
                        .buttonStyle(.borderedProminent)
                        .tint(HiveCueTheme.accent)
                    Button(TurnReview.reject) { appModel.discardPendingTurn() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .hiveCueScreen()
        .navigationTitle("Review turn")
    }
}
