import SporeCueDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            FieldHomeView()
                .navigationDestination(for: SporeCueRoute.self) { route in
                    destination(for: route)
                }
        }
        .onChange(of: appModel.path) { _, _ in
            appModel.persistNavigation()
        }
        .sheet(isPresented: $appModel.showConsent) {
            ConsentSheet(appModel: appModel)
        }
        .sheet(isPresented: $appModel.showCamera) {
            CameraPicker { image in
                appModel.handleCameraImage(image)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $appModel.showVoiceNote) {
            VoiceNoteView()
                .environmentObject(appModel)
        }
        .onChange(of: appModel.selectedPhotoItem) { _, _ in
            appModel.handlePhotoImport()
        }
    }

    @ViewBuilder
    private func destination(for route: SporeCueRoute) -> some View {
        switch route {
        case .fieldHome:
            FieldHomeView()
        case .cameraCapture:
            FieldHomeView()
                .onAppear { appModel.showCamera = true }
        case .photoImport:
            FieldHomeView()
        case .idResult:
            IDResultView()
        case .lookalikeChat:
            LookalikeChatView()
        case .overlayAnnotate:
            OverlayAnnotateView()
        case .fieldBrief:
            FieldBriefView()
        case .voiceNote:
            VoiceNoteView()
        case .aiConsent:
            ConsentSheet(appModel: appModel)
        case .settings:
            SettingsPrivacyView(appModel: appModel)
        case .legal:
            LegalPageView(title: appModel.legalPageName.capitalized, fileName: appModel.legalPageName)
        }
    }
}
