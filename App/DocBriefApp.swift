import SwiftUI

@main
struct DocBriefApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .tint(DocBriefTheme.teal)
        }
    }
}
