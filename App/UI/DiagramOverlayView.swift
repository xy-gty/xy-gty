import SwiftUI
import BendCoachDomain

struct DiagramOverlayView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            BendCoachTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                Text("Diagram overlay")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(BendCoachTheme.ink)

                if model.diagramBusy {
                    ProgressView("Building overlay…").tint(BendCoachTheme.cta)
                }

                ScrollView {
                    Text(model.pendingOverlayHints
                         ?? model.overlays.last.map { overlay in
                            (try? String(contentsOf: model.storage.diagramFileURL(for: overlay), encoding: .utf8)) ?? "Saved overlay"
                         }
                         ?? "Generate a diagram from Job detail first.")
                        .foregroundStyle(BendCoachTheme.ink)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(BendCoachTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(BendCoachTheme.diagram, lineWidth: 2)
                        )
                }

                Text(BendCoachIdentity.assistiveDisclaimer)
                    .font(.footnote)
                    .foregroundStyle(BendCoachTheme.warn)

                if model.pendingOverlay != nil {
                    HStack {
                        Button(BendCoachReviewControls.DiagramPreview.reject) { model.discardDiagram() }
                            .buttonStyle(.bordered)
                        Spacer()
                        Button(BendCoachReviewControls.DiagramPreview.confirm) { model.useDiagram() }
                            .buttonStyle(.borderedProminent)
                            .tint(BendCoachTheme.cta)
                            .accessibilityIdentifier("use_diagram")
                    }
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Diagram")
    }
}
