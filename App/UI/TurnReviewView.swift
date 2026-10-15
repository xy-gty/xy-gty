import StopCueDomain
import SwiftUI

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Review coach turn")
                .font(.title3.bold())
                .foregroundStyle(StopCueTheme.ink)
            Text(appModel.pendingTurn?.text ?? "No pending turn")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(StopCueTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            TextField("Feedback for next call", text: $appModel.userFeedback, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button(TurnReview.reject) { appModel.discardPendingTurn() }
                    .buttonStyle(.bordered)
                Button(TurnReview.confirm) { appModel.keepPendingTurn() }
                    .buttonStyle(.borderedProminent)
                    .tint(StopCueTheme.primary)
            }
            Spacer()
        }
        .padding(20)
        .stopCueScreen()
        .navigationTitle("Turn review")
    }
}
