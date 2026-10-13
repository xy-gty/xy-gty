import SwiftUI
import DocBriefDomain

struct TTSBriefingView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spoken briefing uses only saved local text. No outbound send.")
                .foregroundStyle(.secondary)

            if let session = model.briefingSession,
               session.utterableLines.indices.contains(session.stepIndex) {
                Text(session.utterableLines[session.stepIndex])
                    .font(.title3.weight(.semibold))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DocBriefTheme.mist)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text("Step \(session.stepIndex + 1) of \(session.utterableLines.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Prepare a briefing from the active brief's confirmed fields and actions.")
            }

            HStack(spacing: 12) {
                Button("Play") { model.playBriefingStep() }
                    .buttonStyle(.borderedProminent)
                    .tint(DocBriefTheme.amber)
                Button("Next") { model.nextBriefingStep() }
                    .buttonStyle(.bordered)
                Button("Pause") { model.pauseBriefing() }
                    .buttonStyle(.bordered)
            }

            Button("Rebuild briefing") { model.startBriefing() }
                .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
        .background(DocBriefTheme.paper.ignoresSafeArea())
        .navigationTitle("Speak briefing")
        .onAppear {
            if model.briefingSession == nil {
                model.startBriefing()
            }
        }
    }
}
