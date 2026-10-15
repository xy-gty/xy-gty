import HiveCueDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        TabView {
            NavigationStack(path: $appModel.path) {
                InspectionsHomeView()
                    .navigationDestination(for: HiveCueRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Inspections", systemImage: "hexagon.fill") }

            NavigationStack {
                if appModel.activeInspection != nil {
                    InspectionCoachView()
                } else {
                    ContentUnavailableView(
                        "No open inspection",
                        systemImage: "hexagon",
                        description: Text("Create an inspection from the Inspections tab.")
                    )
                    .hiveCueScreen()
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
    private func destination(for route: HiveCueRoute) -> some View {
        switch route {
        case .inspectionsHome:
            InspectionsHomeView()
        case .newInspection:
            NewInspectionView()
        case .captureImport:
            CaptureImportView()
        case .broodReview:
            BroodReviewView()
        case .inspectionCoach:
            InspectionCoachView()
        case .coachChat:
            CoachChatView()
        case .turnReview:
            TurnReviewView()
        case .annotatedFrame:
            AnnotatedFrameView()
        case .handsFreeTTS:
            HandsFreeTTSView()
        case .dictateFields:
            DictateFieldsView()
        case .settings, .legalPages:
            SettingsPrivacyView(appModel: appModel)
        case .consentSheet:
            ConsentSheet(appModel: appModel)
        }
    }
}
