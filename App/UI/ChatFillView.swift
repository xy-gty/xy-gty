import SwiftUI
import AppRuntimeCore
import SnagCueDomain

struct ChatFillView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedId: String?
    @FocusState private var focused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { focused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                if let msg = model.statusMessage {
                    StatusBanner(message: msg)
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
                    if model.chatBusy { ProgressView() }
                    if let patch = model.fieldPatch {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggested fields").font(.headline)
                            Text(patch.rationale).font(.footnote).foregroundStyle(.secondary)
                            Text("Location: \(patch.location ?? "—")")
                            Text("Severity: \(patch.severity ?? "—")")
                            Text("Assignee: \(patch.assignee ?? "—")")
                            Text("Due: \(patch.dueDate ?? "—")")
                            Text("Notes: \(patch.notes ?? "—")")
                            HStack {
                                Button(PunchFieldReview.confirm) { model.saveFieldPatch() }
                                    .buttonStyle(.borderedProminent)
                                Button(PunchFieldReview.reject) { model.rejectFieldPatch() }
                            }
                        }
                        .padding()
                        .background(SnagTheme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
        .onAppear { selectedId = model.activePunchItems.first?.id }
    }
}
