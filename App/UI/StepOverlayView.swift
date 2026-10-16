import SwiftUI
import BightstepDomain

struct StepOverlayView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step annotation overlay")
                .font(.title2.bold())
                .foregroundStyle(BightstepTheme.primary)
            if let overlay = model.pendingOverlay {
                ForEach(Array(overlay.annotationNotes.enumerated()), id: \.offset) { index, note in
                    HStack {
                        Text("\(index + 1)")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(BightstepTheme.accent)
                            .clipShape(Circle())
                        Text(note)
                    }
                }
            }
            Button(BightstepReviewControls.overlayConfirm) { model.savePendingOverlay() }
                .buttonStyle(BightstepTheme.PrimaryButtonStyle())
            Button(BightstepReviewControls.overlayReject) { model.discardPendingOverlay() }
                .buttonStyle(BightstepTheme.SecondaryButtonStyle())
            Spacer()
        }
        .padding(20)
        .background(BightstepTheme.secondary.ignoresSafeArea())
        .navigationTitle("Overlay")
    }
}

struct OverlaysTabView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        List {
            if model.savedOverlays.isEmpty {
                Text("Saved overlays appear here after you tap Save overlay.")
                    .foregroundStyle(.secondary)
            }
            ForEach(model.savedOverlays) { overlay in
                VStack(alignment: .leading, spacing: 6) {
                    Text(overlay.annotationNotes.joined(separator: " · "))
                    Button("Hands-free coach") { model.openHandsFree(for: overlay) }
                }
            }
        }
        .navigationTitle("Overlays")
    }
}
