import SwiftUI

@main
struct FieldmarkApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(appModel)
                .tint(FieldmarkTheme.primary)
        }
    }
}
