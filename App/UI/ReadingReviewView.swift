import SwiftUI
import BrewCueDomain

struct ReadingReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        List {
            Section {
                Text("Review pour drafts — \(ReadingReviewBar.confirm) / \(ReadingReviewBar.reject) / \(ReadingReviewBar.edit)")
                    .font(.subheadline)
                    .foregroundStyle(BrewCueTheme.muted)
            }
            ForEach(appModel.sessionSteps, id: \.id) { step in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(step.kind) #\(step.pourIndex)")
                        .font(.headline)
                    Text("\(step.targetGrams.map { String(format: "%.0f g", $0) } ?? "—") · \(step.targetSeconds.map { String(format: "%.0f s", $0) } ?? "—")")
                        .font(.subheadline)
                        .foregroundStyle(BrewCueTheme.muted)
                    if appModel.editingStepId == step.id {
                        TextField("Grams", text: $appModel.editGramsDraft)
                            .keyboardType(.decimalPad)
                        TextField("Seconds", text: $appModel.editSecondsDraft)
                            .keyboardType(.decimalPad)
                        Button(ReadingReviewBar.confirm) { appModel.applyEditStep() }
                            .buttonStyle(.borderedProminent)
                            .tint(BrewCueTheme.accent)
                    } else {
                        HStack {
                            Button(ReadingReviewBar.confirm) { appModel.keepStep(step.id) }
                                .buttonStyle(.borderedProminent)
                                .tint(BrewCueTheme.accent)
                            Button(ReadingReviewBar.reject) { appModel.discardStep(step.id) }
                                .buttonStyle(.bordered)
                            Button(ReadingReviewBar.edit) { appModel.beginEditStep(step.id) }
                                .buttonStyle(.bordered)
                        }
                    }
                }
                .listRowBackground(BrewCueTheme.secondary.opacity(0.5))
            }
            Section {
                Button("Keep brew note") { appModel.keepBrewNote() }
                    .accessibilityIdentifier("KeepBrewNote")
                Button("Open funnel") { appModel.push(.funnelTimeline) }
            }
        }
        .scrollContentBackground(.hidden)
        .brewCueScreen()
        .navigationTitle("Review")
        .accessibilityIdentifier("ReadingReview")
    }
}
