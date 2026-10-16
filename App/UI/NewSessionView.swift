import SwiftUI

struct NewSessionView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("Framing session") {
                TextField("Title (optional)", text: $appModel.newSessionTitle)
            }
            Section {
                Button("Create & capture") {
                    appModel.createSession()
                }
                .tint(MatteboxTheme.primary)
            } footer: {
                Text("Opens Capture / Import for an on-set still.")
            }
        }
        .scrollContentBackground(.hidden)
        .matteboxScreen()
        .navigationTitle("New session")
    }
}
