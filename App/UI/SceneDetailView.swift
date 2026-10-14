import SwiftUI
import CuePartnerDomain

struct SceneDetailView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        List {
            if let scene = model.activeScene {
                Section(scene.title) {
                    Text("Roles: \(scene.roles.joined(separator: ", "))")
                    Text("Pages: \(model.activePages.count) · Cues: \(model.activeCues.count)")
                    Text("Ambience: \(AmbienceCatalog.displayName(for: scene.ambienceId))")
                }
            } else {
                Text("No active scene")
            }

            Section("Open") {
                NavigationLink("Partner chat") {
                    PartnerChatView()
                }
                NavigationLink("Cue rehearsal") {
                    CueRehearsalView()
                }
                NavigationLink("Voice note") {
                    VoiceNoteView()
                }
                NavigationLink("Ambience") {
                    AmbiencePickerView()
                }
                Button("Import another page") {
                    model.path = [.importScript]
                    model.persistNavigation()
                }
            }

            Section("Cue lines") {
                if model.activeCues.isEmpty {
                    Text("Import a script page first.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.activeCues, id: \.id) { line in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(line.role)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(CueTheme.curtain)
                            Text(line.text)
                            Text("pause \(line.pauseMilliseconds) ms")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        let ids = indexSet.map { model.activeCues[$0].id }
                        ids.forEach { model.deleteCueLine($0) }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("Scene")
    }
}

struct RehearseHubView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Group {
            if model.activeScene == nil {
                ContentUnavailableView(
                    "Pick a scene",
                    systemImage: "theatermasks",
                    description: Text("Create or open a scene from the Scenes tab.")
                )
            } else {
                SceneDetailView()
            }
        }
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("Rehearse")
    }
}
