import SwiftUI
import BendCoachDomain

struct JobDetailView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            BendCoachTheme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(model.activeJob?.title.isEmpty == false ? (model.activeJob?.title ?? "Job") : "Field bend job")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(BendCoachTheme.ink)

                    Text("Units: \(model.unitBadge)")
                        .foregroundStyle(BendCoachTheme.muted)

                    Group {
                        NavigationLink(value: CoachRoute.bendMathChat) {
                            row("Ask bend math", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        NavigationLink(value: CoachRoute.captureImport) {
                            row("Capture / import photo", systemImage: "camera.fill")
                        }
                        NavigationLink(value: CoachRoute.bendReview) {
                            row("Review bend marks", systemImage: "pencil.and.outline")
                        }
                        Button { model.generateDiagram() } label: {
                            row("Generate diagram", systemImage: "square.stack.3d.up")
                        }
                        NavigationLink(value: CoachRoute.diagramOverlay) {
                            row("Diagram preview", systemImage: "eye")
                        }
                        Button { model.prepareCoaching() } label: {
                            row("Start coaching", systemImage: "speaker.wave.2.fill")
                        }
                        NavigationLink(value: CoachRoute.ttsCoaching) {
                            row("TTS coaching player", systemImage: "list.number")
                        }
                    }

                    if !model.activeMarkups.isEmpty {
                        Text("Saved marks")
                            .font(.headline)
                            .foregroundStyle(BendCoachTheme.ink)
                        ForEach(model.activeMarkups) { m in
                            Text("\(m.bendType) · \(m.keyDimensions.count) hints")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(BendCoachTheme.surface)
                                .foregroundStyle(BendCoachTheme.ink)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    if let msg = model.statusMessage {
                        Text(msg).font(.footnote).foregroundStyle(BendCoachTheme.muted)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Job")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New job") { model.startBendJob() }
            }
        }
    }

    private func row(_ title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(BendCoachTheme.muted)
        }
        .padding()
        .background(BendCoachTheme.surface)
        .foregroundStyle(BendCoachTheme.ink)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
