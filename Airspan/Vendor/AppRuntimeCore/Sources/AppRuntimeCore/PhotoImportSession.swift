import Foundation
#if canImport(ImageIO)
import ImageIO

/// Data and destination belong to the product. Last selection wins, with no awaited write.
@MainActor
public final class PhotoImportSession {
    public enum Result: Equatable { case imported(URL), cancelled, superseded }
    public enum Failure: Error { case unsupportedType, undecodableImage }
    private var generation: UInt64 = 0
    private let destination: URL
    private let writer: (Data, URL) throws -> Void

    public init(destination: URL, writer: @escaping (Data, URL) throws -> Void = { data, url in
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }) { self.destination = destination; self.writer = writer }

    public func cancel() { generation &+= 1 }
    public func importSelection(_ load: () async throws -> Data?) async throws -> Result {
        generation &+= 1
        let selected = generation
        let bytes: Data?
        do { bytes = try await load() }
        catch {
            if selected != generation { return .superseded }
            throw error
        }
        guard selected == generation else { return .superseded }
        try Task.checkCancellation()
        guard let bytes else { throw Failure.unsupportedType }
        guard let source = CGImageSourceCreateWithData(bytes as CFData, nil),
              CGImageSourceGetCount(source) > 0,
              CGImageSourceCreateImageAtIndex(source, 0, [kCGImageSourceShouldCacheImmediately: true] as CFDictionary) != nil,
              CGImageSourceGetStatus(source) == .statusComplete else { throw Failure.undecodableImage }
        try writer(bytes, destination)
        return .imported(destination)
    }
}
#endif
