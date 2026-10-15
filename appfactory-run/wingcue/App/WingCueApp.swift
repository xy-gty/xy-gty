import SwiftUI

@main
struct WingCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(WingCueTheme.primary)
        }
    }
}
