import SwiftUI
import FinishCueDomain

struct HeatHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()

                Text("FinishCue")
                    .font(.largeTitle.bold())
                    .foregroundStyle(FinishCueTheme.primary)

                Text("Snap or import a finish slit, scrub lanes, keep times, chat heat order, and call starts.")
                    .font(.subheadline)
                    .foregroundStyle(FinishCueTheme.muted)

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(FinishCueTheme.muted)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(FinishCueTheme.secondary.opacity(0.8), in: RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    appModel.createHeatPack(title: "Heat \(appModel.state.heatPacks.count + 1)")
                } label: {
                    Label("New heat pack", systemImage: "flag.checkered")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(FinishCueTheme.primary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
                .accessibilityIdentifier("NewHeatPack")

                if appModel.state.heatPacks.isEmpty {
                    VStack(spacing: 8) {
                        Text("No heat packs yet")
                            .font(.title3.weight(.semibold))
                        Text("Start with a practice or amateur-meet finish strip.")
                            .font(.subheadline)
                            .foregroundStyle(FinishCueTheme.muted)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .accessibilityIdentifier("HomeEmpty")
                } else {
                    ForEach(appModel.state.heatPacks, id: \.id) { pack in
                        Button {
                            appModel.openHeat(pack.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(pack.title)
                                    .font(.headline)
                                    .foregroundStyle(FinishCueTheme.ink)
                                Text(pack.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(FinishCueTheme.muted)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.85))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(FinishCueTheme.primary.opacity(0.25), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .finishCueScreen()
        .navigationTitle("Heats")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.push(.settings)
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityIdentifier("SettingsButton")
            }
        }
        .accessibilityIdentifier("HeatHome")
    }
}
