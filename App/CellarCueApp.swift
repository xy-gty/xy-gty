import SwiftUI

@main
struct CellarCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(CellarCueTheme.accent)
        }
    }
}
