import SwiftUI
import BendCoachDomain

struct RootTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "wrench.and.screwdriver") }
                .tag(AppModel.AppTab.home)

            NavigationStack { JobHubView() }
                .tabItem { Label("Job", systemImage: "checklist") }
                .tag(AppModel.AppTab.job)

            NavigationStack { SettingsPrivacyView() }
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppModel.AppTab.settings)
        }
        .toolbarBackground(BendCoachTheme.bg, for: .tabBar)
        .toolbarBackground(BendCoachTheme.bg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $model.showConsent) {
            ConsentSheet().environmentObject(model)
        }
        .sheet(isPresented: $model.showUnitsIntro) {
            UnitsIntroSheet().environmentObject(model)
        }
    }
}

enum CoachRoute: Hashable {
    case bendMathChat, captureImport, bendReview, diagramOverlay, ttsCoaching, units
}

struct JobHubView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        JobDetailView()
            .navigationDestination(for: CoachRoute.self) { route in
                switch route {
                case .bendMathChat: BendMathChatView()
                case .captureImport: CaptureImportView()
                case .bendReview: BendReviewView()
                case .diagramOverlay: DiagramOverlayView()
                case .ttsCoaching: TTSCoachingView()
                case .units: UnitsSettingsView()
                }
            }
    }
}
