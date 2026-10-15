import NightCueDomain
import SwiftUI

struct SessionsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("NightCue")
                    .font(.largeTitle.bold())
                    .foregroundStyle(NightCueTheme.primary)

                Text("AI night long-exposure coach — shoot or import test frames, diagnose exposure & noise, then coach on the tripod.")
                    .font(.subheadline)
                    .foregroundStyle(NightCueTheme.muted)

                // Empty-state tripod + rail placeholder (not a bare chat shell)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.viewfinder")
                            .font(.title)
                            .foregroundStyle(NightCueTheme.accent)
                        VStack(alignment: .leading) {
                            Text("Night stand ready")
                                .font(.headline)
                                .foregroundStyle(NightCueTheme.ink)
                            Text("Night-frame rail waits for your first test shot.")
                                .font(.caption)
                                .foregroundStyle(NightCueTheme.muted)
                        }
                    }
                    NightFrameRail(
                        labels: ["N1", "N2", "N3", "N4"],
                        selectedIndex: .constant(0),
                        onSelect: { _ in }
                    )
                    .opacity(0.55)
                }
                .padding(16)
                .background(NightCueTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button {
                    appModel.push(.newSession)
                } label: {
                    Text("New session")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(NightCueTheme.primary)
                .accessibilityIdentifier("cta-new-session")

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(NightCueTheme.primary)
                }

                if appModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "No night sessions yet",
                        systemImage: "moon.zzz",
                        description: Text("Start a session, then capture or import a night test frame.")
                    )
                    .frame(minHeight: 160)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent sessions")
                            .font(.headline)
                            .foregroundStyle(NightCueTheme.ink)
                        ForEach(appModel.sessions, id: \.id) { session in
                            Button {
                                appModel.openSession(session)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.locationLabel)
                                            .font(.headline)
                                            .foregroundStyle(NightCueTheme.ink)
                                        Text(session.sceneGoal)
                                            .font(.caption)
                                            .foregroundStyle(NightCueTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(NightCueTheme.accent)
                                }
                                .padding(14)
                                .background(NightCueTheme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)
        }
        .nightCueScreen()
        .navigationTitle("Sessions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NewSessionView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("Scene") {
                TextField("Location label", text: $appModel.newLocationLabel)
                TextField("Scene goal (optional)", text: $appModel.newSceneGoal)
            }
            Section {
                Button("Create session") {
                    appModel.createSession()
                }
                .tint(NightCueTheme.primary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(NightCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("New session")
    }
}
