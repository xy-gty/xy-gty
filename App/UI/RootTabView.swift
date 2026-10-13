import SwiftUI
import DocBriefDomain

struct RootTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Briefs", systemImage: "doc.text") }
            .tag(AppModel.AppTab.briefs)

            NavigationStack {
                ActiveBriefHub()
            }
            .tabItem { Label("Active brief", systemImage: "checkmark.seal") }
            .tag(AppModel.AppTab.active)

            NavigationStack {
                SettingsPrivacyView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(AppModel.AppTab.settings)
        }
        .toolbarBackground(DocBriefTheme.paper, for: .tabBar)
        .sheet(isPresented: $model.showConsent) {
            ConsentSheet().environmentObject(model)
        }
    }
}

struct ActiveBriefHub: View {
    @EnvironmentObject private var model: AppModel
    @State private var path = NavigationPath()

    var body: some View {
        BriefDetailView(path: $path)
            .navigationDestination(for: BriefRoute.self) { route in
                switch route {
                case .newBrief: NewBriefView()
                case .importCapture: ImportCaptureView()
                case .recognitionReview: RecognitionReviewView()
                case .chatExtract: ChatExtractView()
                case .summaryCard: SummaryCardView()
                case .ttsBriefing: TTSBriefingView()
                }
            }
    }
}

enum BriefRoute: Hashable {
    case newBrief, importCapture, recognitionReview, chatExtract, summaryCard, ttsBriefing
}
