import SwiftUI
import BroodcheckDomain

struct InspectionsHomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Broodcheck")
                    .font(.largeTitle.bold())
                    .foregroundStyle(BroodcheckTheme.primary)

                Text("AI hive-inspection coach — brood frames, stores, pest signs.")
                    .font(.subheadline)
                    .foregroundStyle(BroodcheckTheme.muted)

                HexCombGrid(
                    labels: appModel.inspections.isEmpty ? ["F1", "F2", "F3", "F4", "F5", "F6"] : appModel.frameLabels,
                    selectedIndex: appModel.currentFrameIndex,
                    onSelect: { appModel.selectFrame($0) }
                )

                if appModel.inspections.isEmpty {
                    VStack(spacing: 14) {
                        Text("Empty inspection rack")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(BroodcheckTheme.ink)
                        Text("Start a hive inspection, then capture or import a brood frame.")
                            .font(.body)
                            .foregroundStyle(BroodcheckTheme.muted)
                            .multilineTextAlignment(.center)
                        Button("New inspection") {
                            appModel.push(.newInspection)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BroodcheckTheme.primary)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(BroodcheckTheme.card)
                    )
                } else {
                    Button {
                        appModel.push(.newInspection)
                    } label: {
                        Label("New inspection", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BroodcheckTheme.primary)

                    ForEach(appModel.inspections, id: \.id) { inspection in
                        Button {
                            appModel.openInspection(inspection)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(inspection.hiveLabel)
                                        .font(.headline)
                                        .foregroundStyle(BroodcheckTheme.ink)
                                    Text("Frame \(inspection.currentFrameLabel) · \(inspection.inspectedAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundStyle(BroodcheckTheme.muted)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(BroodcheckTheme.accent)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(BroodcheckTheme.card)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if let status = appModel.statusMessage {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(BroodcheckTheme.primary)
                }
            }
            .padding(20)
        }
        .broodcheckScreen()
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
                .tint(BroodcheckTheme.primary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(BroodcheckTheme.secondary.ignoresSafeArea())
        .navigationTitle("New inspection")
    }
}
