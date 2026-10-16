import PhotosUI
import SwiftUI
import RacknoteDomain

struct CellarHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Racknote")
                        .font(.largeTitle.bold())
                        .foregroundStyle(RacknoteTheme.primary)
                    Spacer()
                    Button {
                        appModel.push(.settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(RacknoteTheme.primary)
                    }
                    .accessibilityLabel("Settings")
                }

                ComplianceBanner()

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(RacknoteTheme.muted)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.7)))
                }

                if let banner = appModel.statusMessage {
                    Text(banner)
                        .font(.footnote)
                        .foregroundStyle(appModel.statusIsError ? Color.red : RacknoteTheme.ink)
                }

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

                captureBar
                coachBar
            }
            .padding(16)
        }
        .cellarScreen()
        .navigationBarHidden(true)
    }

    private var captureBar: some View {
        HStack(spacing: 12) {
            Button {
                appModel.showCamera = true
            } label: {
                Text("Shoot")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(RacknoteTheme.accent))
                    .foregroundStyle(.white)
            }
            .accessibilityIdentifier("ShootButton")
            .accessibilityLabel("Shoot")

            PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                Text("Import")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .stroke(RacknoteTheme.primary, lineWidth: 2)
                    )
                    .foregroundStyle(RacknoteTheme.primary)
            }
            .accessibilityLabel("Import")

            Button {
                appModel.showVoiceNote = true
            } label: {
                Image(systemName: "mic.fill")
                    .padding(14)
                    .background(Circle().fill(RacknoteTheme.binEmpty))
                    .foregroundStyle(RacknoteTheme.primary)
            }
            .accessibilityLabel("Voice note")
        }
    }

    private var coachBar: some View {
        HStack(spacing: 8) {
            TextField("Ask drinking window or pairing…", text: $appModel.coachQuestion)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.send)
                .onSubmit { appModel.sendCoachQuestion() }

            Button {
                if appModel.speechService.isListening {
                    appModel.finishSpeechQuestion()
                } else {
                    appModel.startSpeechQuestion()
                }
            } label: {
                Image(systemName: appModel.speechService.isListening ? "stop.circle.fill" : "waveform")
                    .foregroundStyle(RacknoteTheme.accent)
            }
            .accessibilityLabel("Speech question")

            Button("Ask") {
                appModel.sendCoachQuestion()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(RacknoteTheme.primary)
        }
        .padding(.top, 4)
    }
}
