import SwiftUI
import PhotosUI
import ZonelightDomain

struct MeterHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()

                HStack {
                    Text("Zonelight")
                        .font(.largeTitle.bold())
                        .foregroundStyle(ZonelightTheme.primary)
                    Spacer()
                    Button {
                        appModel.push(.settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityIdentifier("Settings")
                }

                Text("AI exposure coach — spot meter or import a still.")
                    .font(.subheadline)
                    .foregroundStyle(ZonelightTheme.muted)

                OversizedEVReadoutBar(evText: appModel.evDisplay, shimmer: appModel.identifyBusy)

                ZoneSystemDialView(selectedZone: appModel.selectedZone) { zone in
                    appModel.selectZone(zone)
                }

                SpotMeterCrossCard(
                    crossX: appModel.activeSpot?.crossX ?? 0.5,
                    crossY: appModel.activeSpot?.crossY ?? 0.5,
                    zoneHint: appModel.activeSpot?.zoneHint ?? "",
                    empty: appModel.activeSpot == nil
                )

                HStack(spacing: 12) {
                    Button {
                        appModel.showCamera = true
                    } label: {
                        Label("Spot", systemImage: "viewfinder")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ZonelightTheme.primary)
                    .accessibilityIdentifier("SpotButton")

                    PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                        Label("Import", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(ZonelightTheme.accent)
                    .accessibilityIdentifier("ImportButton")
                }

                HStack(spacing: 12) {
                    Button("Voice note") {
                        appModel.showVoiceNote = true
                    }
                    .buttonStyle(.bordered)
                    if appModel.activeSession != nil {
                        Button("Open result") {
                            appModel.push(.exposureResult)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(ZonelightTheme.accent)
                    }
                }

                if let message = appModel.statusMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(appModel.statusIsError ? .red : ZonelightTheme.ink)
                }

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(ZonelightTheme.muted)
                }

                if !appModel.state.sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent sessions")
                            .font(.headline)
                            .foregroundStyle(ZonelightTheme.ink)
                        ForEach(appModel.state.sessions.prefix(5), id: \.id) { session in
                            Button {
                                appModel.activeSessionId = session.id
                                if let dial = appModel.state.zoneDialStates.first(where: { $0.sessionId == session.id }) {
                                    appModel.selectedZone = dial.selectedZone
                                }
                                appModel.push(.exposureResult)
                            } label: {
                                HStack {
                                    Text(session.source.capitalized)
                                    Spacer()
                                    Text(session.status)
                                        .font(.caption)
                                        .foregroundStyle(ZonelightTheme.muted)
                                }
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(ZonelightTheme.card))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)
        }
        .luxScreen()
        .navigationBarHidden(true)
    }
}
