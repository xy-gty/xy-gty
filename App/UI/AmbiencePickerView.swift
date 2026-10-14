import SwiftUI
import CuePartnerDomain

struct AmbiencePickerView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        List {
            Section("Stage ambience beds") {
                ForEach(AmbienceCatalog.presets, id: \.id) { preset in
                    Button {
                        model.setAmbience(preset.id)
                    } label: {
                        HStack {
                            Text(preset.displayName)
                            Spacer()
                            if model.activeScene?.ambienceId == preset.id ||
                                (preset.id == "off" && (model.activeScene?.ambienceId == nil || model.activeScene?.ambienceId == "off")) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(CueTheme.amber)
                            }
                        }
                    }
                }
            }
            Section {
                Text("Beds are soft local tones and never cover TTS cue lines.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Ambience")
        .safeAreaInset(edge: .bottom) {
            Button("Use bed") {
                model.setAmbience(model.activeScene?.ambienceId ?? "quiet_stage")
            }
            .buttonStyle(.borderedProminent)
            .tint(CueTheme.amber)
            .padding()
        }
    }
}
