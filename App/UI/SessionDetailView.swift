import SwiftUI

struct SessionDetailView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let session = appModel.activeSession {
                    Text(session.title).font(.title2.bold())
                    Text(session.instrumentLabel).foregroundStyle(CountroomTheme.muted)

                    if let photo = appModel.activePhoto {
                        Text("Sheet: \(photo.relativePath) (\(photo.source))")
                            .font(.footnote)
                    }

                    if let plan = appModel.confirmedPlan {
                        Text("Kept plan")
                            .font(.headline)
                        ForEach(Array(plan.steps.enumerated()), id: \.offset) { idx, step in
                            let parsed = AppModel.parseStep(step)
                            Text("\(idx + 1). \(parsed.title) · \(parsed.duration)s")
                        }
                        Button("Resume practice") {
                            appModel.push(.practiceFloor)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(CountroomTheme.violet)
                        .accessibilityLabel("Resume practice")
                    } else {
                        Text("No confirmed plan yet.")
                            .foregroundStyle(CountroomTheme.muted)
                        Button("Ask coach") {
                            appModel.push(.coachChat)
                        }
                        .buttonStyle(.bordered)
                    }

                    if !appModel.sessionTurns.isEmpty {
                        Text("Coach history")
                            .font(.headline)
                        ForEach(appModel.sessionTurns, id: \.id) { turn in
                            Text("\(turn.role): \(turn.text)")
                                .font(.footnote)
                        }
                    }
                } else {
                    ContentUnavailableView("Session missing", systemImage: "questionmark.folder")
                }
            }
            .padding(20)
        }
        .countroomScreen()
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
    }
}
