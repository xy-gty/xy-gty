import SwiftUI
import MixCueDomain

struct PourBoardView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let recipe = appModel.sessionRecipe {
                    Text(recipe.title)
                        .font(.title2.bold())
                        .foregroundStyle(MixCueTheme.ink)
                    Text("Base · \(recipe.baseSpirit)")
                        .font(.subheadline)
                        .foregroundStyle(MixCueTheme.muted)
                    if !recipe.substituteNotes.isEmpty {
                        Text(recipe.substituteNotes)
                            .font(.footnote)
                            .foregroundStyle(MixCueTheme.muted)
                    }
                }

                NextPourCardView(
                    step: appModel.currentPourStep,
                    isActive: true,
                    onNext: { appModel.advancePourStep() },
                    onSpeak: { appModel.speakCurrentStep() }
                )

                GarnishChipRowView(
                    chips: appModel.sessionRecipe?.garnishChips ?? [],
                    onToggle: { appModel.toggleGarnish($0) }
                )

                Button("Save Mix") { appModel.saveMix() }
                    .buttonStyle(.borderedProminent)
                    .tint(MixCueTheme.accent)
                    .frame(maxWidth: .infinity)
            }
            .padding(16)
        }
        .mixCueScreen()
        .navigationTitle("Pour board")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("PourBoard")
    }
}
