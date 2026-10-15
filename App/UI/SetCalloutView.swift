import SwiftUI
import LuxCueDomain

struct SetCalloutView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()
                OversizedEVReadoutBar(evText: appModel.evDisplay)

                Text("TTS set callout")
                    .font(.title2.bold())
                    .foregroundStyle(LuxCueTheme.primary)

                if let callout = appModel.activeCallout {
                    Text(callout.scriptText)
                        .font(.body)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14).fill(LuxCueTheme.card))
                    if appModel.tts.isSpeaking {
                        Label("Speaking…", systemImage: "speaker.wave.2.fill")
                            .foregroundStyle(LuxCueTheme.accent)
                    }
                    if let spoken = callout.spokenAt {
                        Text("Spoken at \(spoken.formatted())")
                            .font(.caption)
                            .foregroundStyle(LuxCueTheme.muted)
                    }
                } else {
                    Text("No callout yet.")
                        .foregroundStyle(LuxCueTheme.muted)
                }

                Button("Speak again") { appModel.playSetCallout() }
                    .buttonStyle(.borderedProminent)
                    .tint(LuxCueTheme.accent)
            }
            .padding(20)
        }
        .luxScreen()
        .navigationTitle("Set Callout")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("SetCallout")
    }
}
