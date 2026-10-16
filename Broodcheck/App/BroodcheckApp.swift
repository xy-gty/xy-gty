import SwiftUI

@main
struct BroodcheckApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(BroodcheckTheme.primary)
        }
    }
}
