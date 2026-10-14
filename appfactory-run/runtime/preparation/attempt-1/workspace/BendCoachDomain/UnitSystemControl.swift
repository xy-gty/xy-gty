import Foundation

/// UnitSystemControl: Settings + first-run explanation; persisted via UnitPreference store.
public enum UnitSystemControl {
    public static let imperialBadge = "Imperial"
    public static let metricBadge = "Metric"

    public static func badge(for system: UnitSystem) -> String {
        switch system {
        case .imperial: return imperialBadge
        case .metric: return metricBadge
        }
    }

    public static func firstExplanation(for system: UnitSystem) -> String {
        switch system {
        case .imperial:
            return "Measurements use inches and feet. Switch to Metric anytime in Settings → Units."
        case .metric:
            return "Measurements use millimeters and meters. Switch to Imperial anytime in Settings → Units."
        }
    }

    public static func load(storage: BendCoachStorageRoot) throws -> UnitPreference {
        try storage.unitPreference.load() ?? UnitPreference()
    }

    public static func save(_ preference: UnitPreference, storage: BendCoachStorageRoot) throws {
        var next = preference
        next.updatedAt = Date()
        try storage.unitPreference.save(next)
    }

    public static func setUnitSystem(_ system: UnitSystem, storage: BendCoachStorageRoot) throws -> UnitPreference {
        var preference = try load(storage: storage)
        preference.unitSystem = system
        preference.updatedAt = Date()
        try storage.unitPreference.save(preference)
        return preference
    }

    public static func markFirstExplanationSeen(storage: BendCoachStorageRoot) throws -> UnitPreference {
        var preference = try load(storage: storage)
        preference.firstExplanationSeen = true
        preference.updatedAt = Date()
        try storage.unitPreference.save(preference)
        return preference
    }
}
