import StopCueDomain
import SwiftUI

struct ProjectsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Group {
            if appModel.projects.isEmpty {
                VStack(spacing: 20) {
                    FilmSprocketTimeline(
                        labels: ["F1", "F2", "F3", "F4"],
                        selectedIndex: .constant(0),
                        onSelect: { _ in }
                    )
                    .frame(height: 120)
                    .opacity(0.55)
                    Text("No projects yet")
                        .font(.title2.bold())
                        .foregroundStyle(StopCueTheme.ink)
                    Text("Start a stop-motion coach project with a film-sprocket timeline and onion-skin overlays.")
                        .font(.subheadline)
                        .foregroundStyle(StopCueTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button {
                        appModel.push(.newProject)
                    } label: {
                        Label("+ New project", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(StopCueTheme.accent)
                }
                .padding()
            } else {
                List {
                    ForEach(appModel.projects, id: \.id) { project in
                        Button {
                            appModel.openProject(project)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(project.title)
                                    .font(.headline)
                                    .foregroundStyle(StopCueTheme.ink)
                                Text("\(Int(project.targetFrameRate)) fps · updated \(project.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundStyle(StopCueTheme.muted)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .stopCueScreen()
        .navigationTitle("StopCue")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.push(.newProject)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(StopCueTheme.accent)
                }
                .accessibilityLabel("New project")
            }
        }
        .overlay(alignment: .bottom) {
            if let msg = appModel.statusMessage {
                Text(msg)
                    .font(.footnote)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
    }
}

struct NewProjectView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("Project") {
                TextField("Title", text: $appModel.newProjectTitle)
                TextField("Target fps", text: $appModel.newFrameRate)
                    .keyboardType(.decimalPad)
            }
            Section {
                Button("Create project") {
                    appModel.createProject()
                }
                .tint(StopCueTheme.primary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(StopCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("New project")
    }
}
