import FrameCueDomain
import SwiftUI

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Turn review")
                .font(.title2.bold())
                .foregroundStyle(FrameCueTheme.ink)
            Text(appModel.pendingTurn?.text ?? "No pending turn")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(FrameCueTheme.card))
            HStack {
                Button(TurnReview.reject) { appModel.discardTurn() }
                    .buttonStyle(.bordered)
                Spacer()
                Button(TurnReview.confirm) { appModel.keepTurn() }
                    .buttonStyle(.borderedProminent)
                    .tint(FrameCueTheme.primary)
            }
            Spacer()
        }
        .padding(20)
        .frameCueScreen()
        .navigationTitle("Review turn")
    }
}
