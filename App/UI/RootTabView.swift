import SwiftUI
import PitchCueDomain

struct RootTabView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView(selection: $appModel.selectedTab) {
            NavigationStack(path: $appModel.path) {
                PracticeHomeView()
                    .navigationDestination(for: PitchCueRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Practice", systemImage: "music.note.list") }
            .tag(AppModel.AppTab.practice)

            NavigationStack {
                SessionsListView()
            }
            .tabItem { Label("Sessions", systemImage: "clock.arrow.circlepath") }
            .tag(AppModel.AppTab.sessions)

            NavigationStack {
                SettingsPrivacyView(appModel: appModel)
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(AppModel.AppTab.settings)
        }
        .sheet(isPresented: $appModel.showConsent) {
            ConsentSheet(appModel: appModel)
        }
        .onChange(of: appModel.path) { _, _ in
            appModel.persistNavigation()
        }
    }

    @ViewBuilder
    private func destination(for route: PitchCueRoute) -> some View {
        switch route {
        case .practiceHome:
            PracticeHomeView()
        case .newSession:
            NewSessionView()
        case .captureImport:
            CaptureImportView()
        case .coachChat:
            CoachChatView()
        case .planReview:
            PlanReviewView()
        case .practiceFloor:
            PracticeFloorView()
        case .pitchFeedback:
            PitchFeedbackView()
        case .sessionDetail:
            SessionDetailView()
        case .settings:
            SettingsPrivacyView(appModel: appModel)
        case .legalPages:
            LocalLegalWebView(page: .privacy)
        case .consentSheet:
            ConsentSheet(appModel: appModel)
        }
    }
}
