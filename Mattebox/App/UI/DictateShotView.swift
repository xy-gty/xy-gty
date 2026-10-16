import SwiftUI

struct DictateShotView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Speak a shot-size instruction (e.g. “switch to medium shot”).")
                .foregroundStyle(MatteboxTheme.ink)
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
                .tint(MatteboxTheme.primary)
            }

            if !appModel.speechTranscript.isEmpty {
                Text("Transcript: \(appModel.speechTranscript)")
                    .font(.callout)
                    .foregroundStyle(MatteboxTheme.muted)
            }

            if let status = appModel.statusMessage {
                Text(status).font(.footnote).foregroundStyle(MatteboxTheme.muted)
            }

            Spacer()
        }
        .padding(20)
        .matteboxScreen()
        .navigationTitle("Dictate shot")
    }
}
