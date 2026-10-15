import SwiftUI

@main
struct YarnCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(YarnCueTheme.fuchsia)
        }
    }
}
