import SwiftUI

struct DictateShotView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Speak a shot-size instruction (e.g. “switch to medium shot”).")
                .foregroundStyle(FrameCueTheme.ink)
                .multilineTextAlignment(.center)

            if appModel.speechBusy {
                ProgressView("Listening…")
            } else {
                Button {
                    Task { await appModel.dictateShot() }
                } label: {
                    Label("Record", systemImage: "mic.circle.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(FrameCueTheme.primary)
            }

            if !appModel.speechTranscript.isEmpty {
                Text("Transcript: \(appModel.speechTranscript)")
                    .font(.callout)
                    .foregroundStyle(FrameCueTheme.muted)
            }

            if let status = appModel.statusMessage {
                Text(status).font(.footnote).foregroundStyle(FrameCueTheme.muted)
            }

            Spacer()
        }
        .padding(20)
        .frameCueScreen()
        .navigationTitle("Dictate shot")
    }
}
