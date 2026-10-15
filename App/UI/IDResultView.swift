import SwiftUI
import WingCueDomain

struct IDResultView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let banner = appModel.statusMessage {
                    StatusBanner(text: banner, isError: appModel.statusIsError)
                }

                if let image = appModel.photoImage(for: appModel.activeSession) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(WingCueTheme.primary, lineWidth: 2)
                        )
                }

                FieldCardStack(candidates: appModel.sessionCandidates, emptyHint: false)

                OversizedFieldMarkChips(marks: appModel.sessionMarks)

                SilhouetteCompareBar(
                    leftKey: appModel.sessionCandidates.first?.silhouetteKey ?? "—",
                    rightKey: appModel.sessionCandidates.dropFirst().first?.silhouetteKey ?? "—",
                    contrastNotes: appModel.sessionLookalike?.contrastNotes ?? ""
                )

                if appModel.identifyBusy {
                    ProgressView("Reading plumage…")
                        .tint(WingCueTheme.primary)
                }

                HStack(spacing: 10) {
                    Button("Identify") { appModel.requestIdentify() }
                        .buttonStyle(.borderedProminent)
                        .tint(WingCueTheme.accent)
                        .disabled(appModel.identifyBusy)

                    Button("Save ID") { appModel.saveID() }
                        .buttonStyle(.borderedProminent)
                        .tint(WingCueTheme.accent)

                    Button("Dismiss") { appModel.dismissID() }
                        .buttonStyle(.bordered)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Edit marks (comma-separated)")
                        .font(.caption)
                        .foregroundStyle(WingCueTheme.muted)
                    TextField("white wing bars, eye ring", text: $appModel.editingMarksText)
                        .textFieldStyle(.roundedBorder)
                    Button("Edit marks") { appModel.applyEditedMarks() }
                        .foregroundStyle(WingCueTheme.primary)
                }

                HStack(spacing: 12) {
                    Button("Clarify lookalikes") {
                        if let id = appModel.activeSessionId {
                            appModel.push(.lookalikeChat(sessionId: id))
                        }
                    }
                    .foregroundStyle(WingCueTheme.primary)

                    Button("Annotate") { appModel.buildOverlayDraft() }
                        .foregroundStyle(WingCueTheme.primary)

                    Button {
                        appModel.speakTip()
                    } label: {
                        Label(appModel.tts.isSpeaking ? "Speaking…" : "Speak tip", systemImage: "speaker.wave.2.fill")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(WingCueTheme.secondary)
                    .clipShape(Capsule())
                }
            }
            .padding(20)
        }
        .wingCueScreen()
        .navigationTitle("ID result")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("IDResultView")
    }
}
