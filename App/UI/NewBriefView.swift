import SwiftUI
import DocBriefDomain

struct NewBriefView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("New brief") {
                TextField("Title", text: $model.newBriefTitle)
                    .textInputAutocapitalization(.sentences)
            }
            Section {
                Button("Create brief") {
                    model.createBrief()
                    dismiss()
                }
                .fontWeight(.semibold)
                .foregroundStyle(DocBriefTheme.amber)
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
