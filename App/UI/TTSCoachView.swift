import SwiftUI

struct TTSCoachView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Checklist coach")
                .font(.title2.weight(.bold))
            Text("Hands-free readout of saved punch items. Offline — no outbound AI.")
                .foregroundStyle(.secondary)

            if let msg = model.statusMessage {
                StatusBanner(message: msg)
            }

            if let session = model.coach, model.activePunchItems.indices.contains(session.stepIndex) {
                let item = model.activePunchItems[session.stepIndex]
                VStack(alignment: .leading, spacing: 8) {
                    Text("Item \(session.stepIndex + 1) of \(model.activePunchItems.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.title).font(.title3.weight(.semibold))
                    Text(item.location.isEmpty ? "Location unspecified" : item.location)
                    Text("Severity \(item.severity)")
                    if session.isPlaying {
                        Label("Playing", systemImage: "speaker.wave.2.fill")
                            .foregroundStyle(SnagTheme.steel)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SnagTheme.panel)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("Press Play to begin.")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Play") { model.startCoach() }
                    .buttonStyle(.borderedProminent)
                Button("Pause") { model.pauseCoach() }
                Button("Next") { model.nextCoachStep() }
                Button("Replay") { model.replayCoachStep() }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(SnagTheme.background.ignoresSafeArea())
        .navigationTitle("TTS coach")
    }
}
