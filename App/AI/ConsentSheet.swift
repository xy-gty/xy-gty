import SwiftUI
import AirspanDomain

/// First-use DeepSeek data-sharing consent (`airspan.consent.v1`).
struct ConsentSheet: View {
    @EnvironmentObject private var model: AppModel
    @State private var showDeepSeekPolicy = false

    private let outboundFields = AirspanConsentFacade.outboundFieldAllowlist

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    outboundList
                    policyLink
                    actions
                }
                .padding(24)
            }
            .background(Color(red: 0.94, green: 0.98, blue: 1.0))
            .navigationTitle("AI data sharing")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDeepSeekPolicy) {
                LocalLegalWebView(page: .deepseekPrivacy)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Share with \(AirspanIdentity.aiProvider)")
                .font(.title2.bold())
                .foregroundStyle(Color(red: 0.05, green: 0.45, blue: 0.56))
            Text("Disclosure \(AirspanIdentity.consentDisclosureVersion)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(
                "Airspan sends the fields below to DeepSeek for duct photo recognition and sizing coach replies. " +
                    "Declining keeps local jobs, diagrams, and formula demos on this device."
            )
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var outboundList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Outbound fields")
                .font(.headline)
            ForEach(outboundFields, id: \.self) { field in
                Label(field, systemImage: "arrow.up.circle")
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 12))
    }

    private var policyLink: some View {
        Button {
            showDeepSeekPolicy = true
        } label: {
            Label("DeepSeek provider policy", systemImage: "doc.text")
                .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(.borderless)
        .foregroundStyle(Color(red: 0.05, green: 0.45, blue: 0.56))
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                model.grantConsentFromSheet()
            } label: {
                Text("Allow")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.96, green: 0.62, blue: 0.04))

            Button {
                model.declineConsentFromSheet()
            } label: {
                Text("Not now")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}
