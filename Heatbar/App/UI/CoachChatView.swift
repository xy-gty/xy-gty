import SwiftUI

struct CoachChatView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            ComplianceBanner()
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(appModel.heatTurns, id: \.id) { turn in
                            HStack {
                                if turn.role == "user" { Spacer(minLength: 40) }
                                Text(turn.text)
                                    .padding(12)
                                    .background(
                                        turn.role == "user"
                                            ? HeatbarTheme.primary.opacity(0.9)
                                            : HeatbarTheme.secondary
                                    )
                                    .foregroundStyle(turn.role == "user" ? Color.white : HeatbarTheme.ink)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                if turn.role != "user" { Spacer(minLength: 40) }
                            }
                            .id(turn.id)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: appModel.heatTurns.count) { _, _ in
                    if let last = appModel.heatTurns.last?.id {
                        withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
            }

            if appModel.coachBusy {
                ProgressView("Coach thinking…")
                    .tint(HeatbarTheme.primary)
                    .padding(.bottom, 4)
            }

            VStack(spacing: 8) {
                HStack {
                    TextField("Heat order or results…", text: $appModel.coachQuestion, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                    Button {
                        appModel.sendCoach()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(HeatbarTheme.primary)
                    }
                    .disabled(appModel.coachQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("SendCoach")
                }

                HStack {
                    Button {
                        Task {
                            _ = await appModel.speechService.requestAuthorization()
                            _ = await appModel.voiceRecorder.requestMicAccess()
                            if appModel.speechService.isListening {
                                appModel.speechService.stop()
                                appModel.applySpeechToCoach()
                            } else {
                                appModel.speechService.start()
                            }
                        }
                    } label: {
                        Label(
                            appModel.speechService.isListening ? "Stop speak" : "Read aloud",
                            systemImage: appModel.speechService.isListening ? "stop.circle.fill" : "mic.circle.fill"
                        )
                    }
                    .tint(HeatbarTheme.accent)
                    .accessibilityIdentifier("SpeakCue")

                    Spacer()

                    Button("Review reads") { appModel.push(.readingReview) }
                    Button("Finish card") { appModel.buildFinishCardDraft() }
                }
                .font(.caption.weight(.semibold))

                if let err = appModel.speechService.lastError {
                    Text(err).font(.caption2).foregroundStyle(.red)
                }
            }
            .padding(16)
            .background(HeatbarTheme.secondary.opacity(0.7))
        }
        .heatbarScreen()
        .navigationTitle("Coach chat")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("CoachChat")
    }
}
