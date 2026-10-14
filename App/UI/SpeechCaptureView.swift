import SwiftUI

struct SpeechCaptureView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: model.speechHost.isListening ? "waveform.circle.fill" : "mic.circle")
                .font(.system(size: 72))
                .foregroundStyle(DuctCueTheme.primary)
                .symbolEffect(.pulse, isActive: model.speechHost.isListening)

            Text(model.speechHost.isListening ? "Listening…" : "Ready to listen")
                .font(.title2.bold())
                .foregroundStyle(DuctCueTheme.ink)

            Text(model.speechHost.partialTranscript.isEmpty ? "Speak airflow numbers for coach chat." : model.speechHost.partialTranscript)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(DuctCueTheme.ink.opacity(0.85))
                .padding(.horizontal)

            if let error = model.speechHost.lastError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            Button("Stop & use transcript") {
                model.stopMicAndFillChat()
            }
            .buttonStyle(DuctCueTheme.PrimaryButtonStyle())
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DuctCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("Speech")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !model.speechHost.isListening {
                Task { await model.speechHost.start() }
            }
        }
        .onDisappear {
            if model.speechHost.isListening {
                model.speechHost.stop()
            }
        }
    }
}
