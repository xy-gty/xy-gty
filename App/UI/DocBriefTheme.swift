import SwiftUI

enum DocBriefTheme {
    static let paper = Color(red: 243 / 255, green: 237 / 255, blue: 227 / 255)
    static let ink = Color(red: 28 / 255, green: 36 / 255, blue: 48 / 255)
    static let teal = Color(red: 31 / 255, green: 111 / 255, blue: 107 / 255)
    static let amber = Color(red: 217 / 255, green: 119 / 255, blue: 6 / 255)
    static let mist = Color(red: 232 / 255, green: 226 / 255, blue: 216 / 255)

    static var panel: some View {
        mist.opacity(0.9)
    }
}

struct DocBriefAIStatusBanner: View {
    @EnvironmentObject private var model: AppModel
    var retry: (() -> Void)?

    var body: some View {
        if let reason = model.aiUnavailableReason {
            VStack(alignment: .leading, spacing: 8) {
                Text(reason)
                    .font(.footnote)
                    .foregroundStyle(DocBriefTheme.ink.opacity(0.85))
                if let retry {
                    Button("Retry", action: retry)
                        .font(.footnote.weight(.semibold))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DocBriefTheme.mist)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

struct DocBriefErrorRetryBanner: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        if message.localizedCaseInsensitiveContains("failed") {
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .font(.footnote)
                Button("Retry", action: retry)
                    .font(.footnote.weight(.semibold))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DocBriefTheme.amber.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

struct VoiceSupplementControls: View {
    @EnvironmentObject private var model: AppModel
    let target: VoiceSupplementSession.Target
    let voiceButtonAccessibilityID: String
    var showDueDateToggle: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Voice supplement")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DocBriefTheme.ink.opacity(0.85))

            if model.voiceSession.isListening {
                Button("Stop & draft") {
                    model.stopVoiceSupplementAndDraft(target: target)
                }
                .buttonStyle(.borderedProminent)
                .tint(DocBriefTheme.teal)

                if !model.voiceSession.partialTranscript.isEmpty {
                    Text(model.voiceSession.partialTranscript)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Button("Voice supplement") {
                    model.startVoiceSupplement(target: target)
                }
                .accessibilityIdentifier(voiceButtonAccessibilityID)
                .buttonStyle(.bordered)
                .tint(DocBriefTheme.teal)
            }

            if showDueDateToggle {
                Toggle("Include due date", isOn: $model.voiceDueDateEnabled)
                    .tint(DocBriefTheme.teal)
                if model.voiceDueDateEnabled {
                    DatePicker("Due date", selection: $model.voiceDueDate, displayedComponents: .date)
                        .tint(DocBriefTheme.amber)
                }
            }

            if let draft = model.pendingVoiceDraft, draft.target == target {
                Text(draft.titleText)
                    .font(.body)
                if let due = draft.dueDate {
                    Text(due, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Button("Save") { model.saveVoiceDraft() }
                        .buttonStyle(.borderedProminent)
                        .tint(DocBriefTheme.teal)
                    Button("Not this") { model.rejectVoiceDraft() }
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DocBriefTheme.mist.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
