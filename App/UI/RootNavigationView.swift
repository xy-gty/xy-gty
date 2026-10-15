import SwiftUI
import FinishCueDomain

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            HeatHomeView()
                .navigationDestination(for: FinishCueRoute.self) { route in
                    switch route {
                    case .heatHome:
                        HeatHomeView()
                    case .captureImport:
                        CaptureImportView()
                    case .slitScrubber:
                        SlitScrubberView()
                    case .coachChat:
                        CoachChatView()
                    case .readingReview:
                        ReadingReviewView()
                    case .finishCard:
                        FinishCardView()
                    case .calloutDeck:
                        CalloutDeckView()
                    case .heatDetail:
                        HeatDetailView()
                    case .settings:
                        SettingsPrivacyView()
                    case .legalPages:
                        LegalPageHost(page: appModel.legalPageName)
                    case .consentSheet:
                        ConsentSheet(appModel: appModel)
                    }
                }
        }
        .sheet(isPresented: $appModel.showConsent) {
            ConsentSheet(appModel: appModel)
        }
        .fullScreenCover(isPresented: $appModel.showCamera) {
            CameraPicker { image in
                appModel.ingestImage(image, source: "camera")
            }
        }
        .overlay(alignment: .bottom) {
            if let msg = appModel.statusMessage {
                Text(msg)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(appModel.statusIsError ? Color.red : FinishCueTheme.ink)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture { appModel.statusMessage = nil }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appModel.statusMessage)
    }
}

struct LegalPageHost: View {
    let page: String
    var body: some View {
        LocalLegalWebView(fileName: page)
            .navigationTitle(page.capitalized)
            .navigationBarTitleDisplayMode(.inline)
            .finishCueScreen()
    }
}
