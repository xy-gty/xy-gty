import AppRuntimeCore
import SwiftUI
import WorkrestDomain

struct SessionsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                IntervalChipRail(
                    blocks: ["Warm-up", "Main HIIT", "Finisher"],
                    currentIndex: 0,
                    onSelect: { _ in }
                )

                Text("Workrest")
                    .font(.largeTitle.bold())
                    .foregroundStyle(WorkrestTheme.primary)

                Text("Snap mid-set form, Keep posture notes, run intervals on a chip rail with a large rest ring, and annotate the polaroid strip.")
                    .font(.body)
                    .foregroundStyle(WorkrestTheme.muted)

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(WorkrestTheme.ink)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(WorkrestTheme.accent.opacity(0.25)))
                }

                if appModel.sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No sessions yet")
                            .font(.title3.bold())
                            .foregroundStyle(WorkrestTheme.ink)
                        Text("Start a session shelf, then capture your first mid-set pose.")
                            .foregroundStyle(WorkrestTheme.muted)
                        Button("New session") {
                            appModel.push(.newSession)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(WorkrestTheme.primary)
                        .accessibilityIdentifier("cta-new-session")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 18).fill(WorkrestTheme.card))
                } else {
                    Button("New session") {
                        appModel.push(.newSession)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WorkrestTheme.primary)

                    ForEach(appModel.sessions, id: \.id) { session in
                        Button {
                            appModel.openSession(session)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(session.title)
                                    .font(.headline)
                                    .foregroundStyle(WorkrestTheme.ink)
                                Text("Block · \(session.currentBlockLabel)")
                                    .font(.subheadline)
                                    .foregroundStyle(WorkrestTheme.muted)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 16).fill(WorkrestTheme.card))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .workrestScreen()
        .navigationTitle("Sessions")
    }
}

struct NewSessionView: View {
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var titleFocused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { titleFocused = false }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Session title")
                    .font(.headline)
                    .foregroundStyle(WorkrestTheme.ink)
                TextField("Title", text: $appModel.newSessionTitle)
                    .textFieldStyle(.roundedBorder)
                    .focused($titleFocused)
            }
            .padding(20)
        } actions: {
            Button("Create & capture") {
                appModel.createSession()
            }
            .buttonStyle(.borderedProminent)
            .tint(WorkrestTheme.primary)
            .padding()
        }
        .workrestScreen()
        .navigationTitle("New session")
    }
}
