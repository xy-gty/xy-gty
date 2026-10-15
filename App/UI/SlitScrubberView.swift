import SwiftUI

struct SlitScrubberView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var chipDraft = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ComplianceBanner()

                if let path = appModel.activeStrip?.localMediaURL,
                   let image = UIImage(contentsOfFile: path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(FinishCueTheme.primary.opacity(0.3), lineWidth: 1)
                        )
                }

                SlitScanScrubber(position: $appModel.scrubPosition, isReading: appModel.readBusy)

                LaneScaleRail(laneMarks: $appModel.laneMarks) { lane in
                    appModel.toggleLaneMark(lane)
                }

                TimeCalloutChips(chips: appModel.timeChips) {
                    // show inline field below
                }

                HStack {
                    TextField("e.g. 12.34", text: $chipDraft)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        appModel.addTimeChip(chipDraft)
                        chipDraft = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(FinishCueTheme.accent)
                }

                if appModel.readBusy {
                    Label("Reading lanes…", systemImage: "waveform.path.ecg")
                        .foregroundStyle(FinishCueTheme.primary)
                }

                Button {
                    appModel.readTimes()
                } label: {
                    Label("Read times", systemImage: "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(FinishCueTheme.primary, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .disabled(appModel.readBusy)
                .accessibilityIdentifier("ReadTimes")

                Button("Open coach chat") {
                    appModel.push(.coachChat)
                }
                .foregroundStyle(FinishCueTheme.accent)
            }
            .padding(20)
        }
        .finishCueScreen()
        .navigationTitle("Slit scrubber")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("SlitScrubber")
    }
}
