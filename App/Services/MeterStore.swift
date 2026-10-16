import Foundation
import ZonelightDomain
import AppRuntimeCore

struct MeterStore {
    private let store: AtomicCodableStore<ZonelightState>

    init(directory: URL) {
        store = ZonelightStores.meterStore(directory: directory)
    }

    func load() throws -> ZonelightState {
        try store.load() ?? ZonelightState()
    }

    func save(_ state: ZonelightState) throws {
        try store.save(state)
    }
}

enum ZonelightComplianceCopy {
    static func ensureDisclaimers(_ text: String) -> String {
        var out = text
        for line in ZonelightCompliance.requiredDisclaimers {
            if !out.contains(line) {
                out += (out.isEmpty || out.hasSuffix(".") ? " " : ". ") + line
            }
        }
        return out
    }

    static func makeCalloutScript(exposure: ExposureID, zone: String) -> String {
        let core = "Set EV \(String(format: "%.1f", exposure.ev)), aperture \(exposure.aperture), shutter \(exposure.shutter), ISO \(exposure.iso). Zone \(zone)."
        return ensureDisclaimers(core)
    }

    static func localCoachTip(question: String, zone: String, exposure: ExposureID?) -> String {
        let ev = exposure.map { String(format: "%.1f", $0.ev) } ?? "—"
        let base = "Local tip for “\(question)”: keep Zone \(zone.isEmpty ? "V" : zone) skin reference near EV \(ev). Film bias favors denser shadows; digital favors highlight retention."
        return ensureDisclaimers(base)
    }
}
