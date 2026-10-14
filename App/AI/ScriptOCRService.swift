import Foundation
import UIKit
import Vision

enum ScriptOCRService {
    static func recognizeText(in imageData: Data) async throws -> String {
        guard let image = UIImage(data: imageData), let cg = image.cgImage else {
            throw OCRError.undecodable
        }
        return try await withCheckedThrowingContinuation { cont in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }
                let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                cont.resume(returning: lines.joined(separator: "\n"))
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            let handler = VNImageRequestHandler(cgImage: cg, options: [:])
            do { try handler.perform([request]) } catch { cont.resume(throwing: error) }
        }
    }

    enum OCRError: LocalizedError {
        case undecodable
        var errorDescription: String? { "Could not decode script image for OCR" }
    }
}
