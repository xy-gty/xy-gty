import SwiftUI
import DocBriefDomain

struct HomeView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack {
            DocBriefTheme.paper.ignoresSafeArea()
            if model.briefs.isEmpty {
                VStack(spacing: 20) {
                    Text("DocBrief AI")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(DocBriefTheme.teal)
                    Text("Turn document, whiteboard, and receipt photos into reviewed action briefs.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(DocBriefTheme.ink.opacity(0.75))
                        .padding(.horizontal)
                    NavigationLink(value: BriefRoute.newBrief) {
                        Text("Start brief")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(DocBriefTheme.amber)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding()
            } else {
                List {
                    ForEach(model.briefs) { brief in
                        Button {
                            model.selectBrief(brief.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(brief.title)
                                    .font(.headline)
                                    .foregroundStyle(DocBriefTheme.ink)
                                Text(brief.recognizedType ?? "Type pending")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Briefs")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: BriefRoute.newBrief) {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(for: BriefRoute.self) { route in
            switch route {
            case .newBrief: NewBriefView()
            default: EmptyView()
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let message = model.statusMessage {
                Text(message)
                    .font(.footnote)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(DocBriefTheme.mist)
            }
        }
    }
}
