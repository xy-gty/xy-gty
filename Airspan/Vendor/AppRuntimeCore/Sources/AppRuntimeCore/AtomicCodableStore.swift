import Foundation

/// A caller-owned domain file. Ordinary saves never replace unreadable data.
public final class AtomicCodableStore<Value: Codable>: @unchecked Sendable {
    public let url: URL
    private let lock = NSRecursiveLock()
    private let writer: @Sendable (Data, URL) throws -> Void

    public init(url: URL, writer: @escaping @Sendable (Data, URL) throws -> Void = { data, url in
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }) {
        self.url = url
        self.writer = writer
    }

    public func load() throws -> Value? {
        lock.lock(); defer { lock.unlock() }
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode(Value.self, from: Data(contentsOf: url))
    }

    public func save(_ value: Value) throws {
        lock.lock(); defer { lock.unlock() }
        // Decode again on every save, including the first save in this process.
        // Recovery/migration is an explicit product decision, not an overwrite.
        if FileManager.default.fileExists(atPath: url.path) {
            _ = try JSONDecoder().decode(Value.self, from: Data(contentsOf: url))
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let bytes = try encoder.encode(value)
        try writer(bytes, url)
    }
}
