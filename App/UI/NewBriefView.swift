import SwiftUI
import DocBriefDomain

struct NewBriefView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var didCreate = false

    var body: some View {
        Form {
            Section("New brief") {
                TextField("Title", text: $model.newBriefTitle)
                    .textInputAutocapitalization(.sentences)
            }
            Section {
                Button("Create brief") {
                    model.createBrief()
                    didCreate = true
                }
                .fontWeight(.semibold)
                .foregroundStyle(DocBriefTheme.amber)
                .disabled(model.newBriefTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            if didCreate {
                Section {
                    NavigationLink("Add photos") {
                        ImportCaptureView()
                    }
                    Button("Done") { dismiss() }
                }
            }
            Section {
                Text(DocBriefIdentity.nonCertificationDisclaimer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(DocBriefTheme.paper.ignoresSafeArea())
        .navigationTitle("New brief")
    }
}
