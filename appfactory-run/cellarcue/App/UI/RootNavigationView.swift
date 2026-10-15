import CellarCueDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            CellarHomeView()
                .navigationDestination(for: CellarCueRoute.self) { route in
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
    private func destination(for route: CellarCueRoute) -> some View {
        switch route {
        case .cellarHome:
            CellarHomeView()
        case .cameraCapture:
            CellarHomeView()
                .onAppear { appModel.showCamera = true }
        case .photoImport:
            CellarHomeView()
        case .labelResult:
            LabelResultView()
        case .windowChat:
            WindowChatView()
        case .rackCard:
            RackCardView()
        case .pullBrief:
            PullBriefView()
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
