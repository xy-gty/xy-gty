import SwiftUI

struct SpeechCaptureView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text(model.speechHost.isListening ? "Listening…" : "Mic ready")
                .font(.title2.bold())
                .foregroundStyle(BightstepTheme.primary)
            Text(model.speechHost.partialTranscript.isEmpty ? "Speak a coach question while both hands hold the rope." : model.speechHost.partialTranscript)
                .multilineTextAlignment(.center)
                .foregroundStyle(BightstepTheme.ink)
            if let err = model.speechHost.lastError {
                Text(err).foregroundStyle(BightstepTheme.warn)
            }
            Button("Use transcript in chat") { model.stopMicAndFillChat() }
                .buttonStyle(BightstepTheme.PrimaryButtonStyle())
            Button("Listen again") {
                Task { await model.speechHost.start() }
            }
            .buttonStyle(BightstepTheme.SecondaryButtonStyle())
            Spacer()
        }
        .padding(20)
        .background(BightstepTheme.secondary.ignoresSafeArea())
        .navigationTitle("Speech")
    }
}
