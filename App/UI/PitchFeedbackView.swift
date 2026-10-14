import SwiftUI

struct PitchFeedbackView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Optional mic pitch feedback")
                .font(.headline)
            Text("Coaching aid only — not a professional tuner replacement.")
                .font(.footnote)
                .foregroundStyle(PitchCueTheme.muted)
                .multilineTextAlignment(.center)

            TunerDialView(
                centsOffset: appModel.pitchDetector.centsOffset,
                frequencyHz: appModel.pitchDetector.frequencyHz
            )

            Button(appModel.pitchDetector.isListening ? "Stop listening" : "Start listening") {
                if appModel.pitchDetector.isListening {
                    appModel.stopPitchCheckAndSample()
                    appModel.statusMessage = "Pitch sample saved to session."
                } else {
                    appModel.pitchDetector.start()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(PitchCueTheme.violet)
            .accessibilityLabel("Start listening")

            if let msg = appModel.pitchDetector.statusMessage {
                Text(msg)
                    .font(.footnote)
                    .foregroundStyle(PitchCueTheme.muted)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(24)
        .pitchCueScreen()
        .navigationTitle("Pitch feedback")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            appModel.stopPitchCheckAndSample()
        }
    }
}
