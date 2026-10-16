import SwiftUI
import AppRuntimeCore
import AirspanDomain

struct CoachChatView: View {
    @EnvironmentObject private var model: AppModel
    @FocusState private var chatFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { chatFocused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                if let reason = model.aiUnavailableReason {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(AirspanTheme.ink.opacity(0.8))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AirspanTheme.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                if let run = model.selectedRun {
                    Text("Context: \(run.sizeTags.joined(separator: ", "))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AirspanTheme.primary)
                }
                messagesList
            }
            .padding()
        } actions: {
            composerBar
        }
        .background(AirspanTheme.secondary.ignoresSafeArea())
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.large)
    }

    private var messagesList: some View {
        LazyVStack(alignment: .leading, spacing: 14) {
            if model.sizingSessions.isEmpty {
                Text("Ask about CFM, friction, or velocity. Formula cites appear with each answer.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(model.sizingSessions) { session in
                sessionBlock(session)
            }
        }
    }

    private func sessionBlock(_ session: SizingSession) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("You")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AirspanTheme.primary)
                Spacer()
                Text(session.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(session.promptText)
                .font(.body)
                .foregroundStyle(AirspanTheme.ink)

            Text("Coach")
                .font(.caption.weight(.bold))
                .foregroundStyle(AirspanTheme.accent)
            Text(session.responseText)
                .font(.body)
                .foregroundStyle(AirspanTheme.ink)

            if !session.citedFormulas.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Formula cites")
                        .font(.caption.weight(.semibold))
                    ForEach(session.citedFormulas, id: \.self) { formula in
                        Text(formula)
                            .font(.caption)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AirspanTheme.secondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AirspanTheme.primary.opacity(0.25), lineWidth: 1)
                            )
                    }
                }
            }

            if session.includesSizingDisclaimer {
                Text(AirspanIdentity.sizingFormulaDisclaimer)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(AirspanTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var composerBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                TextField("CFM, friction, velocity…", text: $model.chatText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .focused($chatFocused)
                Button {
                    model.startMicIntoChat()
                } label: {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(AirspanTheme.primary)
                        .padding(10)
                        .background(AirspanTheme.secondary)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Microphone")
            }
            HStack(spacing: 12) {
                Button("Make size diagram") {
                    model.makeSizeDiagram()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(AirspanTheme.primary)

                Spacer()

                if model.chatBusy {
                    ProgressView()
                }
                Button("Send") {
                    model.sendCoachChatLocalDemoIfNeeded()
                }
                .font(.headline)
                .foregroundStyle(AirspanTheme.primary)
                .disabled(model.chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.chatBusy)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
