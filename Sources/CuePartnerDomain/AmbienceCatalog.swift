import Foundation

public enum AmbienceCatalog {
    public static let presets: [AmbiencePreset] = [
        AmbiencePreset(id: "off", displayName: "Off"),
        AmbiencePreset(id: "quiet_stage", displayName: "Quiet stage"),
        AmbiencePreset(id: "soft_murmur", displayName: "Soft murmur"),
        AmbiencePreset(id: "rain_wings", displayName: "Rain wings"),
    ]

    public static func displayName(for id: String?) -> String {
        guard let id else { return "Off" }
        return presets.first(where: { $0.id == id })?.displayName ?? "Off"
    }
}
