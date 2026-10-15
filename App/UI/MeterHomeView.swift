import SwiftUI
import PhotosUI
import LuxCueDomain

struct MeterHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ComplianceBanner()

                HStack {
                    Text("LuxCue")
                        .font(.largeTitle.bold())
                        .foregroundStyle(LuxCueTheme.primary)
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
                    .foregroundStyle(LuxCueTheme.muted)

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
                    .tint(LuxCueTheme.primary)
                    .accessibilityIdentifier("SpotButton")

                    PhotosPicker(selection: $appModel.selectedPhotoItem, matching: .images) {
                        Label("Import", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(LuxCueTheme.accent)
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
                        .tint(LuxCueTheme.accent)
                    }
                }

                if let message = appModel.statusMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(appModel.statusIsError ? .red : LuxCueTheme.ink)
                }

                if let reason = appModel.aiUnavailableReason {
                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(LuxCueTheme.muted)
                }

                if !appModel.state.sessions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent sessions")
                            .font(.headline)
                            .foregroundStyle(LuxCueTheme.ink)
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
                                        .foregroundStyle(LuxCueTheme.muted)
                                }
                                .padding(10)
                                .background(RoundedRectangle(cornerRadius: 10).fill(LuxCueTheme.card))
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
