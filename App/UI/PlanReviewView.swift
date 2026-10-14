import PitchCueDomain
import SwiftUI

struct PlanReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let turn = appModel.pendingTurn {
                    Text(turn.text)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(PitchCueTheme.softCloud)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Text("Edit steps (one per line: title|seconds|tip)")
                    .font(.subheadline.weight(.semibold))
                TextEditor(text: $appModel.editingStepsText)
                    .frame(minHeight: 160)
                    .padding(8)
                    .background(PitchCueTheme.softCloud)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                HStack(spacing: 12) {
                    Button(CoachingReviewBar.reject) {
                        appModel.discardPlanDraft()
                    }
                    .buttonStyle(.bordered)

                    Button(CoachingReviewBar.edit) {
                        // Editing is inline via TextEditor; Keep applies edits.
                        appModel.statusMessage = "Edit steps above, then Keep."
                    }
                    .buttonStyle(.bordered)

                    Button(CoachingReviewBar.confirm) {
                        appModel.keepPlanDraft()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(PitchCueTheme.violet)
                }
                .accessibilityElement(children: .contain)

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(PitchCueTheme.muted)
                }
            }
            .padding(20)
        }
        .pitchCueScreen()
        .navigationTitle("Plan review")
        .navigationBarTitleDisplayMode(.inline)
    }
}
