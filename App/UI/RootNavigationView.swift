import SunbriefDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            ScoutsHomeView()
                .navigationDestination(for: SunbriefRoute.self) { route in
                    switch route {
                    case .scoutsHome:
                        ScoutsHomeView()
                    case .captureImport:
                        CaptureImportView()
                    case .sceneReview:
                        SceneReviewView()
                    case .scoutCardDetail:
                        ScoutCardDetailView()
                    case .coachChat:
                        CoachChatView()
                    case .turnReview:
                        TurnReviewView()
                    case .goldenOverlay:
                        GoldenOverlayView()
                    case .nextStopBriefing:
                        NextStopBriefingView()
                    case .dictateNote:
                        DictateNoteView()
                    case .settings, .legalPages:
                        SettingsPrivacyView(appModel: appModel)
                    case .consentSheet:
                        ConsentSheet(appModel: appModel)
                    }
                }
        }
        .onChange(of: appModel.path) { _, _ in
            appModel.persistNavigation()
        }
        .sheet(isPresented: $appModel.showConsent) {
            ConsentSheet(appModel: appModel)
        }
    }
}
