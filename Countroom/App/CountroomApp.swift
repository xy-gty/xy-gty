import SwiftUI

@main
struct CountroomApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(CountroomTheme.violet)
        }
    }
}
