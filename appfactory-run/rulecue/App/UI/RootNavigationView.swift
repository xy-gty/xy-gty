import RuleCueDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView {
            NavigationStack(path: $appModel.path) {
                SessionsHomeView()
                    .navigationDestination(for: RuleCueRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Sessions", systemImage: "rectangle.grid.2x2.fill") }

            NavigationStack {
                if appModel.activeSession != nil {
                    TableCoachView()
                } else {
                    ContentUnavailableView(
                        "No open session",
                        systemImage: "rectangle.on.rectangle",
                        description: Text("Create a board-game session from the Sessions tab.")
                    )
                    .ruleCueScreen()
                }
            }
            .tabItem { Label("Table", systemImage: "tablecells.fill") }

            NavigationStack {
                SettingsPrivacyView(appModel: appModel)
            }
            .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .onChange(of: appModel.path) { _, _ in
            appModel.persistNavigation()
        }
        .sheet(isPresented: $appModel.showConsent) {
            ConsentSheet(appModel: appModel)
        }
    }

    @ViewBuilder
    private func destination(for route: RuleCueRoute) -> some View {
        switch route {
        case .sessionsHome:
            SessionsHomeView()
        case .newSession:
            NewSessionView()
        case .captureImport:
            CaptureImportView()
        case .componentReview:
            ComponentReviewView()
        case .tableCoach:
            TableCoachView()
        case .coachChat:
            CoachChatView()
        case .turnReview:
            TurnReviewView()
        case .setupOverlay:
            SetupOverlayView()
        case .hostTTS:
            HostTTSView()
        case .dictateRules:
            DictateRulesView()
        case .settings, .legalPages:
            SettingsPrivacyView(appModel: appModel)
        case .consentSheet:
            ConsentSheet(appModel: appModel)
        }
    }
}
