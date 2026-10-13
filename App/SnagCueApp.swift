import SwiftUI

@main
struct SnagCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(SnagTheme.steel)
        }
    }
}
