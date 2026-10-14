import SwiftUI
import KnotCueDomain

struct StepOverlayView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step annotation overlay")
                .font(.title2.bold())
                .foregroundStyle(KnotCueTheme.primary)
            if let overlay = model.pendingOverlay {
                ForEach(Array(overlay.annotationNotes.enumerated()), id: \.offset) { index, note in
                    HStack {
                        Text("\(index + 1)")
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(KnotCueTheme.accent)
                            .clipShape(Circle())
                        Text(note)
                    }
                }
            }
            Button(KnotCueReviewControls.overlayConfirm) { model.savePendingOverlay() }
                .buttonStyle(KnotCueTheme.PrimaryButtonStyle())
            Button(KnotCueReviewControls.overlayReject) { model.discardPendingOverlay() }
                .buttonStyle(KnotCueTheme.SecondaryButtonStyle())
            Spacer()
        }
        .padding(20)
        .background(KnotCueTheme.secondary.ignoresSafeArea())
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
