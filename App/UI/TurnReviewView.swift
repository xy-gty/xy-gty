import NightCueDomain
import SwiftUI

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review coach turn")
                    .font(.title2.bold())
                    .foregroundStyle(NightCueTheme.ink)

                if let turn = appModel.pendingTurn {
                    Text(turn.text)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(NightCueTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                TextField("Optional feedback for next call", text: $appModel.userFeedback, axis: .vertical)
                    .lineLimit(2 ... 4)
                    .padding(10)
                    .background(NightCueTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                HStack {
                    Button(TurnReview.reject) { appModel.discardPendingTurn() }
                        .buttonStyle(.bordered)
                    Button(TurnReview.confirm) { appModel.keepPendingTurn() }
                        .buttonStyle(.borderedProminent)
                        .tint(NightCueTheme.primary)
                }

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(NightCueTheme.primary)
                }
            }
            .padding(20)
        }
        .nightCueScreen()
        .navigationTitle("Turn review")
        .navigationBarBackButtonHidden(true)
    }
}
