import SwiftUI
import CuePartnerDomain

struct TurnReviewView: View {
    @EnvironmentObject private var model: AppModel
    @State private var feedback = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Review partner turn")
                .font(.title2.weight(.bold))
                .foregroundStyle(CueTheme.ink)
            if let turn = model.pendingTurn {
                Text(turn.partnerRole)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(CueTheme.curtain)
                Text(turn.draftText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Text("No pending draft.")
                    .foregroundStyle(.secondary)
            }
            TextField("Optional feedback for next call", text: $feedback)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button(TurnReview.reject) { model.discardPendingTurn() }
                    .buttonStyle(.bordered)
                Spacer()
                Button(TurnReview.confirm) { model.keepPendingTurn(feedback: feedback) }
                    .buttonStyle(.borderedProminent)
                    .tint(CueTheme.amber)
            }
            Spacer()
        }
        .padding()
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("Turn review")
    }
}
