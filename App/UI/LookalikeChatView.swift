import AppRuntimeCore
import SwiftUI
import UIKit
import FieldmarkDomain

struct LookalikeChatView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var coachFocused: Bool

    var body: some View {
        RuntimeForm(
            dismissFocus: {
                coachFocused = false
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            },
            content: {
                VStack(alignment: .leading, spacing: 12) {
                    OversizedFieldMarkChips(marks: appModel.sessionMarks)
                    FieldCardStack(candidates: appModel.sessionCandidates, emptyHint: false)
                        .frame(maxHeight: 160)
                    SilhouetteCompareBar(
                        leftKey: appModel.sessionCandidates.first?.silhouetteKey ?? "—",
                        rightKey: appModel.sessionCandidates.dropFirst().first?.silhouetteKey ?? "—",
                        contrastNotes: appModel.sessionLookalike?.contrastNotes ?? ""
                    )

                    ForEach(Array(appModel.sessionTurns.enumerated()), id: \.offset) { _, turn in
                        HStack {
                            if turn.role == "coach" { Spacer(minLength: 40) }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(turn.role == "coach" ? "Coach" : "You")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(FieldmarkTheme.muted)
                                Text(turn.text)
                                    .font(.body)
                                    .foregroundStyle(FieldmarkTheme.ink)
                                if turn.sttSource == "speech" {
                                    Text("via speech")
                                        .font(.caption2)
                                        .foregroundStyle(FieldmarkTheme.accent)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(turn.role == "coach"
                                          ? FieldmarkTheme.primary.opacity(0.12)
                                          : FieldmarkTheme.cardFace)
                            )
                            if turn.role == "user" { Spacer(minLength: 40) }
                        }
                    }

                    if appModel.coachBusy {
                        ProgressView("Coach thinking…")
                            .tint(FieldmarkTheme.primary)
                    }
                }
                .padding(16)
            },
            actions: {
                HStack(spacing: 8) {
                    TextField("which warbler has the white wing bars", text: $appModel.coachQuestion, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                        .focused($coachFocused)
                    Button {
                        if appModel.speechService.isListening {
                            appModel.finishSpeechQuestion()
                        } else {
                            appModel.startSpeechQuestion()
                        }
                    } label: {
                        Image(systemName: appModel.speechService.isListening ? "stop.circle.fill" : "waveform.circle.fill")
                            .font(.title2)
                            .foregroundStyle(FieldmarkTheme.accent)
                    }
                    .accessibilityLabel("Speech question")

                    Button("Send") {
                        appModel.sendCoachQuestion()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FieldmarkTheme.primary)
                }
                .padding(12)
                .background(FieldmarkTheme.cardFace)
            }
        )
        .fieldmarkScreen()
        .navigationTitle("Lookalike coach")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("LookalikeChatView")
    }
}
