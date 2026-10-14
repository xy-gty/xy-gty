import SwiftUI

@main
struct PitchCueApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(PitchCueTheme.violet)
        }
    }
}
