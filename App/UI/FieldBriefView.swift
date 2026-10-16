import SwiftUI
import GillnoteDomain

struct FieldBriefView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DisclaimerBanner()

            Text("TTS field brief")
                .font(.title2.bold())
                .foregroundStyle(GillnoteTheme.ink)

            if let brief = appModel.sessionBrief {
                Text(brief.scriptText)
                    .font(.body)
                    .foregroundStyle(GillnoteTheme.ink)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(GillnoteTheme.stackSlot)
                    )

                HStack {
                    if appModel.tts.isSpeaking {
                        Image(systemName: "waveform")
                            .foregroundStyle(GillnoteTheme.accent)
                        Text("Speaking…")
                            .foregroundStyle(GillnoteTheme.accent)
                        Spacer()
                        Button("Stop") { appModel.tts.stop() }
                    } else {
                        Button("Play again") { appModel.playFieldBrief() }
                            .buttonStyle(.borderedProminent)
                            .tint(GillnoteTheme.accent)
                    }
                }
            } else {
                Text("Identify a find first to generate a brief.")
                    .foregroundStyle(GillnoteTheme.muted)
            }

            Spacer()
        }
        .padding(16)
        .sporeScreen()
        .navigationTitle("Field brief")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("FieldBrief")
    }
}
