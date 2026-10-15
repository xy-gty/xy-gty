import SwiftUI
import HiveCueDomain

struct InspectionsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("HiveCue")
                    .font(.largeTitle.bold())
                    .foregroundStyle(HiveCueTheme.primary)

                Text("AI hive-inspection coach — brood frames, stores, pest signs.")
                    .font(.subheadline)
                    .foregroundStyle(HiveCueTheme.muted)

                HexCombGrid(
                    labels: appModel.inspections.isEmpty ? ["F1", "F2", "F3", "F4", "F5", "F6"] : appModel.frameLabels,
                    selectedIndex: appModel.currentFrameIndex,
                    onSelect: { appModel.selectFrame($0) }
                )

                if appModel.inspections.isEmpty {
                    VStack(spacing: 14) {
                        Text("Empty inspection rack")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(HiveCueTheme.ink)
                        Text("Start a hive inspection, then capture or import a brood frame.")
                            .font(.body)
                            .foregroundStyle(HiveCueTheme.muted)
                            .multilineTextAlignment(.center)
                        Button("New inspection") {
                            appModel.push(.newInspection)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(HiveCueTheme.primary)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(HiveCueTheme.card)
                    )
                } else {
                    Button {
                        appModel.push(.newInspection)
                    } label: {
                        Label("New inspection", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(HiveCueTheme.primary)

                    ForEach(appModel.inspections, id: \.id) { inspection in
                        Button {
                            appModel.openInspection(inspection)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(inspection.hiveLabel)
                                        .font(.headline)
                                        .foregroundStyle(HiveCueTheme.ink)
                                    Text("Frame \(inspection.currentFrameLabel) · \(inspection.inspectedAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundStyle(HiveCueTheme.muted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(HiveCueTheme.accent)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(HiveCueTheme.card)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(HiveCueTheme.primary)
                }
            }
            .padding(20)
        }
        .hiveCueScreen()
        .navigationTitle("Inspections")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NewInspectionView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Form {
            Section("Hive") {
                TextField("Hive label", text: $appModel.newHiveLabel)
                    .textInputAutocapitalization(.words)
            }
            Section {
                Button("Start inspection") {
                    appModel.createInspection()
                }
                .tint(HiveCueTheme.primary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(HiveCueTheme.secondary.ignoresSafeArea())
        .navigationTitle("New inspection")
    }
}
