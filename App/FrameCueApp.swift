import SwiftUI

@main
struct FrameCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(FrameCueTheme.primary)
        }
    }
}
