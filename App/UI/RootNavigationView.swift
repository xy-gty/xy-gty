import NightCueDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView {
            NavigationStack(path: $appModel.path) {
                SessionsHomeView()
                    .navigationDestination(for: NightCueRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Sessions", systemImage: "moon.stars.fill") }

            NavigationStack {
                if appModel.activeSession != nil {
                    NightCoachView()
                } else {
                    ContentUnavailableView(
                        "No open session",
                        systemImage: "moon.stars",
                        description: Text("Create a night session from the Sessions tab.")
                    )
                    .nightCueScreen()
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
    private func destination(for route: NightCueRoute) -> some View {
        switch route {
        case .sessionsHome:
            SessionsHomeView()
        case .newSession:
            NewSessionView()
        case .captureImport:
            CaptureImportView()
        case .exposureReview:
            ExposureReviewView()
        case .nightCoach:
            NightCoachView()
        case .coachChat:
            CoachChatView()
        case .turnReview:
            TurnReviewView()
        case .annotatedOverlay:
            AnnotatedOverlayView()
        case .fieldCueTTS:
            FieldCueTTSView()
        case .dictateExposure:
            DictateExposureView()
        case .settings, .legalPages:
            SettingsPrivacyView(appModel: appModel)
        case .consentSheet:
            ConsentSheet(appModel: appModel)
        }
    }
}
