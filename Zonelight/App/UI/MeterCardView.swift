import SwiftUI
import ZonelightDomain

struct MeterCardView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()
                OversizedEVReadoutBar(evText: appModel.evDisplay)

                Text("Annotated meter card")
                    .font(.title2.bold())
                    .foregroundStyle(ZonelightTheme.primary)

                ForEach(Array(appModel.draftCallouts.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.body.weight(.medium))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ZonelightTheme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ZonelightTheme.accent.opacity(0.4), lineWidth: 1)
                                )
                        )
                }

                HStack {
                    Button("Save") { appModel.keepMeterCard() }
                        .buttonStyle(.borderedProminent)
                        .tint(ZonelightTheme.primary)
                    Button("Keep") { appModel.keepMeterCard() }
                        .buttonStyle(.bordered)
                    Button("Reject") { appModel.rejectMeterCardDraft() }
                        .buttonStyle(.bordered)
                    Button("Speak Callout") { appModel.playSetCallout() }
                        .buttonStyle(.borderedProminent)
                        .tint(ZonelightTheme.accent)
                }
            }
            .padding(20)
        }
        .luxScreen()
        .navigationTitle("Meter Card")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("MeterCard")
    }
}
