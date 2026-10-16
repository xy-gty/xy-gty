import SwiftUI
import BloomkettleDomain

struct ReadingReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        List {
            Section {
                Text("Review pour drafts — \(ReadingReviewBar.confirm) / \(ReadingReviewBar.reject) / \(ReadingReviewBar.edit)")
                    .font(.subheadline)
                    .foregroundStyle(BloomkettleTheme.muted)
            }
            ForEach(appModel.sessionSteps, id: \.id) { step in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(step.kind) #\(step.pourIndex)")
                        .font(.headline)
                    Text("\(step.targetGrams.map { String(format: "%.0f g", $0) } ?? "—") · \(step.targetSeconds.map { String(format: "%.0f s", $0) } ?? "—")")
                        .font(.subheadline)
                        .foregroundStyle(BloomkettleTheme.muted)
                    if appModel.editingStepId == step.id {
                        TextField("Grams", text: $appModel.editGramsDraft)
                            .keyboardType(.decimalPad)
                        TextField("Seconds", text: $appModel.editSecondsDraft)
                            .keyboardType(.decimalPad)
                        Button(ReadingReviewBar.confirm) { appModel.applyEditStep() }
                            .buttonStyle(.borderedProminent)
                            .tint(BloomkettleTheme.accent)
                    } else {
                        HStack {
                            Button(ReadingReviewBar.confirm) { appModel.keepStep(step.id) }
                                .buttonStyle(.borderedProminent)
                                .tint(BloomkettleTheme.accent)
                            Button(ReadingReviewBar.reject) { appModel.discardStep(step.id) }
                                .buttonStyle(.bordered)
                            Button(ReadingReviewBar.edit) { appModel.beginEditStep(step.id) }
                                .buttonStyle(.bordered)
                        }
                    }
                }
                .listRowBackground(BloomkettleTheme.secondary.opacity(0.5))
            }
            Section {
                Button("Keep brew note") { appModel.keepBrewNote() }
                    .accessibilityIdentifier("KeepBrewNote")
                Button("Open funnel") { appModel.push(.funnelTimeline) }
            }
        }
        .scrollContentBackground(.hidden)
        .bloomkettleScreen()
        .navigationTitle("Review")
        .accessibilityIdentifier("ReadingReview")
    }
}
