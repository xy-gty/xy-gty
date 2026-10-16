import Foundation

@MainActor
public final class TypedNavigationStore<Route: Codable> {
    private let storage: AtomicCodableStore<[Route]>
    private let isValid: (Route) -> Bool
    public init(url: URL, isValid: @escaping (Route) -> Bool) {
        storage = AtomicCodableStore(url: url)
        self.isValid = isValid
    }
    public func restore() throws -> [Route] {
        Array((try storage.load() ?? []).prefix(while: isValid))
    }
    public func save(_ path: [Route]) throws {
        guard path.allSatisfy(isValid) else { throw Failure.invalidRoute }
        try storage.save(path)
    }
    public enum Failure: Error { case invalidRoute }
}
