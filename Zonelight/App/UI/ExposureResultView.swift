import SwiftUI
import ZonelightDomain

struct ExposureResultView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()
                OversizedEVReadoutBar(evText: appModel.evDisplay, shimmer: appModel.identifyBusy)
                ZoneSystemDialView(selectedZone: appModel.selectedZone) { zone in
                    appModel.selectZone(zone)
                    appModel.editZoneText = zone
                }
                SpotMeterCrossCard(
                    crossX: appModel.activeSpot?.crossX ?? 0.5,
                    crossY: appModel.activeSpot?.crossY ?? 0.5,
                    zoneHint: appModel.activeSpot?.zoneHint ?? appModel.selectedZone,
                    empty: appModel.activeSpot == nil
                )

                if let exposure = appModel.activeExposure {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exposure ID")
                            .font(.headline)
                        Text("\(exposure.aperture) · \(exposure.shutter) · ISO \(exposure.iso)")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(ZonelightTheme.primary)
                        Text(exposure.rationale)
                            .font(.subheadline)
                            .foregroundStyle(ZonelightTheme.muted)
                        HStack {
                            TextField("Edit EV", text: $appModel.editEVText)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .accessibilityLabel("Edit EV")
                            TextField("Edit zone", text: $appModel.editZoneText)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityLabel("Edit zone")
                        }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(ZonelightTheme.card))
                }

                Button {
                    appModel.requestIdentify()
                } label: {
                    Label(appModel.identifyBusy ? "Identifying…" : "Identify Exposure", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(ZonelightTheme.primary)
                .disabled(appModel.identifyBusy)

                HStack {
                    Button("Save Reading") { appModel.saveReading() }
                        .buttonStyle(.borderedProminent)
                        .tint(ZonelightTheme.accent)
                    Button("Keep") { appModel.keepExposure() }
                        .buttonStyle(.bordered)
                    Button("Use") { appModel.useExposure() }
                        .buttonStyle(.bordered)
                    Button("Dismiss") { appModel.dismissID() }
                        .buttonStyle(.bordered)
                }

                HStack {
                    Button("Ask Coach") { appModel.push(.coachChat) }
                    Button("Meter Card") { appModel.openMeterCard() }
                    Button("Speak Callout") { appModel.playSetCallout() }
                }
                .buttonStyle(.bordered)

                if let message = appModel.statusMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(appModel.statusIsError ? .red : ZonelightTheme.ink)
                }
            }
            .padding(20)
        }
        .luxScreen()
        .navigationTitle("Exposure")
        .navigationBarTitleDisplayMode(.inline)
    }
}
