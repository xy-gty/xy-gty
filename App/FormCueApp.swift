import SwiftUI

@main
struct FormCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(FormCueTheme.primary)
        }
    }
}
