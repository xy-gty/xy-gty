import Foundation
import LuxCueDomain
import AppRuntimeCore

struct MeterStore {
    private let store: AtomicCodableStore<LuxCueState>

    init(directory: URL) {
        store = LuxCueStores.meterStore(directory: directory)
    }

    func load() throws -> LuxCueState {
        try store.load() ?? LuxCueState()
    }

    func save(_ state: LuxCueState) throws {
        try store.save(state)
    }
}

enum LuxCueComplianceCopy {
    static func ensureDisclaimers(_ text: String) -> String {
        var out = text
        for line in LuxCueCompliance.requiredDisclaimers {
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
