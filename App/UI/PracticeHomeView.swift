import SwiftUI

struct PracticeHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("PitchCue")
                    .font(.largeTitle.bold())
                    .foregroundStyle(PitchCueTheme.violet)

                Text("AI practice coach — warm-ups, count-ins, and beds. Not a tuner clone.")
                    .font(.subheadline)
                    .foregroundStyle(PitchCueTheme.muted)

                PracticeStripView(
                    steps: appModel.confirmedPlan?.steps ?? ["Import a sheet", "Ask coach", "Keep plan", "Count-in"],
                    currentIndex: appModel.confirmedPlan == nil ? 0 : appModel.currentStepIndex
                ) { index in
                    if appModel.confirmedPlan != nil {
                        appModel.currentStepIndex = index
                    }
                }

                WaveformView(levels: appModel.audioBed.isPlaying ? appModel.audioBed.waveform : Array(repeating: 0.18, count: 48))
                    .frame(height: 56)

                if appModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "No practice yet",
                        systemImage: "music.quarternote.3",
                        description: Text("Start a session, import sheet music, then Keep an AI warm-up plan.")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else if let session = appModel.activeSession {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Active: \(session.title)")
                            .font(.headline)
                        Text(session.instrumentLabel)
                            .font(.caption)
                            .foregroundStyle(PitchCueTheme.muted)
                        if appModel.confirmedPlan != nil {
                            Button("Resume practice floor") {
                                appModel.push(.practiceFloor)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PitchCueTheme.softCloud)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Button {
                    appModel.push(.newSession)
                } label: {
                    Text("New practice")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(PitchCueTheme.violet)
                .accessibilityLabel("New practice")

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(PitchCueTheme.muted)
                }
            }
            .padding(20)
        }
        .pitchCueScreen()
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
    }
}
