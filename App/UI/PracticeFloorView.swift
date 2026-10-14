import SwiftUI

struct PracticeFloorView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(appModel.currentStepTitle)
                    .font(.title2.bold())
                if !appModel.currentStepTip.isEmpty {
                    Text(appModel.currentStepTip)
                        .foregroundStyle(PitchCueTheme.muted)
                }

                PracticeStripView(
                    steps: appModel.planSteps,
                    currentIndex: appModel.currentStepIndex
                ) { index in
                    appModel.currentStepIndex = index
                }

                WaveformView(levels: appModel.audioBed.waveform)
                    .frame(height: 64)

                HStack(spacing: 12) {
                    Button("Count-in") {
                        appModel.speakCountIn()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(PitchCueTheme.violet)
                    .disabled(appModel.confirmedPlan == nil)
                    .accessibilityLabel("Count-in")

                    if appModel.tts.isSpeaking {
                        Button("Stop speech") { appModel.stopSpeech() }
                            .buttonStyle(.bordered)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Audio bed")
                        .font(.headline)
                    Picker("Bed", selection: $appModel.audioBed.kind) {
                        Text("Drone").tag(AudioBedEngine.Kind.drone)
                        Text("Metronome").tag(AudioBedEngine.Kind.metronome)
                    }
                    .pickerStyle(.segmented)
                    if appModel.audioBed.kind == .drone {
                        HStack {
                            Text("Pitch Hz")
                            Slider(value: $appModel.audioBed.pitchHz, in: 110 ... 880)
                            Text("\(Int(appModel.audioBed.pitchHz))")
                                .monospacedDigit()
                        }
                    } else {
                        HStack {
                            Text("BPM")
                            Slider(value: $appModel.audioBed.bpm, in: 40 ... 200)
                            Text("\(Int(appModel.audioBed.bpm))")
                                .monospacedDigit()
                        }
                    }
                    Button(appModel.audioBed.isPlaying ? "Stop bed" : "Play bed") {
                        appModel.toggleAudioBed()
                    }
                    .buttonStyle(.bordered)
                    .tint(PitchCueTheme.mint)
                }
                .padding()
                .background(PitchCueTheme.softCloud)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button("Pitch check") {
                    appModel.startPitchCheck()
                }
                .buttonStyle(.bordered)
                .tint(PitchCueTheme.violet)

                if let status = appModel.statusMessage {
                    Text(status).font(.footnote).foregroundStyle(PitchCueTheme.muted)
                }
            }
            .padding(20)
        }
        .pitchCueScreen()
        .navigationTitle("Practice floor")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if appModel.audioBed.isPlaying {
                appModel.audioBed.stop()
            }
        }
    }
}
