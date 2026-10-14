import SwiftUI

struct SessionsListView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        List {
            if appModel.sessions.isEmpty {
                ContentUnavailableView(
                    "No sessions",
                    systemImage: "clock",
                    description: Text("Start from Practice → New practice.")
                )
            } else {
                ForEach(appModel.sessions, id: \.id) { session in
                    Button {
                        appModel.selectSession(session.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title).font(.headline)
                            Text(session.instrumentLabel)
                                .font(.caption)
                                .foregroundStyle(PitchCueTheme.muted)
                            Text(session.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(PitchCueTheme.muted)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(PitchCueTheme.lilac)
        .navigationTitle("Sessions")
    }
}
