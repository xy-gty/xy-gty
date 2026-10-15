import SwiftUI

@main
struct FolioCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(FolioCueTheme.primary)
        }
    }
}
