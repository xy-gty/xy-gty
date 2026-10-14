import SwiftUI
import CuePartnerDomain

struct RootTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            NavigationStack(path: Binding(
                get: { model.path },
                set: { model.path = $0; model.persistNavigation() }
            )) {
                ScenesHomeView()
                    .navigationDestination(for: CuePartnerRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem { Label("Scenes", systemImage: "square.stack.3d.up") }
            .tag(AppModel.AppTab.scenes)

            NavigationStack {
                RehearseHubView()
            }
            .tabItem { Label("Rehearse", systemImage: "theatermasks") }
            .tag(AppModel.AppTab.rehearse)

            NavigationStack {
                SettingsPrivacyView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(AppModel.AppTab.settings)
        }
        .sheet(isPresented: $model.showConsent) {
            ConsentSheet().environmentObject(model)
        }
    }

    @ViewBuilder
    private func destination(for route: CuePartnerRoute) -> some View {
        switch route {
        case .scenesHome: ScenesHomeView()
        case .newScene: NewSceneView()
        case .importScript: ImportScriptView()
        case .ocrReview: OCRReviewView()
        case .sceneDetail: SceneDetailView()
        case .partnerChat: PartnerChatView()
        case .turnReview: TurnReviewView()
        case .cueRehearsal: CueRehearsalView()
        case .voiceNoteCapture: VoiceNoteView()
        case .ambiencePicker: AmbiencePickerView()
        case .settings: SettingsPrivacyView()
        case .legalPages: LegalPagesView()
        case .consentSheet: ConsentSheet()
        }
    }
}
