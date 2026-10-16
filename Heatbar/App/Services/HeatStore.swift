import Foundation
import AppRuntimeCore
import HeatbarDomain

final class HeatStore: HeatPackStore {
    private let store: AtomicCodableStore<HeatbarState>

    init(directory: URL) {
        store = HeatbarStores.stateStore(directory: directory)
    }

    func load() throws -> HeatbarState {
        try store.load() ?? HeatbarState()
    }

    func save(_ state: HeatbarState) throws {
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
