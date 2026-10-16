import SwiftUI
import UIKit
import AirspanDomain

struct SizeDiagramView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let diagram = model.pendingDiagram {
                    diagramPreview(diagram)
                    Text("Preview isometric size diagram before saving locally.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    VStack(spacing: 10) {
                        Button(AirspanReviewControls.SizeDiagramPreview.confirm) {
                            model.savePendingDiagram()
                        }
                        .buttonStyle(AirspanTheme.PrimaryButtonStyle())

                        Button(AirspanReviewControls.SizeDiagramPreview.reject) {
                            model.discardPendingDiagram()
                        }
                        .buttonStyle(AirspanTheme.SecondaryButtonStyle())

                        Button("Field steps") {
                            model.openFieldSteps(for: diagram)
                        }
                        .buttonStyle(AirspanTheme.SecondaryButtonStyle())
                    }
                } else {
                    ContentUnavailableView(
                        "No pending diagram",
                        systemImage: "square.3.layers.3d.slash"
                    )
                }
            }
            .padding()
        }
        .background(AirspanTheme.secondary.ignoresSafeArea())
        .navigationTitle("Size diagram")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func diagramPreview(_ diagram: SizeDiagram) -> some View {
        let url = model.storage.diagramFileURL(for: diagram)
        if let ui = UIImage(contentsOfFile: url.path) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            IsometricDuctCanvas(accentChip: model.sizeChips.first)
        }
    }
}
