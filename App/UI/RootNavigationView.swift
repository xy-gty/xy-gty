import StirboardDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            BarHomeView()
                .navigationDestination(for: StirboardRoute.self) { route in
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
    private func destination(for route: StirboardRoute) -> some View {
        switch route {
        case .barHome:
            BarHomeView()
        case .cameraCapture:
            BarHomeView()
                .onAppear { appModel.showCamera = true }
        case .photoImport:
            BarHomeView()
        case .idResult:
            IDResultView()
        case .recipeChat:
            RecipeChatView()
        case .pourBoard:
            PourBoardView()
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
