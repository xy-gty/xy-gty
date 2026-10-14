import SwiftUI
import AppRuntimeCore

struct NewSceneView: View {
    @EnvironmentObject private var model: AppModel
    @FocusState private var focused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { focused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Name this scene")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CueTheme.ink)
                TextField("e.g. Act II kitchen", text: $model.newSceneTitle)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                Text("You will import your own script pages next. No copyrighted library is included.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        } actions: {
            Button {
                model.createScene()
            } label: {
                Text("Create scene")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(CueTheme.amber)
                    .foregroundStyle(.white)
            }
            .padding()
        }
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("New scene")
    }
}
