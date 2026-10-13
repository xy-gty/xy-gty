import SwiftUI
import UIKit
import AppRuntimeCore
import DocBriefDomain

struct ChatExtractView: View {
    @EnvironmentObject private var model: AppModel
    @State private var feedback = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ask DocBrief to extract actions and deadlines from this brief.")
                .foregroundStyle(.secondary)

            RuntimeForm(dismissFocus: { UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }) {
                TextField("What should we pull out?", text: $model.chatText, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(8)
                    .background(DocBriefTheme.mist)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } actions: {
                Button("Send") {
                    model.runChatExtract()
                }
                .buttonStyle(.borderedProminent)
                .tint(DocBriefTheme.amber)
                .disabled(model.chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .frame(minHeight: 160)

            if model.chatBusy {
                ProgressView("Extracting…")
            }

            if let draft = model.pendingActionDraft {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Proposed action")
                        .font(.headline)
                    Text(draft.text)
                    if let deadline = draft.deadline {
                        Text(deadline, style: .date)
                            .foregroundStyle(.secondary)
                    }
                    TextField("Optional feedback for next call", text: $feedback)
                    HStack {
                        Button(DocBriefReviewControls.ActionReview.confirm) {
                            model.saveActionDraft(feedback: feedback)
                            feedback = ""
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DocBriefTheme.teal)
                        Button(DocBriefReviewControls.ActionReview.reject) {
                            model.rejectActionDraft(feedback: feedback)
                            feedback = ""
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(DocBriefTheme.mist)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if !model.activeActions.isEmpty {
                Text("Saved actions")
                    .font(.headline)
                ForEach(model.activeActions) { item in
                    VStack(alignment: .leading) {
                        Text(item.text)
                        if !item.feedbackNotes.isEmpty {
                            Text("Feedback: \(item.feedbackNotes.joined(separator: "; "))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(DocBriefTheme.paper.ignoresSafeArea())
        .navigationTitle("Chat extract")
    }
}
