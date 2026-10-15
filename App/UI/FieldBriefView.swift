import SwiftUI
import SporeCueDomain

struct FieldBriefView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DisclaimerBanner()

            Text("TTS field brief")
                .font(.title2.bold())
                .foregroundStyle(SporeCueTheme.ink)

            if let brief = appModel.sessionBrief {
                Text(brief.scriptText)
                    .font(.body)
                    .foregroundStyle(SporeCueTheme.ink)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SporeCueTheme.stackSlot)
                    )

                HStack {
                    if appModel.tts.isSpeaking {
                        Image(systemName: "waveform")
                            .foregroundStyle(SporeCueTheme.accent)
                        Text("Speaking…")
                            .foregroundStyle(SporeCueTheme.accent)
                        Spacer()
                        Button("Stop") { appModel.tts.stop() }
                    } else {
                        Button("Play again") { appModel.playFieldBrief() }
                            .buttonStyle(.borderedProminent)
                            .tint(SporeCueTheme.accent)
                    }
                }
            } else {
                Text("Identify a find first to generate a brief.")
                    .foregroundStyle(SporeCueTheme.muted)
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
