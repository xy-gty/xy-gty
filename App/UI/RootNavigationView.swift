import ZonelightDomain
import SwiftUI
import PhotosUI

struct RootNavigationView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack(path: $appModel.path) {
            MeterHomeView()
                .navigationDestination(for: ZonelightRoute.self) { route in
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
    private func destination(for route: ZonelightRoute) -> some View {
        switch route {
        case .meterHome:
            MeterHomeView()
        case .cameraSpot:
            MeterHomeView()
                .onAppear { appModel.showCamera = true }
        case .photoImport:
            MeterHomeView()
        case .exposureResult:
            ExposureResultView()
        case .coachChat:
            CoachChatView()
        case .meterCard:
            MeterCardView()
        case .setCallout:
            SetCalloutView()
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
