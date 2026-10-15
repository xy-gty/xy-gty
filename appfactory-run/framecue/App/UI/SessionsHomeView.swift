import FrameCueDomain
import SwiftUI

struct SessionsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("FrameCue")
                    .font(.largeTitle.bold())
                    .foregroundStyle(FrameCueTheme.primary)

                Text("AI director framing coach — clapper slate + shot chips.")
                    .font(.subheadline)
                    .foregroundStyle(FrameCueTheme.muted)

                ClapperFrameCanvas(title: "Slate", shotLabel: "MS") {
                    VStack(spacing: 12) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 44))
                            .foregroundStyle(FrameCueTheme.primary.opacity(0.45))
                        Text(appModel.sessions.isEmpty
                             ? "Empty slate — start a framing session"
                             : "\(appModel.sessions.count) session(s) on the board")
                            .font(.callout)
                            .foregroundStyle(FrameCueTheme.ink)
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
                .tint(FrameCueTheme.primary)
                .accessibilityIdentifier("new_session_cta")

                if !appModel.sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sessions")
                            .font(.headline)
                            .foregroundStyle(FrameCueTheme.ink)
                        ForEach(appModel.sessions, id: \.id) { session in
                            Button {
                                appModel.openSession(session)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.title)
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(FrameCueTheme.ink)
                                        Text("\(session.currentShotSize) · \(session.aspectRatio)")
                                            .font(.caption)
                                            .foregroundStyle(FrameCueTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(FrameCueTheme.accent)
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(FrameCueTheme.card))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(FrameCueTheme.primary.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(FrameCueTheme.muted)
                }
            }
            .padding(20)
        }
        .frameCueScreen()
        .navigationTitle("Sessions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
