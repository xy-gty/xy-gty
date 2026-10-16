import Foundation
import AppRuntimeCore
import BloomkettleDomain

final class BrewStore: BrewSessionStore {
    private let store: AtomicCodableStore<BloomkettleState>

    init(directory: URL) {
        store = BloomkettleStores.stateStore(directory: directory)
    }

    func load() throws -> BloomkettleState {
        try store.load() ?? BloomkettleState()
    }

    func save(_ state: BloomkettleState) throws {
        try store.save(state)
    }

    func upsertSession(_ session: BrewSession) throws {
        var state = try load()
        if let idx = state.sessions.firstIndex(where: { $0.id == session.id }) {
            state.sessions[idx] = session
        } else {
            state.sessions.insert(session, at: 0)
        }
        try save(state)
    }

    func session(id: String) throws -> BrewSession? {
        try load().sessions.first(where: { $0.id == id })
    }
}
