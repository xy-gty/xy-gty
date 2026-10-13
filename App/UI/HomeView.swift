import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var model: AppModel
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("SnagCue AI")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(SnagTheme.ink)
                    Text("Turn walkthrough photos into a reviewed punch list. Guidance only — not certification.")
                        .foregroundStyle(.secondary)

                    if let msg = model.statusMessage {
                        StatusBanner(message: msg)
                    }

                    if model.audits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("No audits yet")
                                .font(.title3.weight(.semibold))
                            Text("Start with a site walkthrough. Import photos, review snag drafts, then coach through the list.")
                                .foregroundStyle(.secondary)
                            PrimaryCTA(title: "Start audit", systemImage: "plus.circle.fill") {
                                path.append(SnagRoute.newAudit)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(SnagTheme.panel)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    } else {
                        ForEach(model.audits) { audit in
                            Button {
                                model.selectAudit(audit.id)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(audit.title)
                                        .font(.headline)
                                        .foregroundStyle(SnagTheme.ink)
                                    Text(audit.siteLabel.isEmpty ? "No site label" : audit.siteLabel)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text(audit.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(SnagTheme.panel)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        PrimaryCTA(title: "Start audit", systemImage: "plus.circle.fill") {
                            path.append(SnagRoute.newAudit)
                        }
                    }
                }
                .padding()
            }
            .background(SnagTheme.background.ignoresSafeArea())
            .navigationTitle("Audits")
            .navigationDestination(for: SnagRoute.self) { route in
                switch route {
                case .newAudit: NewAuditView()
                case .capture: CaptureView()
                case .review: SnagRecognitionReviewView()
                case .chat: ChatFillView()
                case .report: AnnotatedReportView()
                case .tts: TTSCoachView()
                }
            }
        }
    }
}
