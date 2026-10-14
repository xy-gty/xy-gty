import SwiftUI
import BendCoachDomain

struct UnitsSettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Form {
            Section("Unit system") {
                Picker("Units", selection: Binding(
                    get: { model.unitPreference.unitSystem },
                    set: { model.setUnitSystem($0) }
                )) {
                    Text(UnitSystemControl.imperialBadge).tag(UnitSystem.imperial)
                    Text(UnitSystemControl.metricBadge).tag(UnitSystem.metric)
                }
                .pickerStyle(.segmented)
                Text(UnitSystemControl.firstExplanation(for: model.unitPreference.unitSystem))
                    .font(.footnote)
            }
        }
        .scrollContentBackground(.hidden)
        .background(BendCoachTheme.bg.ignoresSafeArea())
        .navigationTitle("Units")
    }
}
