import MatteboxDomain
import SwiftUI

struct SessionsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Mattebox")
                    .font(.largeTitle.bold())
                    .foregroundStyle(MatteboxTheme.primary)

                Text("AI director framing coach — clapper slate + shot chips.")
                    .font(.subheadline)
                    .foregroundStyle(MatteboxTheme.muted)

                ClapperFrameCanvas(title: "Slate", shotLabel: "MS") {
                    VStack(spacing: 12) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 44))
                            .foregroundStyle(MatteboxTheme.primary.opacity(0.45))
                        Text(appModel.sessions.isEmpty
                             ? "Empty slate — start a framing session"
                             : "\(appModel.sessions.count) session(s) on the board")
                            .font(.callout)
                            .foregroundStyle(MatteboxTheme.ink)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, minHeight: 180)
                }

                ShotSizeChipBar(
                    chips: AppModel.defaultChips,
                    selected: "MS",
                    onSelect: { _ in }
                )
                .opacity(0.55)
                .allowsHitTesting(false)

                Button {
                    appModel.push(.newSession)
                } label: {
                    Label("New session", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(MatteboxTheme.primary)
                .accessibilityIdentifier("new_session_cta")

                if !appModel.sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sessions")
                            .font(.headline)
                            .foregroundStyle(MatteboxTheme.ink)
                        ForEach(appModel.sessions, id: \.id) { session in
                            Button {
                                appModel.openSession(session)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.title)
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(MatteboxTheme.ink)
                                        Text("\(session.currentShotSize) · \(session.aspectRatio)")
                                            .font(.caption)
                                            .foregroundStyle(MatteboxTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(MatteboxTheme.accent)
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(MatteboxTheme.card))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(MatteboxTheme.primary.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(MatteboxTheme.muted)
                }
            }
            .padding(20)
        }
        .matteboxScreen()
        .navigationTitle("Sessions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
