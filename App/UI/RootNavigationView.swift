import WorkrestDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView {
            NavigationStack(path: $appModel.path) {
                SessionsHomeView()
                    .navigationDestination(for: WorkrestRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Sessions", systemImage: "list.bullet.rectangle.fill") }

            NavigationStack {
                if appModel.activeSession != nil {
                    SessionCoachView()
                } else {
                    ContentUnavailableView(
                        "No open session",
                        systemImage: "figure.run",
                        description: Text("Create a session from the Sessions tab.")
                    )
                    .workrestScreen()
                }
            }
            .tabItem { Label("Coach", systemImage: "bubble.left.and.bubble.right.fill") }

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
    private func destination(for route: WorkrestRoute) -> some View {
        switch route {
        case .sessionsHome:
            SessionsHomeView()
        case .newSession:
            NewSessionView()
        case .captureImport:
            CaptureImportView()
        case .formReview:
            FormReviewView()
        case .sessionCoach:
            SessionCoachView()
        case .coachChat:
            CoachChatView()
        case .turnReview:
            TurnReviewView()
        case .annotatedForm:
            AnnotatedFormView()
        case .handsFreeTTS:
            HandsFreeTTSView()
        case .dictateIntent:
            DictateIntentView()
        case .settings, .legalPages:
            SettingsPrivacyView(appModel: appModel)
        case .consentSheet:
            ConsentSheet(appModel: appModel)
        }
    }
}
