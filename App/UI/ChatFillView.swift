import SwiftUI
import AppRuntimeCore
import SnagCueDomain

struct ChatFillView: View {
    @EnvironmentObject private var model: AppModel
    var initialPunchItemId: String?
    @State private var selectedId: String?
    @FocusState private var focused: Bool

    init(initialPunchItemId: String? = nil) {
        self.initialPunchItemId = initialPunchItemId
    }

    var body: some View {
        RuntimeForm(dismissFocus: { focused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                if let msg = model.statusMessage {
                    StatusBanner(message: msg)
                }
                if let reason = model.aiUnavailableReason, model.fieldPatch == nil {
                    Text(reason)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if model.activePunchItems.isEmpty {
                    Text("Add punch items before chat fill.")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Item", selection: Binding(
                        get: { selectedId ?? model.activePunchItems.first?.id ?? "" },
                        set: { selectedId = $0 }
                    )) {
                        ForEach(model.activePunchItems) { item in
                            Text(item.title).tag(item.id)
                        }
                    }
                    TextField("e.g. assignee is GC not painter", text: $model.chatText, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .focused($focused)
                    Button {
                        focused = false
                        model.transcribeSpeechIntoChat()
                    } label: {
                        Label("Speech to text", systemImage: "mic.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.bordered)
                    .disabled(model.speechBusy || model.chatBusy)
                    if model.speechBusy {
                        ProgressView("Listening for speech…")
                    }
                    if SpeechRecognitionService.isSimulatorLimited {
                        Text("Speech recognition: 真机待测")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if model.chatBusy {
                        ProgressView("Waiting for suggestions…")
                    }
                    if let patch = model.fieldPatch {
                        FieldReviewView(patch: patch)
                    }
                }
            }
            .padding()
        } actions: {
            PrimaryCTA(title: "Send", systemImage: "paperplane.fill") {
                focused = false
                let id = selectedId ?? model.activePunchItems.first?.id
                guard let id else { return }
                model.askAIForFields(punchItemId: id)
            }
            .padding()
            .disabled(model.chatBusy || model.activePunchItems.isEmpty)
        }
        .background(SnagTheme.background.ignoresSafeArea())
        .navigationTitle("Chat fill")
        .onAppear {
            if let initialPunchItemId,
               model.activePunchItems.contains(where: { $0.id == initialPunchItemId }) {
                selectedId = initialPunchItemId
            } else {
                selectedId = model.activePunchItems.first?.id
            }
        }
    }
}
