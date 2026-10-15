import SwiftUI

@main
struct NightCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(NightCueTheme.primary)
        }
    }
}
