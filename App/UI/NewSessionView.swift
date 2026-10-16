import SwiftUI
import CountroomDomain

struct NewSessionView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var title = "Practice session"

    var body: some View {
        Form {
            Section("Session") {
                TextField("Title", text: $title)
                TextField("Instrument", text: $appModel.instrumentLabel)
                    .textInputAutocapitalization(.words)
            }
            Section {
                Button("Continue to Capture / Import") {
                    appModel.createSession(title: title.isEmpty ? "Practice session" : title)
                }
                .tint(CountroomTheme.violet)
            }
        }
        .scrollContentBackground(.hidden)
        .background(CountroomTheme.lilac)
        .navigationTitle("New session")
        .navigationBarTitleDisplayMode(.inline)
    }
}
