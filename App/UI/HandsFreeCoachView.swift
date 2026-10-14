import SwiftUI
import KnotCueDomain

struct HandsFreeCoachView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hands-free coach")
                .font(.title2.bold())
                .foregroundStyle(KnotCueTheme.primary)
            if let plan = model.activeHandsFreePlan {
                ForEach(Array(plan.steps.enumerated()), id: \.offset) { index, step in
                    Text(step)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(index == model.handsFreeStepIndex ? KnotCueTheme.accent.opacity(0.2) : KnotCueTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            Button("Play steps") { model.playCurrentHandsFreeStep() }
                .buttonStyle(KnotCueTheme.PrimaryButtonStyle())
            HStack {
                Button(KnotCueReviewControls.HandsFreePlayer.pause) { model.pauseHandsFree() }
                    .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
                Button(KnotCueReviewControls.HandsFreePlayer.next) { model.nextHandsFreeStep() }
                    .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
            }
            Spacer()
        }
        .padding(20)
        .background(KnotCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Hands-free")
    }
}
