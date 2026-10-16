import SwiftUI
import BloomkettleDomain

struct SessionDetailView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        List {
            if let session = appModel.activeSession {
                Section(session.title) {
                    Text(session.complianceSnapshot)
                        .font(.caption)
                        .foregroundStyle(BloomkettleTheme.muted)
                    Button("Resume funnel") { appModel.push(.funnelTimeline) }
                    Button("Coach chat") { appModel.push(.coachChat) }
                    Button("Capture another shot") { appModel.push(.captureImport) }
                }
                Section("Shots") {
                    ForEach(appModel.state.shots.filter { $0.sessionId == session.id }, id: \.id) { shot in
                        Text("\(shot.subject) · \(shot.source)")
                    }
                }
                Section("Kept notes") {
                    ForEach(appModel.sessionNotes.filter { $0.status == "confirmed" }, id: \.id) { note in
                        Text(note.stepSummary)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .bloomkettleScreen()
        .navigationTitle("Session")
        .accessibilityIdentifier("SessionDetail")
    }
}
