import SwiftUI

@main
struct LuxCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(LuxCueTheme.accent)
        }
    }
}
