import FrameCueDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView {
            NavigationStack(path: $appModel.path) {
                SessionsHomeView()
                    .navigationDestination(for: FrameCueRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Sessions", systemImage: "film.stack") }

            NavigationStack {
                if appModel.activeSession != nil {
                    SlateStageView()
                } else {
                    ContentUnavailableView(
                        "No open session",
                        systemImage: "rectangle.dashed",
                        description: Text("Create a framing session from the Sessions tab.")
                    )
                    .frameCueScreen()
                }
            }
            .tabItem { Label("Stage", systemImage: "rectangle.inset.filled") }

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
    private func destination(for route: FrameCueRoute) -> some View {
        switch route {
        case .sessionsHome:
            SessionsHomeView()
        case .newSession:
            NewSessionView()
        case .captureImport:
            CaptureImportView()
        case .compositionReview:
            CompositionReviewView()
        case .slateStage:
            SlateStageView()
        case .coachChat:
            CoachChatView()
        case .turnReview:
            TurnReviewView()
        case .overlayMarks:
            OverlayMarksView()
        case .handsFreeTTS:
            HandsFreeTTSView()
        case .dictateShot:
            DictateShotView()
        case .settings, .legalPages:
            SettingsPrivacyView(appModel: appModel)
        case .consentSheet:
            ConsentSheet(appModel: appModel)
        }
    }
}
