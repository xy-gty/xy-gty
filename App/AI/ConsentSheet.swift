import SwiftUI
import KnotCueDomain

struct ConsentSheet: View {
    @EnvironmentObject private var model: AppModel
    @State private var showDeepSeekPolicy = false
    private let outboundFields = KnotCueConsentFacade.outboundFieldAllowlist

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Share with \(KnotCueIdentity.aiProvider)")
                        .font(.title2.bold())
                        .foregroundStyle(KnotCueTheme.primary)
                    Text("Disclosure \(KnotCueIdentity.consentDisclosureVersion)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("KnotCue may send the fields below to DeepSeek for knot stage recognition and next-haul coaching. Declining keeps the rope carousel, overlays, and local demos on this device.")
                        .font(.body)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Outbound fields").font(.headline)
                        ForEach(outboundFields, id: \.self) { field in
                            Label(field, systemImage: "arrow.up.circle").font(.subheadline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(KnotCueTheme.surface.opacity(0.9), in: RoundedRectangle(cornerRadius: 12))
                    Button { showDeepSeekPolicy = true } label: {
                        Label("DeepSeek provider policy", systemImage: "doc.text")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(KnotCueTheme.accent)
                    Text(KnotCueIdentity.coachingDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(KnotCueTheme.primary)
                    Button { model.grantConsentFromSheet() } label: {
                        Text("Allow").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(KnotCueTheme.accent)
                    Button { model.declineConsentFromSheet() } label: {
                        Text("Not now").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(24)
            }
            .background(KnotCueTheme.secondary)
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDeepSeekPolicy) {
                LocalLegalWebView(page: .deepseekPrivacy)
            }
        }
        .presentationDetents([.medium, .large])
    }
}
