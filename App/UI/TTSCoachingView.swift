import SwiftUI
import BendCoachDomain

struct TTSCoachingView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            BendCoachTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("Field coaching")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(BendCoachTheme.ink)

                if model.activeSteps.isEmpty {
                    Text("Tap Start coaching on Job detail to build steps.")
                        .foregroundStyle(BendCoachTheme.muted)
                    Button("Start coaching") { model.prepareCoaching() }
                        .buttonStyle(.borderedProminent)
                        .tint(BendCoachTheme.cta)
                } else {
                    List {
                        ForEach(Array(model.activeSteps.enumerated()), id: \.element.id) { idx, step in
                            HStack(alignment: .top) {
                                Circle()
                                    .fill(idx == model.coachingIndex ? BendCoachTheme.cta : BendCoachTheme.muted)
                                    .frame(width: 10, height: 10)
                                    .padding(.top, 6)
                                Text(step.utterance)
                                    .foregroundStyle(BendCoachTheme.ink)
                            }
                            .listRowBackground(idx == model.coachingIndex ? BendCoachTheme.surface.opacity(0.9) : BendCoachTheme.surface.opacity(0.5))
                        }
                    }
                    .scrollContentBackground(.hidden)

                    HStack {
                        Button(BendCoachReviewControls.CoachingPlayer.pause) { model.pauseCoaching() }
                        Button("Replay") { model.playCurrentStep() }
                        Spacer()
                        Button(BendCoachReviewControls.CoachingPlayer.next) { model.nextCoachingStep() }
                            .buttonStyle(.borderedProminent)
                            .tint(BendCoachTheme.cta)
                    }
                    .foregroundStyle(BendCoachTheme.ink)
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Coaching")
        .onAppear {
            if model.activeSteps.isEmpty == false && model.coachingIndex == 0 {
                // leave idle until Play
            }
        }
    }
}
