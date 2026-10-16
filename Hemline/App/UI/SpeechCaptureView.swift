import SwiftUI

struct SpeechCaptureView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .fill(HemlineTheme.surface)
                    .frame(width: 120, height: 120)
                Image(systemName: appModel.speechHost.isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(appModel.speechHost.isListening ? HemlineTheme.cta : HemlineTheme.muted)
                    .symbolEffect(.pulse, isActive: appModel.speechHost.isListening)
            }

            HemlineTheme.sectionTitle(
                appModel.speechHost.isListening ? "Listening…" : "Ready to listen"
            )

            Text(appModel.speechHost.partialTranscript.isEmpty ? "Speak your outfit question." : appModel.speechHost.partialTranscript)
                .font(.body)
                .foregroundStyle(HemlineTheme.ink)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            if let error = appModel.speechHost.lastError {
                HemlineTheme.mutedText(error)
                    .padding(.horizontal, 24)
            }

            Spacer()

            Button("Done") {
                appModel.finishSpeechCapture()
            }
            .buttonStyle(CCPrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .hemlineScene()
        .navigationTitle("Speech")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !appModel.speechHost.isListening {
                Task { await appModel.speechHost.start() }
            }
        }
        .onDisappear {
            appModel.speechHost.stop()
        }
    }
}
