import SwiftUI
import BrewCueDomain
import AppRuntimeCore

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ComplianceBanner()
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(appModel.sessionTurns, id: \.id) { turn in
                            HStack {
                                if turn.role == "user" { Spacer(minLength: 40) }
                                Text(turn.text)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(turn.role == "user" ? BrewCueTheme.accent.opacity(0.15) : Color.white.opacity(0.9))
                                    )
                                    .foregroundStyle(BrewCueTheme.ink)
                                if turn.role != "user" { Spacer(minLength: 40) }
                            }
                            .id(turn.id)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: appModel.sessionTurns.count) { _, _ in
                    if let last = appModel.sessionTurns.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            RuntimeForm(dismissFocus: { focused = false }) {
                TextField("Ask ratio, sourness, next pour…", text: $appModel.coachQuestion, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($focused)
                    .accessibilityIdentifier("CoachInput")
            } actions: {
                HStack {
                    Button {
                        if appModel.speechService.isListening {
                            appModel.stopSpeechCue()
                        } else {
                            appModel.startSpeechCue()
                        }
                    } label: {
                        Label(appModel.speechService.isListening ? "Stop" : "Speak cue", systemImage: "mic.fill")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("ChatSpeakCue")

                    Button {
                        appModel.sendCoach()
                    } label: {
                        if appModel.coachBusy {
                            ProgressView()
                        } else {
                            Text("Send")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BrewCueTheme.accent)
                    .disabled(appModel.coachBusy)
                    .accessibilityIdentifier("CoachSend")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(BrewCueTheme.secondary.opacity(0.95))
            }
            .frame(height: 140)
        }
        .brewCueScreen()
        .navigationTitle("Coach chat")
        .accessibilityIdentifier("CoachChat")
    }
}
