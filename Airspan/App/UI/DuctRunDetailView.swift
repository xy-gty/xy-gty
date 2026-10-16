import SwiftUI
import UIKit
import AirspanDomain

struct DuctRunDetailView: View {
    @EnvironmentObject private var model: AppModel

    private var run: DuctRun? { model.selectedRun }

    var body: some View {
        ScrollView {
            if let run {
                VStack(alignment: .leading, spacing: 16) {
                    runPhoto(run)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(run.sizeTags.joined(separator: ", "))
                            .font(.title2.bold())
                            .foregroundStyle(AirspanTheme.ink)
                        if let feet = run.lengthFeet {
                            Text("Length \(feet, specifier: "%.0f") ft")
                                .foregroundStyle(.secondary)
                        }
                        Text("Confirmed \(run.confirmedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    actions(for: run)
                }
                .padding()
            } else {
                ContentUnavailableView("Run not found", systemImage: "wind")
            }
        }
        .background(AirspanTheme.secondary.ignoresSafeArea())
        .navigationTitle("Duct run")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func runPhoto(_ run: DuctRun) -> some View {
        let url = model.storage.photoFileURL(for: run)
        if let ui = UIImage(contentsOfFile: url.path) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            IsometricDuctCanvas(accentChip: run.sizeTags.first)
        }
    }

    private func actions(for run: DuctRun) -> some View {
        VStack(spacing: 12) {
            Button("Ask coach with this run") {
                model.selectedRunID = run.id
                model.selectedTab = .coach
            }
            .buttonStyle(AirspanTheme.PrimaryButtonStyle())

            Button("Make size diagram") {
                model.selectedRunID = run.id
                model.makeSizeDiagram()
            }
            .buttonStyle(AirspanTheme.SecondaryButtonStyle())

            Button("Field steps") {
                model.openFieldSteps(run: run)
            }
            .buttonStyle(AirspanTheme.SecondaryButtonStyle())
        }
    }
}
