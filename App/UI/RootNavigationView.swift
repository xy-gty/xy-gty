import SpinewellDomain
import SwiftUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            ShelfHomeView()
                .navigationDestination(for: SpinewellRoute.self) { route in
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
    private func destination(for route: SpinewellRoute) -> some View {
        switch route {
        case .shelfHome:
            ShelfHomeView()
        case .cameraCapture:
            ShelfHomeView()
                .onAppear { appModel.showCamera = true }
        case .photoImport:
            ShelfHomeView()
        case .bookIdResult:
            BookIDResultView()
        case .coachChat:
            CoachChatView()
        case .shelfCard:
            ShelfCardView()
        case .findCallout:
            FindCalloutView()
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
