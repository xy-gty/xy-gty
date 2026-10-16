import PhotosUI
import SwiftUI
import StirboardDomain

struct BarHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Stirboard")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(StirboardTheme.primary)
                Spacer()
                Button {
                    appModel.push(.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(StirboardTheme.primary)
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if let banner = appModel.statusMessage {
                        StatusBanner(text: banner, isError: appModel.statusIsError)
                    }
                    if let reason = appModel.aiUnavailableReason {
                        StatusBanner(text: reason, isError: false)
                    }

                    HStack(alignment: .top, spacing: 12) {
                        BottleRailView(candidates: appModel.sessionCandidates, emptyHint: true)

                        VStack(alignment: .leading, spacing: 12) {
                            NextPourCardView(
                                step: appModel.currentPourStep,
                                isActive: appModel.sessionRecipe != nil,
                                onNext: appModel.sessionRecipe == nil ? nil : { appModel.advancePourStep() },
                                onSpeak: appModel.sessionRecipe == nil ? nil : { appModel.speakCurrentStep() }
                            )
                            GarnishChipRowView(
                                chips: appModel.sessionRecipe?.garnishChips ?? [],
                                onToggle: { appModel.toggleGarnish($0) }
                            )
                        }
                    }
                    .padding(.top, 4)

                    if !appModel.state.sessions.isEmpty {
                        Text("Recent mixes")
                            .font(.headline)
                            .foregroundStyle(StirboardTheme.ink)
                        ForEach(appModel.state.sessions.prefix(6), id: \.id) { session in
                            Button {
                                appModel.activeSessionId = session.id
                                appModel.push(.idResult)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(session.subject.capitalized + " · " + session.source)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(StirboardTheme.ink)
                                        Text(session.status)
                                            .font(.caption)
                                            .foregroundStyle(StirboardTheme.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(StirboardTheme.primary)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(StirboardTheme.cardFace)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 120)
            }

            coachBar
        }
        .stirboardScreen()
        .navigationBarHidden(true)
        .accessibilityIdentifier("BarHome")
    }

    private var coachBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    appModel.showCamera = true
                    appModel.push(.cameraCapture)
                } label: {
                    Label("Shoot", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(StirboardTheme.accent)

                PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                    Label("Import", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .tint(StirboardTheme.primary)
            }

            HStack(spacing: 8) {
                TextField("Ask coach a substitute…", text: $appModel.coachQuestion)
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
                    Image(systemName: appModel.speechService.isListening ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .foregroundStyle(StirboardTheme.primary)
                }
                .accessibilityLabel("Speech question")

                Button {
                    appModel.showVoiceNote = true
                } label: {
                    Image(systemName: "waveform.circle")
                        .font(.title2)
                        .foregroundStyle(StirboardTheme.accent)
                }
                .accessibilityLabel("Voice note")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(StirboardTheme.cardFace.ignoresSafeArea(edges: .bottom))
    }
}
