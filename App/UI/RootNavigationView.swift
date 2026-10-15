import StopCueDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView {
            NavigationStack(path: $appModel.path) {
                ProjectsHomeView()
                    .navigationDestination(for: StopCueRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Projects", systemImage: "film.stack") }

            NavigationStack {
                if appModel.activeProject != nil {
                    StopCoachView()
                } else {
                    ContentUnavailableView(
                        "No open project",
                        systemImage: "film",
                        description: Text("Create a stop-motion project from the Projects tab.")
                    )
                    .stopCueScreen()
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
    private func destination(for route: StopCueRoute) -> some View {
        switch route {
        case .projectsHome:
            ProjectsHomeView()
        case .newProject:
            NewProjectView()
        case .captureImport:
            CaptureImportView()
        case .frameReview:
            FrameReviewView()
        case .stopCoach:
            StopCoachView()
        case .coachChat:
            CoachChatView()
        case .turnReview:
            TurnReviewView()
        case .onionSkinGuide:
            OnionSkinGuideView()
        case .countdownTTS:
            CountdownTTSView()
        case .dictateInterval:
            DictateIntervalView()
        case .settings, .legalPages:
            SettingsPrivacyView(appModel: appModel)
        case .consentSheet:
            ConsentSheet(appModel: appModel)
        }
    }
}
