import SwiftUI
import StirboardDomain

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
                        Text("Label notes")
                            .font(.headline)
                            .foregroundStyle(StirboardTheme.ink)
                        ForEach(appModel.sessionCandidates.flatMap(\.labelCues).prefix(6), id: \.self) { cue in
                            Text("· \(cue)")
                                .font(.subheadline)
                                .foregroundStyle(StirboardTheme.muted)
                        }
                        if appModel.sessionCandidates.isEmpty {
                            Text("Identify to fill the bottle rail.")
                                .font(.subheadline)
                                .foregroundStyle(StirboardTheme.muted)
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
                    .tint(StirboardTheme.accent)
                    .disabled(appModel.identifyBusy)

                    Button("Save Mix") { appModel.saveMix() }
                        .buttonStyle(.borderedProminent)
                        .tint(StirboardTheme.accent)

                    Button("Dismiss") { appModel.dismissID() }
                        .buttonStyle(.bordered)
                }

                Button("Ask coach") { appModel.push(.recipeChat) }
                    .foregroundStyle(StirboardTheme.primary)
                Button("Open pour board") { appModel.openPourBoard() }
                    .foregroundStyle(StirboardTheme.primary)
            }
            .padding(16)
        }
        .stirboardScreen()
        .navigationTitle("Spirit ID")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("IDResult")
    }
}
