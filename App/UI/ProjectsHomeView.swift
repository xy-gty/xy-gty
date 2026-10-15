import AppRuntimeCore
import SwiftUI
import YarnCueDomain

struct ProjectsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                YarnBallSwatchStrip(hexes: YarnCueTheme.defaultSwatches, title: "Yarn ball color strip")

                Text("YarnCue")
                    .font(.largeTitle.bold())
                    .foregroundStyle(YarnCueTheme.fuchsia)

                Text("Snap yarn & WIP photos, Keep stitch cues, then coach the next row with hands-free TTS.")
                    .font(.body)
                    .foregroundStyle(YarnCueTheme.muted)

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(YarnCueTheme.ink)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(YarnCueTheme.lime.opacity(0.25)))
                }

                if appModel.projects.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No projects yet")
                            .font(.title3.bold())
                            .foregroundStyle(YarnCueTheme.ink)
                        Text("Start with a project shelf, then capture your first WIP.")
                            .foregroundStyle(YarnCueTheme.muted)
                        Button("New project") {
                            appModel.push(.newProject)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(YarnCueTheme.fuchsia)
                        .accessibilityIdentifier("cta-new-project")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 18).fill(YarnCueTheme.card))
                } else {
                    Button("New project") {
                        appModel.push(.newProject)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(YarnCueTheme.fuchsia)

                    ForEach(appModel.projects, id: \.id) { project in
                        Button {
                            appModel.openProject(project)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(project.title)
                                    .font(.headline)
                                    .foregroundStyle(YarnCueTheme.ink)
                                Text("Current row \(project.currentRow)")
                                    .font(.subheadline)
                                    .foregroundStyle(YarnCueTheme.muted)
                                YarnBallSwatchStrip(hexes: project.yarnSwatchHexes, title: "Swatches")
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 16).fill(YarnCueTheme.card))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .yarnCueScreen()
        .navigationTitle("Projects")
    }
}

struct NewProjectView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var titleFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { titleFocused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Project title")
                    .font(.headline)
                    .foregroundStyle(YarnCueTheme.ink)
                TextField("Title", text: $appModel.newProjectTitle)
                    .textFieldStyle(.roundedBorder)
                    .focused($titleFocused)
            }
            .padding(20)
        } actions: {
            Button("Create & capture") {
                appModel.createProject()
            }
            .buttonStyle(.borderedProminent)
            .tint(YarnCueTheme.fuchsia)
            .padding()
        }
        .yarnCueScreen()
        .navigationTitle("New project")
    }
}
