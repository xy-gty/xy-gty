import SwiftUI

struct ProjectCoachView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let project = appModel.activeProject {
                    Text(project.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(YarnCueTheme.fuchsia)

                    YarnBallSwatchStrip(hexes: project.yarnSwatchHexes)

                    NextRowStepBand(
                        cues: appModel.stepLabels,
                        currentIndex: appModel.currentStepIndex
                    ) { idx in
                        appModel.selectStep(idx)
                    }

                    if let status = appModel.statusMessage {
                        Text(status)
                            .font(.footnote)
                            .foregroundStyle(YarnCueTheme.ink)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        coachButton("Ask coach", icon: "bubble.left.fill") {
                            appModel.push(.coachChat)
                        }
                        coachButton("Hands-free", icon: "speaker.wave.2.fill") {
                            appModel.push(.handsFreeTTS)
                        }
                        coachButton("Annotate", icon: "pencil.tip.crop.circle") {
                            appModel.push(.annotatedWIP)
                        }
                        coachButton("Dictate", icon: "mic.fill") {
                            appModel.push(.dictateNote)
                        }
                        coachButton("Capture WIP", icon: "camera.fill") {
                            appModel.push(.captureImport)
                        }
                    }
                } else {
                    Text("Open or create a project from Projects.")
                        .foregroundStyle(YarnCueTheme.muted)
                }
            }
            .padding(20)
        }
        .yarnCueScreen()
        .navigationTitle("Coach")
    }

    private func coachButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(YarnCueTheme.fuchsia)
    }
}
