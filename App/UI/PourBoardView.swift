import SwiftUI
import StirboardDomain

struct PourBoardView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let recipe = appModel.sessionRecipe {
                    Text(recipe.title)
                        .font(.title2.bold())
                        .foregroundStyle(StirboardTheme.ink)
                    Text("Base · \(recipe.baseSpirit)")
                        .font(.subheadline)
                        .foregroundStyle(StirboardTheme.muted)
                    if !recipe.substituteNotes.isEmpty {
                        Text(recipe.substituteNotes)
                            .font(.footnote)
                            .foregroundStyle(StirboardTheme.muted)
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
                    .tint(StirboardTheme.accent)
                    .frame(maxWidth: .infinity)
            }
            .padding(16)
        }
        .stirboardScreen()
        .navigationTitle("Pour board")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("PourBoard")
    }
}
