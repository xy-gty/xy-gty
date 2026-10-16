import SwiftUI

@main
struct MatteboxApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(MatteboxTheme.primary)
        }
    }
}
