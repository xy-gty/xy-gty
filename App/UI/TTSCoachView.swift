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

            if model.activePunchItems.isEmpty {
                Text("Add punch items on Active punch before coaching.")
                    .foregroundStyle(.secondary)
            } else {
                let currentIndex = model.coach?.stepIndex ?? -1
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(model.activePunchItems.enumerated()), id: \.element.id) { index, item in
                            let isCurrent = index == currentIndex
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Item \(index + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(item.title).font(.headline)
                                Text(item.location.isEmpty ? "Location unspecified" : item.location)
                                    .font(.subheadline)
                                Text("Severity \(item.severity)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if isCurrent, model.coach?.isPlaying == true {
                                    Label("Playing", systemImage: "speaker.wave.2.fill")
                                        .foregroundStyle(SnagTheme.safety)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(isCurrent ? SnagTheme.safety.opacity(0.22) : SnagTheme.panel)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(isCurrent ? SnagTheme.safety : Color.clear, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
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
