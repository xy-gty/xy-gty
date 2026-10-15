import UIKit
import NightCueDomain

enum ExposureRecognizer {
    struct Result {
        var exposureSummary: String
        var noiseSummary: String
        var trailSigns: String
        var diagnosisMarks: [(x: Double, y: Double, value: Double, label: String)]
    }

    static func recognize(image: UIImage, session: Session) -> Result {
        let brightness = averageBrightness(image)
        let exposure: String
        let noise: String
        let trail: String
        var marks: [(Double, Double, Double, String)] = []

        if brightness < 0.28 {
            exposure = "Underexposed — lift ISO or lengthen shutter for \(session.locationLabel)."
            marks.append((0.32, 0.38, 0.8, "underexposed"))
        } else if brightness > 0.72 {
            exposure = "Highlight risk — protect bright city lights; consider ND or shorter shutter."
            marks.append((0.68, 0.28, 0.7, "highlight"))
        } else {
            exposure = "Exposure window looks workable for night long exposure."
            marks.append((0.5, 0.45, 0.45, "pass"))
        }

        if brightness < 0.35 {
            noise = "Noise risk elevated at this brightness — prefer longer shutter over extreme ISO."
            marks.append((0.55, 0.62, 0.65, "noise"))
        } else {
            noise = "Noise appears manageable; keep ISO disciplined."
        }

        if session.sceneGoal.lowercased().contains("trail") || session.sceneGoal.lowercased().contains("light") {
            trail = "Trail signs: watch for smear on light trails — lock tripod and use 2s timer."
            marks.append((0.4, 0.72, 0.55, "trail"))
        } else {
            trail = "No strong trail smear cues in local draft."
        }

        return Result(
            exposureSummary: exposure,
            noiseSummary: noise,
            trailSigns: trail,
            diagnosisMarks: marks
        )
    }

    private static func averageBrightness(_ image: UIImage) -> Double {
        guard let cg = image.cgImage else { return 0.4 }
        let width = min(cg.width, 48)
        let height = min(cg.height, 48)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var data = [UInt8](repeating: 0, count: width * height * 4)
        guard let ctx = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return 0.4 }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        var sum = 0.0
        let pixels = width * height
        for i in 0 ..< pixels {
            let o = i * 4
            let r = Double(data[o])
            let g = Double(data[o + 1])
            let b = Double(data[o + 2])
            sum += (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
        }
        return sum / Double(max(pixels, 1))
    }
}
