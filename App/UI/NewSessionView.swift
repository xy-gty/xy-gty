import SwiftUI
import PitchCueDomain

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
                .tint(PitchCueTheme.violet)
            }
        }
        .scrollContentBackground(.hidden)
        .background(PitchCueTheme.lilac)
        .navigationTitle("New session")
        .navigationBarTitleDisplayMode(.inline)
    }
}
