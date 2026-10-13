import SwiftUI
import DocBriefDomain

struct BriefDetailView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let brief = model.activeBrief {
                    Text(brief.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(DocBriefTheme.ink)
                    Text(brief.recognizedType.map { "Type: \($0)" } ?? "Type pending")
                        .foregroundStyle(.secondary)

                    Group {
                        labeledRow("Photos", "\(model.activePhotos.count)")
                        labeledRow("Fields", "\(model.activeFields.count)")
                        labeledRow("Actions", "\(model.activeActions.count)")
                    }

                    if model.activeFields.isEmpty && model.activeActions.isEmpty {
                        Text("Add photos, recognize fields, or add an action to fill this brief.")
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 10) {
                        navButton("Add photos", route: .importCapture)
                        navButton("Review recognition", route: .recognitionReview)
                        navButton("Chat extract", route: .chatExtract)
                        navButton("Summary card", route: .summaryCard)
                        navButton("Speak briefing", route: .ttsBriefing)
                    }

                    if !model.activeFields.isEmpty {
                        Text("Confirmed fields")
                            .font(.headline)
                        ForEach(model.activeFields) { field in
                            LabeledContent(field.key, value: field.value)
                        }
                    }
                    if !model.activeActions.isEmpty {
                        Text("Confirmed actions")
                            .font(.headline)
                        ForEach(model.activeActions) { item in
                            Text(item.text)
                        }
                    }

                    Text(DocBriefIdentity.nonCertificationDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ContentUnavailableView(
                        "No active brief",
                        systemImage: "doc",
                        description: Text("Start a brief from the Briefs tab.")
                    )
                    NavigationLink(value: BriefRoute.newBrief) {
                        Text("Start brief")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(DocBriefTheme.amber)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                if let message = model.statusMessage {
                    Text(message)
                        .font(.footnote)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DocBriefTheme.mist)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
        }
        .background(DocBriefTheme.paper.ignoresSafeArea())
        .navigationTitle("Active brief")
        .navigationDestination(for: BriefRoute.self) { route in
            switch route {
            case .newBrief: NewBriefView()
            case .importCapture: ImportCaptureView()
            case .recognitionReview: RecognitionReviewView()
            case .chatExtract: ChatExtractView()
            case .summaryCard: SummaryCardView()
            case .ttsBriefing: TTSBriefingView()
            }
        }
    }

    private func labeledRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func navButton(_ title: String, route: BriefRoute) -> some View {
        NavigationLink(value: route) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(DocBriefTheme.teal.opacity(0.12))
                .foregroundStyle(DocBriefTheme.teal)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
