import SwiftUI

@main
struct RuleCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(RuleCueTheme.primary)
        }
    }
}
