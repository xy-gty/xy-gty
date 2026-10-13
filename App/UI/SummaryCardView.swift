import SwiftUI
import DocBriefDomain

struct SummaryCardView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Button("Generate summary card") {
                    model.runSummaryCard()
                }
                .buttonStyle(.borderedProminent)
                .tint(DocBriefTheme.amber)

                if model.summaryBusy {
                    ProgressView("Generating…")
                }

                if let draft = model.pendingSummary ?? model.activeSummary {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(draft.headline)
                            .font(.title2.weight(.bold))
                        Text(draft.body)
                        Text(DocBriefIdentity.nonCertificationDisclaimer)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DocBriefTheme.mist)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    if model.pendingSummary != nil {
                        HStack {
                            Button(DocBriefReviewControls.SummaryCardPreview.confirm) {
                                model.useSummaryCard()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(DocBriefTheme.teal)
                            Button(DocBriefReviewControls.SummaryCardPreview.reject) {
                                model.discardSummaryCard()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } else if let reason = model.aiUnavailableReason {
                    Text(reason)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(DocBriefTheme.paper.ignoresSafeArea())
        .navigationTitle("Summary card")
    }
}
