import Foundation
import AppRuntimeCore
import BrewCueDomain

final class BrewStore: BrewSessionStore {
    private let store: AtomicCodableStore<BrewCueState>

    init(directory: URL) {
        store = BrewCueStores.stateStore(directory: directory)
    }

    func load() throws -> BrewCueState {
        try store.load() ?? BrewCueState()
    }

    func save(_ state: BrewCueState) throws {
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
