import SwiftUI
import TablehostDomain

struct SessionsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tablehost")
                    .font(.largeTitle.bold())
                    .foregroundStyle(TablehostTheme.primary)

                Text("Board-game rules & setup coach")
                    .font(.title3)
                    .foregroundStyle(TablehostTheme.ink)

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(TablehostTheme.accent)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(TablehostTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                if appModel.sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("No sessions yet")
                            .font(.title2.bold())
                            .foregroundStyle(TablehostTheme.ink)
                        Text("Snap a rulebook or table photo, keep reviewed zones, and walk the turn step bar while you set up.")
                            .foregroundStyle(TablehostTheme.muted)
                        TableZoneSilhouette()
                        Button {
                            appModel.push(.newSession)
                        } label: {
                            Label("+ New session", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(TablehostTheme.primary)
                    }
                    .padding(18)
                    .background(TablehostTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(TablehostTheme.primary.opacity(0.25), lineWidth: 1)
                    )
                } else {
                    Button {
                        appModel.push(.newSession)
                    } label: {
                        Label("+ New session", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(TablehostTheme.primary)

                    ForEach(appModel.sessions, id: \.id) { session in
                        Button {
                            appModel.openSession(session)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.gameName)
                                        .font(.headline)
                                        .foregroundStyle(TablehostTheme.ink)
                                    Text("\(session.playerCount) players · \(session.currentPhase)")
                                        .font(.caption)
                                        .foregroundStyle(TablehostTheme.muted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(TablehostTheme.accent)
                            }
                            .padding(14)
                            .background(TablehostTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(TablehostTheme.primary.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .tablehostScreen()
        .navigationTitle("Sessions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.push(.newSession)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New session")
            }
        }
    }
}

struct NewSessionView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("Game") {
                TextField("Game name", text: $appModel.newGameName)
                TextField("Player count", text: $appModel.newPlayerCount)
                    .keyboardType(.numberPad)
            }
            Section {
                Button("Start capture") {
                    appModel.createSession()
                }
                .tint(TablehostTheme.primary)
            }
        }
        .scrollContentBackground(.hidden)
        .tablehostScreen()
        .navigationTitle("New session")
    }
}
