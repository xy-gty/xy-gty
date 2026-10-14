import SwiftUI
import KnotCueDomain

struct RootTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationStack(path: $model.path) {
            TabView(selection: $model.selectedTab) {
                RopeHomeView()
                    .tabItem { Label("Rope", systemImage: "circle.hexagongrid") }
                    .tag(AppModel.AppTab.rope)
                CoachChatView()
                    .tabItem { Label("Coach", systemImage: "bubble.left.and.bubble.right") }
                    .tag(AppModel.AppTab.coach)
                OverlaysTabView()
                    .tabItem { Label("Overlays", systemImage: "square.stack.3d.up") }
                    .tag(AppModel.AppTab.overlays)
                SettingsPrivacyView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
                    .tag(AppModel.AppTab.settings)
            }
            .navigationDestination(for: KnotCueRoute.self) { route in
                switch route {
                case .knotCapture: KnotCaptureView()
                case .stageReview: StageReviewView()
                case .knotStageDetail: KnotStageDetailView()
                case .stepOverlay: StepOverlayView()
                case .handsFreeCoach: HandsFreeCoachView()
                case .speechCapture: SpeechCaptureView()
                case .legalPages: LegalPagesHubView()
                default: EmptyView()
                }
            }
        }
        .background(KnotCueTheme.secondary.ignoresSafeArea())
        .sheet(isPresented: $model.showConsent) { ConsentSheet() }
        .sheet(isPresented: $model.showCameraPicker) {
            CameraCapturePicker(
                onImageData: { model.handleCameraImageData($0) },
                onCancel: { model.cancelCameraPicker() }
            )
            .ignoresSafeArea()
        }
        .overlay(alignment: .top) {
            if let message = model.statusMessage {
                Text(message)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .onTapGesture { model.statusMessage = nil }
            }
        }
    }
}

struct LegalPagesHubView: View {
    var body: some View {
        SettingsPrivacyView()
    }
}
