import WorkrestDomain
import SwiftUI

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Turn review")
                    .font(.title2.bold())
                    .foregroundStyle(WorkrestTheme.ink)

                if let turn = appModel.pendingTurn {
                    Text(turn.text)
                        .foregroundStyle(WorkrestTheme.ink)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14).fill(WorkrestTheme.card))
                } else {
                    Text("No pending coach draft.")
                        .foregroundStyle(WorkrestTheme.muted)
                }

                TextField("Optional feedback for next call", text: $appModel.userFeedback, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)

                HStack(spacing: 12) {
                    Button(TurnReview.confirm) { appModel.keepPendingTurn() }
                        .buttonStyle(.borderedProminent)
                        .tint(WorkrestTheme.primary)
                        .accessibilityIdentifier("cta-keep-turn")
                    Button(TurnReview.reject) { appModel.discardPendingTurn() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .workrestScreen()
        .navigationTitle("Review turn")
    }
}
