import SwiftUI

struct ShelfCardView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ComplianceRibbon()
                Text("Annotated shelf card")
                    .font(.title2.bold())
                    .foregroundStyle(SpinewellTheme.ink)
                if let card = appModel.activeShelfCard {
                    ForEach(card.callouts, id: \.self) { line in
                        Text(line)
                            .font(.body.weight(.medium))
                            .foregroundStyle(SpinewellTheme.ink)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(SpinewellTheme.cardFace)
                            )
                    }
                    Button("Speak Find") { appModel.speakFindCallout() }
                        .buttonStyle(.borderedProminent)
                        .tint(SpinewellTheme.accent)
                } else {
                    Text("No card yet.")
                        .foregroundStyle(SpinewellTheme.muted)
                    Button("Build card") { appModel.buildShelfCard() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(16)
        }
        .spinewellScreen()
        .navigationTitle("Shelf Card")
        .accessibilityIdentifier("ShelfCard")
    }
}

struct FindCalloutView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ComplianceRibbon()
                Text("Find-my-book callout")
                    .font(.title2.bold())
                    .foregroundStyle(SpinewellTheme.ink)
                if let callout = appModel.state.findCallouts.first(where: { $0.sessionId == appModel.activeSessionId }) {
                    Text(callout.scriptText)
                        .font(.body)
                        .foregroundStyle(SpinewellTheme.ink)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(SpinewellTheme.cardFace)
                        )
                    Button("Speak again") { appModel.speakFindCallout() }
                        .buttonStyle(.borderedProminent)
                        .tint(SpinewellTheme.primary)
                } else {
                    Button("Generate & speak") { appModel.speakFindCallout() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(16)
        }
        .spinewellScreen()
        .navigationTitle("Find")
        .accessibilityIdentifier("FindCallout")
    }
}

struct VoiceNoteView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Hands-free shelf note")
                .font(.title2.bold())
                .foregroundStyle(SpinewellTheme.ink)
            Text("Microphone extends the shelf coach while you hold books — location / TBR notes.")
                .font(.subheadline)
                .foregroundStyle(SpinewellTheme.muted)
                .multilineTextAlignment(.center)
            if appModel.voiceRecorder.isRecording {
                Button("Stop & save") { appModel.stopVoiceNote() }
                    .buttonStyle(.borderedProminent)
                    .tint(SpinewellTheme.accent)
            } else {
                Button("Start recording") { appModel.startVoiceNote() }
                    .buttonStyle(.borderedProminent)
                    .tint(SpinewellTheme.primary)
            }
            if let err = appModel.voiceRecorder.lastError {
                Text(err).foregroundStyle(.red)
            }
            Spacer()
        }
        .padding(24)
        .spinewellScreen()
        .accessibilityIdentifier("VoiceNote")
    }
}
