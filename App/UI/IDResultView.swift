import SwiftUI
import MixCueDomain

struct IDResultView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let banner = appModel.statusMessage {
                    StatusBanner(text: banner, isError: appModel.statusIsError)
                }

                HStack(alignment: .top, spacing: 12) {
                    BottleRailView(candidates: appModel.sessionCandidates)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Label cues")
                            .font(.headline)
                            .foregroundStyle(MixCueTheme.ink)
                        ForEach(appModel.sessionCandidates.flatMap(\.labelCues).prefix(6), id: \.self) { cue in
                            Text("· \(cue)")
                                .font(.subheadline)
                                .foregroundStyle(MixCueTheme.muted)
                        }
                        if appModel.sessionCandidates.isEmpty {
                            Text("Identify to fill the bottle rail.")
                                .font(.subheadline)
                                .foregroundStyle(MixCueTheme.muted)
                        }

                        NextPourCardView(
                            step: appModel.currentPourStep,
                            isActive: false,
                            onNext: nil,
                            onSpeak: nil
                        )
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        appModel.requestIdentify()
                    } label: {
                        Label(appModel.identifyBusy ? "Reading…" : "Identify", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(MixCueTheme.accent)
                    .disabled(appModel.identifyBusy)

                    Button("Save Mix") { appModel.saveMix() }
                        .buttonStyle(.borderedProminent)
                        .tint(MixCueTheme.accent)

                    Button("Dismiss") { appModel.dismissID() }
                        .buttonStyle(.bordered)
                }

                Button("Ask coach") { appModel.push(.recipeChat) }
                    .foregroundStyle(MixCueTheme.primary)
                Button("Open pour board") { appModel.openPourBoard() }
                    .foregroundStyle(MixCueTheme.primary)
            }
            .padding(16)
        }
        .mixCueScreen()
        .navigationTitle("Spirit ID")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("IDResult")
    }
}
