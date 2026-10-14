import SwiftUI
import DuctCueDomain

struct FieldStepsView: View {
    @EnvironmentObject private var model: AppModel

    private var plan: FieldStepPlan? { model.activeFieldPlan }

    var body: some View {
        ScrollView {
            if let plan {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Field steps")
                        .font(.title2.bold())
                        .foregroundStyle(DuctCueTheme.ink)
                    ForEach(Array(plan.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .frame(width: 28, height: 28)
                                .background(index == model.fieldStepIndex ? DuctCueTheme.accent : DuctCueTheme.primary.opacity(0.15))
                                .foregroundStyle(index == model.fieldStepIndex ? Color.white : DuctCueTheme.primary)
                                .clipShape(Circle())
                            Text(step)
                                .font(.body)
                                .foregroundStyle(DuctCueTheme.ink)
                                .padding(.vertical, 4)
                        }
                        .padding(10)
                        .background(index == model.fieldStepIndex ? DuctCueTheme.accent.opacity(0.12) : DuctCueTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    controls
                }
                .padding()
            } else {
                ContentUnavailableView("No step plan", systemImage: "list.bullet")
            }
        }
        .background(DuctCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Field steps")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            Button("Play") {
                model.playCurrentFieldStep()
            }
            .buttonStyle(DuctCueTheme.PrimaryButtonStyle())

            Button(DuctCueReviewControls.FieldStepsPlayer.pause) {
                model.pauseFieldSteps()
            }
            .buttonStyle(DuctCueTheme.SecondaryButtonStyle())

            Button(DuctCueReviewControls.FieldStepsPlayer.next) {
                model.nextFieldStep()
            }
            .buttonStyle(DuctCueTheme.SecondaryButtonStyle())
        }
    }
}
