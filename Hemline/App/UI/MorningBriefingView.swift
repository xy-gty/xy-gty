import SwiftUI
import HemlineDomain

struct MorningBriefingView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let briefing = appModel.activeBriefing {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(briefing.utterances.enumerated()), id: \.offset) { index, line in
                            utteranceRow(line, index: index)
                        }
                    }
                    .padding(16)
                }
            } else {
                HemlineTheme.mutedText("No briefing loaded.")
                    .padding(20)
            }

            playerBar
        }
        .hemlineScene()
        .navigationTitle("Morning briefing")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func utteranceRow(_ line: String, index: Int) -> some View {
        let isActive = index == appModel.briefingIndex
        Text(line)
            .font(.body)
            .foregroundStyle(isActive ? HemlineTheme.cta : HemlineTheme.ink)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isActive ? HemlineTheme.surface : HemlineTheme.bg)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isActive ? HemlineTheme.cta : HemlineTheme.line, lineWidth: isActive ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .animation(.easeInOut(duration: 0.25), value: appModel.briefingIndex)
    }

    private var playerBar: some View {
        HStack(spacing: 10) {
            Button("Play briefing") {
                appModel.playBriefing()
            }
            .buttonStyle(CCPrimaryButtonStyle())

            Button(HemlineReviewControls.MorningBriefingPlayer.pause) {
                appModel.pauseBriefing()
            }
            .buttonStyle(CCSecondaryButtonStyle())

            Button(HemlineReviewControls.MorningBriefingPlayer.next) {
                appModel.nextBriefingStep()
            }
            .buttonStyle(CCSecondaryButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
}
