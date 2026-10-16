import SwiftUI
import AirspanDomain

struct FieldStepsView: View {
    @EnvironmentObject private var model: AppModel

    private var plan: FieldStepPlan? { model.activeFieldPlan }

    var body: some View {
        ScrollView {
            if let plan {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Field steps")
                        .font(.title2.bold())
                        .foregroundStyle(AirspanTheme.ink)
                    ForEach(Array(plan.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .frame(width: 28, height: 28)
                                .background(index == model.fieldStepIndex ? AirspanTheme.accent : AirspanTheme.primary.opacity(0.15))
                                .foregroundStyle(index == model.fieldStepIndex ? Color.white : AirspanTheme.primary)
                                .clipShape(Circle())
                            Text(step)
                                .font(.body)
                                .foregroundStyle(AirspanTheme.ink)
                                .padding(.vertical, 4)
                        }
                        .padding(10)
                        .background(index == model.fieldStepIndex ? AirspanTheme.accent.opacity(0.12) : AirspanTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    controls
                }
                .padding()
            } else {
                ContentUnavailableView("No step plan", systemImage: "list.bullet")
            }
        }
        .background(AirspanTheme.secondary.ignoresSafeArea())
        .navigationTitle("Field steps")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            Button("Play") {
                model.playCurrentFieldStep()
            }
            .buttonStyle(AirspanTheme.PrimaryButtonStyle())

            Button(AirspanReviewControls.FieldStepsPlayer.pause) {
                model.pauseFieldSteps()
            }
            .buttonStyle(AirspanTheme.SecondaryButtonStyle())

            Button(AirspanReviewControls.FieldStepsPlayer.next) {
                model.nextFieldStep()
            }
            .buttonStyle(AirspanTheme.SecondaryButtonStyle())
        }
    }
}
