import SwiftUI
import CellarCueDomain

struct LabelResultView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()

                LabelOCRHeroCardView(
                    bottle: appModel.activeBottle,
                    ocr: appModel.activeOCR,
                    isBusy: appModel.identifyBusy
                )

                DrinkingWindowTimelineView(window: appModel.activeWindow)

                CellarRowBinGridView(
                    bins: appModel.state.bins,
                    bottlesByBin: appModel.bottlesByBin,
                    selectedBinId: appModel.selectedBinId,
                    onSelect: { appModel.selectBin($0) }
                )

                if let banner = appModel.statusMessage {
                    Text(banner)
                        .font(.footnote)
                        .foregroundStyle(appModel.statusIsError ? Color.red : CellarCueTheme.ink)
                }

                VStack(spacing: 10) {
                    Button {
                        appModel.requestIdentify()
                    } label: {
                        Text(appModel.identifyBusy ? "Reading label…" : "Identify / Place")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(CellarCueTheme.accent)
                    .disabled(appModel.identifyBusy)

                    HStack {
                        Button("Save Bottle") { appModel.saveBottle() }
                            .buttonStyle(.borderedProminent)
                            .tint(CellarCueTheme.accent)
                        Button("Keep") { appModel.saveBottle() }
                            .buttonStyle(.bordered)
                        Button("Dismiss") { appModel.dismissID() }
                            .buttonStyle(.bordered)
                    }

                    Button("Ask coach") { appModel.push(.windowChat) }
                        .foregroundStyle(CellarCueTheme.primary)
                    Button("Make rack card") { appModel.openRackCard() }
                        .buttonStyle(.borderedProminent)
                        .tint(CellarCueTheme.accent)
                    Button("Play brief") { appModel.playPullBrief() }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(CellarCueTheme.secondary))
                        .foregroundStyle(CellarCueTheme.primary)
                }
            }
            .padding(16)
        }
        .cellarScreen()
        .navigationTitle("Label result")
        .navigationBarTitleDisplayMode(.inline)
    }
}
