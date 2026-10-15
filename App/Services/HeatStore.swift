import Foundation
import AppRuntimeCore
import FinishCueDomain

final class HeatStore: HeatPackStore {
    private let store: AtomicCodableStore<FinishCueState>

    init(directory: URL) {
        store = FinishCueStores.stateStore(directory: directory)
    }

    func load() throws -> FinishCueState {
        try store.load() ?? FinishCueState()
    }

    func save(_ state: FinishCueState) throws {
        try store.save(state)
    }

    func upsertHeatPack(_ pack: HeatPack) throws {
        var state = try load()
        if let idx = state.heatPacks.firstIndex(where: { $0.id == pack.id }) {
            state.heatPacks[idx] = pack
        } else {
            state.heatPacks.insert(pack, at: 0)
        }
        try save(state)
    }

    func heatPack(id: String) throws -> HeatPack? {
        try load().heatPacks.first(where: { $0.id == id })
    }
}
