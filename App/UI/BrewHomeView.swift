import SwiftUI
import BrewCueDomain

struct BrewHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()
                Text("BrewCue")
                    .font(.largeTitle.bold())
                    .foregroundStyle(BrewCueTheme.primary)
                Text("Home pour-over coach — snap a brew shot, follow the funnel timeline.")
                    .font(.subheadline)
                    .foregroundStyle(BrewCueTheme.muted)

                Button {
                    appModel.createSession()
                } label: {
                    Label("New brew session", systemImage: "drop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(BrewCueTheme.accent)
                .accessibilityIdentifier("NewBrewSession")

                if appModel.state.sessions.isEmpty {
                    ContentUnavailableView(
                        "No brew sessions yet",
                        systemImage: "cup.and.saucer",
                        description: Text("Start a session, then snap beans, grounds, bloom, pour, or crema.")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                } else {
                    ForEach(appModel.state.sessions, id: \.id) { session in
                        Button {
                            appModel.openSession(session.id)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.title)
                                        .font(.headline)
                                        .foregroundStyle(BrewCueTheme.ink)
                                    Text(session.gearNote.isEmpty ? "Pour-over" : session.gearNote)
                                        .font(.caption)
                                        .foregroundStyle(BrewCueTheme.muted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(BrewCueTheme.primary)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.85))
                                    .shadow(color: BrewCueTheme.primary.opacity(0.12), radius: 6, y: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .brewCueScreen()
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.openSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityIdentifier("OpenSettings")
            }
        }
        .accessibilityIdentifier("BrewHome")
    }
}
