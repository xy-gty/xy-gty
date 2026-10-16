import LoopwellDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView {
            NavigationStack(path: $appModel.path) {
                ProjectsHomeView()
                    .navigationDestination(for: LoopwellRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Projects", systemImage: "square.grid.2x2.fill") }

            NavigationStack {
                if appModel.activeProject != nil {
                    ProjectCoachView()
                } else {
                    ContentUnavailableView(
                        "No open project",
                        systemImage: "circle.hexagongrid.fill",
                        description: Text("Create a project from the Projects tab.")
                    )
                    .loopwellScreen()
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
    private func destination(for route: LoopwellRoute) -> some View {
        switch route {
        case .projectsHome:
            ProjectsHomeView()
        case .newProject:
            NewProjectView()
        case .captureImport:
            CaptureImportView()
        case .stitchReview:
            StitchReviewView()
        case .projectCoach:
            ProjectCoachView()
        case .coachChat:
            CoachChatView()
        case .turnReview:
            TurnReviewView()
        case .annotatedWIP:
            AnnotatedWIPView()
        case .handsFreeTTS:
            HandsFreeTTSView()
        case .dictateNote:
            DictateNoteView()
        case .settings, .legalPages:
            SettingsPrivacyView(appModel: appModel)
        case .consentSheet:
            ConsentSheet(appModel: appModel)
        }
    }
}
