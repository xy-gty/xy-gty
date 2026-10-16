import AppRuntimeCore
import SwiftUI
import LoopwellDomain

struct ProjectsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                YarnBallSwatchStrip(hexes: LoopwellTheme.defaultSwatches, title: "Yarn ball color strip")

                Text("Loopwell")
                    .font(.largeTitle.bold())
                    .foregroundStyle(LoopwellTheme.fuchsia)

                Text("Snap yarn & WIP photos, Keep stitch lines, then coach the next row with hands-free TTS.")
                    .font(.body)
                    .foregroundStyle(LoopwellTheme.muted)

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(LoopwellTheme.ink)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(LoopwellTheme.lime.opacity(0.25)))
                }

                if appModel.projects.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No projects yet")
                            .font(.title3.bold())
                            .foregroundStyle(LoopwellTheme.ink)
                        Text("Start with a project shelf, then capture your first WIP.")
                            .foregroundStyle(LoopwellTheme.muted)
                        Button("New project") {
                            appModel.push(.newProject)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(LoopwellTheme.fuchsia)
                        .accessibilityIdentifier("cta-new-project")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 18).fill(LoopwellTheme.card))
                } else {
                    Button("New project") {
                        appModel.push(.newProject)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(LoopwellTheme.fuchsia)

                    ForEach(appModel.projects, id: \.id) { project in
                        Button {
                            appModel.openProject(project)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(project.title)
                                    .font(.headline)
                                    .foregroundStyle(LoopwellTheme.ink)
                                Text("Current row \(project.currentRow)")
                                    .font(.subheadline)
                                    .foregroundStyle(LoopwellTheme.muted)
                                YarnBallSwatchStrip(hexes: project.yarnSwatchHexes, title: "Swatches")
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 16).fill(LoopwellTheme.card))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .loopwellScreen()
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
                    .foregroundStyle(LoopwellTheme.ink)
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
            .tint(LoopwellTheme.fuchsia)
            .padding()
        }
        .loopwellScreen()
        .navigationTitle("New project")
    }
}
