import SwiftUI
import FinishCueDomain

struct FinishCardView: View {
    @EnvironmentObject private var appModel: AppModel

    private var card: FinishCard? {
        if let id = appModel.activeCardId {
            return appModel.state.finishCards.first(where: { $0.id == id })
        }
        return appModel.heatCards.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()

                Text("Annotated finish-bar card")
                    .font(.title2.bold())
                    .foregroundStyle(FinishCueTheme.ink)

                if let path = card?.stripCropURL ?? appModel.activeStrip?.localMediaURL,
                   let image = UIImage(contentsOfFile: path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                HStack {
                    ForEach(card?.laneNumbers ?? [], id: \.self) { lane in
                        Text("L\(lane)")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(FinishCueTheme.primary.opacity(0.15), in: Capsule())
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(card?.timeChips ?? [], id: \.self) { chip in
                            Text(chip)
                                .font(.subheadline.monospacedDigit().weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(FinishCueTheme.accent.opacity(0.2), in: Capsule())
                        }
                    }
                }

                HStack {
                    Button("Keep card") { appModel.keepCard() }
                        .buttonStyle(.borderedProminent)
                        .tint(FinishCueTheme.accent)
                        .accessibilityIdentifier("KeepCard")
                    Button("Discard") { appModel.discardCard() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .finishCueScreen()
        .navigationTitle("Finish card")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("FinishCard")
    }
}
