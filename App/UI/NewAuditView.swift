import SwiftUI
import AppRuntimeCore

struct NewAuditView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { focused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("New audit")
                    .font(.title2.weight(.bold))
                TextField("Title e.g. Level 3 walkthrough", text: $model.newAuditTitle)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                TextField("Site label / zone", text: $model.newAuditSite)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                Text("After create, open Active punch → Add photos to import walkthrough shots.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        } actions: {
            PrimaryCTA(title: "Create audit", systemImage: "plus.circle.fill") {
                focused = false
                model.createAudit()
                if model.activeAudit != nil {
                    dismiss()
                    model.selectedTab = .active
                }
            }
            .padding()
        }
        .background(SnagTheme.background.ignoresSafeArea())
        .navigationTitle("New audit")
        .navigationBarTitleDisplayMode(.inline)
    }
}
