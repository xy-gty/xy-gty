import SwiftUI

struct HeatDetailView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        List {
            if let heat = appModel.activeHeat {
                Section(heat.title) {
                    Text(heat.complianceSnapshot)
                        .font(.caption)
                        .foregroundStyle(FinishCueTheme.muted)
                    Button("Capture / import") { appModel.push(.captureImport) }
                    Button("Slit scrubber") { appModel.push(.slitScrubber) }
                    Button("Coach chat") { appModel.push(.coachChat) }
                    Button("Callout deck") { appModel.push(.calloutDeck) }
                }
            }

            Section("Confirmed reads") {
                if appModel.confirmedReads.isEmpty {
                    Text("None yet").foregroundStyle(FinishCueTheme.muted)
                } else {
                    ForEach(appModel.confirmedReads, id: \.id) { read in
                        Text("L\(read.laneNumber)  \(read.athleteLabel)  \(read.timeRead)")
                            .font(.body.monospacedDigit())
                    }
                }
            }

            Section("Finish cards") {
                let cards = appModel.heatCards.filter { $0.status == "confirmed" }
                if cards.isEmpty {
                    Text("None kept").foregroundStyle(FinishCueTheme.muted)
                } else {
                    ForEach(cards, id: \.id) { card in
                        Text("Lanes \(card.laneNumbers.map(String.init).joined(separator: ",")) · \(card.timeChips.joined(separator: ", "))")
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .finishCueScreen()
        .navigationTitle("Heat detail")
        .accessibilityIdentifier("HeatDetail")
    }
}
