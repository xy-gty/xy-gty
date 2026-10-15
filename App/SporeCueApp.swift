import SwiftUI

@main
struct SporeCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(SporeCueTheme.accent)
        }
    }
}
