import SwiftUI
import FinishCueDomain

struct ReadingReviewView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        List {
            Section {
                Text("Keep confirmed reads into the heat. Discard drops drafts from official results. Edit then Keep.")
                    .font(.footnote)
                    .foregroundStyle(FinishCueTheme.muted)
                    .listRowBackground(Color.clear)
            }

            Section("Draft & confirmed") {
                ForEach(appModel.heatReads.filter { $0.status != "discarded" }, id: \.id) { read in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Lane \(read.laneNumber)")
                                .font(.headline)
                            Spacer()
                            Text(read.status)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(read.status == "confirmed" ? FinishCueTheme.accent : FinishCueTheme.primary)
                        }
                        Text(read.athleteLabel.isEmpty ? "Athlete TBD" : read.athleteLabel)
                            .font(.subheadline)
                        Text(read.timeRead.isEmpty ? "—.—" : read.timeRead)
                            .font(.title3.monospacedDigit().weight(.bold))
                            .foregroundStyle(FinishCueTheme.ink)

                        if appModel.editingReadId == read.id {
                            HStack {
                                TextField("Lane", text: $appModel.editLaneDraft)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                TextField("Time", text: $appModel.editTimeDraft)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                Button(ReadingReviewBar.confirm) { appModel.applyEditRead() }
                                    .buttonStyle(.borderedProminent)
                                    .tint(FinishCueTheme.accent)
                            }
                        } else {
                            HStack {
                                Button(ReadingReviewBar.confirm) { appModel.keepRead(read.id) }
                                    .buttonStyle(.borderedProminent)
                                    .tint(FinishCueTheme.accent)
                                    .accessibilityIdentifier("Keep-\(read.id)")
                                Button(ReadingReviewBar.reject) { appModel.discardRead(read.id) }
                                    .buttonStyle(.bordered)
                                Button(ReadingReviewBar.edit) { appModel.beginEditRead(read.id) }
                                    .buttonStyle(.bordered)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .finishCueScreen()
        .navigationTitle("Reading review")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish card") { appModel.buildFinishCardDraft() }
            }
        }
        .accessibilityIdentifier("ReadingReview")
    }
}
