import SwiftUI
import SnagCueDomain
import UIKit

struct AnnotatedReportView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Annotated report")
                    .font(.title2.weight(.bold))
                Text("Uses selected punch labels over a walkthrough photo. Guidance only — not certification.")
                    .foregroundStyle(.secondary)
                if let msg = model.statusMessage {
                    StatusBanner(message: msg)
                }
                if model.reportBusy {
                    ProgressView("Generating…")
                }
                if let path = model.lastReportPreviewPath,
                   let image = UIImage(contentsOfFile: path) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    HStack {
                        Button(AnnotatedReportPreview.confirm) { model.useReportDraft() }
                            .buttonStyle(.borderedProminent)
                        Button(AnnotatedReportPreview.reject) { model.discardReportDraft() }
                    }
                }
                PrimaryCTA(title: "Generate annotated report", systemImage: "photo.badge.plus") {
                    model.generateAnnotatedReport()
                }
                if !model.reportDrafts.isEmpty {
                    Text("Saved reports: \(model.reportDrafts.count)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(SnagTheme.background.ignoresSafeArea())
        .navigationTitle("Annotated report")
    }
}
