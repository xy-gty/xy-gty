import SunbriefDomain
import SwiftUI

struct TurnReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Review coach draft")
                    .font(.title3.bold())
                    .foregroundStyle(SunbriefTheme.ink)

                Text(appModel.pendingTurn?.text ?? "No draft")
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: SunbriefTheme.indigo.opacity(0.1), radius: 8, y: 3)

                HStack(spacing: 12) {
                    Button(TurnReview.reject) {
                        appModel.discardPendingTurn()
                    }
                    .buttonStyle(.bordered)
                    .tint(SunbriefTheme.muted)

                    Button(TurnReview.confirm) {
                        appModel.keepPendingTurn()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SunbriefTheme.indigo)
                }

                Text("Discard writes nothing. Keep stores CoachTurn for the next call.")
                    .font(.caption)
                    .foregroundStyle(SunbriefTheme.muted)
            }
            .padding(20)
        }
        .sunbriefScreen()
        .navigationTitle("Turn review")
        .navigationBarTitleDisplayMode(.inline)
    }
}
