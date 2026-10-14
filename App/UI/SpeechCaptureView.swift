import SwiftUI

struct SpeechCaptureView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text(model.speechHost.isListening ? "Listening…" : "Mic ready")
                .font(.title2.bold())
                .foregroundStyle(KnotCueTheme.primary)
            Text(model.speechHost.partialTranscript.isEmpty ? "Speak a coach question while both hands hold the rope." : model.speechHost.partialTranscript)
                .multilineTextAlignment(.center)
                .foregroundStyle(KnotCueTheme.ink)
            if let err = model.speechHost.lastError {
                Text(err).foregroundStyle(KnotCueTheme.warn)
            }
            Button("Use transcript in chat") { model.stopMicAndFillChat() }
                .buttonStyle(KnotCueTheme.PrimaryButtonStyle())
            Button("Listen again") {
                Task { await model.speechHost.start() }
            }
            .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
            Spacer()
        }
        .padding(20)
        .background(KnotCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Speech")
    }
}
