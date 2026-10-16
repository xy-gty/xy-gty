import FieldmarkDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            FieldHomeView()
                .navigationDestination(for: FieldmarkRoute.self) { route in
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
    private func destination(for route: FieldmarkRoute) -> some View {
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
        case .overlayStudio:
            OverlayStudioView()
        case .voiceNote:
            VoiceNoteView()
        case .aiConsent:
            ConsentSheet(appModel: appModel)
        case .settings:
            SettingsPrivacyView(appModel: appModel)
        case .legal(let page):
            LegalPageView(title: page.capitalized, fileName: page)
        }
    }
}
