import SwiftUI

@main
struct FinishCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(FinishCueTheme.primary)
        }
    }
}
