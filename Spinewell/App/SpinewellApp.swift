import SwiftUI

@main
struct SpinewellApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(SpinewellTheme.primary)
        }
    }
}
