import SwiftUI
import CellarCueDomain

struct RackCardView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()

                Text("Annotated rack card")
                    .font(.title2.bold())
                    .foregroundStyle(CellarCueTheme.ink)

                ForEach(Array(appModel.draftCallouts.enumerated()), id: \.offset) { idx, callout in
                    HStack(alignment: .top) {
                        Text("•")
                            .foregroundStyle(CellarCueTheme.accent)
                        TextField("Callout", text: binding(at: idx))
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Button("Add callout") {
                    appModel.draftCallouts.append("New pull note")
                }
                .foregroundStyle(CellarCueTheme.primary)

                HStack {
                    Button("Keep") { appModel.keepRackCard() }
                        .buttonStyle(.borderedProminent)
                        .tint(CellarCueTheme.accent)
                    Button("Edit bin") { }
                        .buttonStyle(.bordered)
                    Button("Dismiss") { appModel.rejectRackCardDraft() }
                        .buttonStyle(.bordered)
                }
            }
            .padding(16)
        }
        .cellarScreen()
        .navigationTitle("Rack card")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func binding(at index: Int) -> Binding<String> {
        Binding(
            get: {
                guard appModel.draftCallouts.indices.contains(index) else { return "" }
                return appModel.draftCallouts[index]
            },
            set: { newValue in
                guard appModel.draftCallouts.indices.contains(index) else { return }
                appModel.draftCallouts[index] = newValue
            }
        )
    }
}
