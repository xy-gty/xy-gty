import SwiftUI

struct SessionCoachView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let session = appModel.activeSession {
                    Text(session.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(FormCueTheme.primary)

                    IntervalChipRail(
                        blocks: appModel.chipLabels,
                        currentIndex: appModel.currentBlockIndex
                    ) { idx in
                        appModel.selectBlock(idx)
                    }

                    RestRing(
                        phaseLabel: session.currentBlockLabel,
                        secondsRemaining: appModel.ringSecondsRemaining,
                        totalSeconds: appModel.ringTotalSeconds,
                        isRest: appModel.ringIsRest
                    )

                    PolaroidFormStrip(
                        titles: appModel.polaroidTitles,
                        selectedIndex: appModel.selectedPolaroidIndex
                    ) { idx in
                        appModel.selectedPolaroidIndex = idx
                        appModel.push(.annotatedForm)
                    }

                    if let status = appModel.statusMessage {
                        Text(status)
                            .font(.footnote)
                            .foregroundStyle(FormCueTheme.ink)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        coachButton("Ask coach", icon: "bubble.left.fill") {
                            appModel.push(.coachChat)
                        }
                        coachButton("Hands-free", icon: "speaker.wave.2.fill") {
                            appModel.push(.handsFreeTTS)
                        }
                        coachButton("Annotate", icon: "pencil.tip.crop.circle") {
                            appModel.push(.annotatedForm)
                        }
                        coachButton("Dictate", icon: "mic.fill") {
                            appModel.push(.dictateIntent)
                        }
                        coachButton("Capture form", icon: "camera.fill") {
                            appModel.push(.captureImport)
                        }
                        coachButton(appModel.ringIsRest ? "Skip rest" : "Start ring", icon: "timer") {
                            if appModel.ringIsRest {
                                appModel.skipRest()
                            } else {
                                appModel.startRingCountdown()
                            }
                        }
                    }
                } else {
                    Text("Open or create a session from Sessions.")
                        .foregroundStyle(FormCueTheme.muted)
                }
            }
            .padding(20)
        }
        .formCueScreen()
        .navigationTitle("Coach")
    }

    private func coachButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(FormCueTheme.primary)
    }
}
