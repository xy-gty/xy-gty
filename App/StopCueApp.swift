import SwiftUI

@main
struct StopCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(StopCueTheme.primary)
        }
    }
}
