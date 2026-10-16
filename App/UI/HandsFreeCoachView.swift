import SwiftUI
import BightstepDomain

struct HandsFreeCoachView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hands-free coach")
                .font(.title2.bold())
                .foregroundStyle(BightstepTheme.primary)
            if let plan = model.activeHandsFreePlan {
                ForEach(Array(plan.steps.enumerated()), id: \.offset) { index, step in
                    Text(step)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(index == model.handsFreeStepIndex ? BightstepTheme.accent.opacity(0.2) : BightstepTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            Button("Play steps") { model.playCurrentHandsFreeStep() }
                .buttonStyle(BightstepTheme.PrimaryButtonStyle())
            HStack {
                Button(BightstepReviewControls.HandsFreePlayer.pause) { model.pauseHandsFree() }
                    .buttonStyle(BightstepTheme.SecondaryButtonStyle())
                Button(BightstepReviewControls.HandsFreePlayer.next) { model.nextHandsFreeStep() }
                    .buttonStyle(BightstepTheme.SecondaryButtonStyle())
            }
            Spacer()
        }
        .padding(20)
        .background(BightstepTheme.secondary.ignoresSafeArea())
        .navigationTitle("Hands-free")
    }
}
