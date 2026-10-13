import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            HomeView()
            .tabItem { Label("Audits", systemImage: "list.bullet.rectangle") }
            .tag(AppModel.AppTab.audits)

            NavigationStack {
                ActivePunchHub()
            }
            .tabItem { Label("Active punch", systemImage: "checkmark.seal") }
            .tag(AppModel.AppTab.active)

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
}

struct ActivePunchHub: View {
    @EnvironmentObject private var model: AppModel
    @State private var path = NavigationPath()

    var body: some View {
        PunchListView(path: $path)
            .navigationDestination(for: SnagRoute.self) { route in
                switch route {
                case .capture: CaptureView()
                case .review: SnagRecognitionReviewView()
                case .chat: ChatFillView()
                case .chatForPunch(let id): ChatFillView(initialPunchItemId: id)
                case .report: AnnotatedReportView()
                case .tts: TTSCoachView()
                case .newAudit: NewAuditView()
                }
            }
    }
}

enum SnagRoute: Hashable {
    case newAudit, capture, review, chat, report, tts
    case chatForPunch(String)
}
