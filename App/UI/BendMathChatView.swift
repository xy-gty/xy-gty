import SwiftUI
import UIKit
import BendCoachDomain
import AppRuntimeCore

struct BendMathChatView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            BendCoachTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text(model.unitBadge)
                        .font(.caption.weight(.bold))
                        .padding(6)
                        .background(BendCoachTheme.surface)
                        .foregroundStyle(BendCoachTheme.cta)
                        .clipShape(Capsule())
                    Spacer()
                    Text(BendCoachIdentity.assistiveDisclaimer)
                        .font(.caption2)
                        .foregroundStyle(BendCoachTheme.warn)
                        .lineLimit(2)
                }
                .padding()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(model.activeQueries) { q in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(q.promptText).font(.subheadline.weight(.semibold))
                                Text(q.responseText).font(.body)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(BendCoachTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(BendCoachTheme.ink)
                        }
                        if model.chatBusy {
                            ProgressView("Reading field marks…")
                                .tint(BendCoachTheme.cta)
                                .foregroundStyle(BendCoachTheme.muted)
                        }
                    }
                    .padding()
                }

                RuntimeForm(dismissFocus: { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }) {
                    TextField("Ask bend math…", text: $model.chatText, axis: .vertical)
                        .lineLimit(2...4)
                        .padding(10)
                        .background(BendCoachTheme.surface)
                        .foregroundStyle(BendCoachTheme.ink)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("chat_field")
                } actions: {
                    HStack {
                        Button {
                            if model.speechHost.isListening {
                                model.stopMicIntoChat()
                            } else {
                                model.startMic()
                            }
                        } label: {
                            Label(model.speechHost.isListening ? "Stop" : "Mic", systemImage: model.speechHost.isListening ? "stop.circle.fill" : "mic.fill")
                        }
                        .accessibilityIdentifier("chat_mic")
                        Spacer()
                        Button("Send") { model.sendChat() }
                            .buttonStyle(.borderedProminent)
                            .tint(BendCoachTheme.cta)
                            .disabled(model.chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.chatBusy)
                            .accessibilityIdentifier("chat_send")
                    }
                    .foregroundStyle(BendCoachTheme.ink)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .frame(height: 140)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Bend math")
        .navigationBarTitleDisplayMode(.inline)
    }
}
