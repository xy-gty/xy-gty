import UIKit
import BroodcheckDomain

enum BroodRecognizer {
    struct Result {
        var broodSummary: String
        var storesSummary: String
        var pestSigns: String
        var heatMarks: [(x: Double, y: Double, heat: Double, label: String)]
    }

    /// Local heuristic draft when outbound AI is unavailable; always editable.
    static func recognize(image: UIImage, inspection: Inspection) -> Result {
        let w = image.size.width
        let h = image.size.height
        let brightness = averageBrightness(image)
        let brood: String
        let stores: String
        let pests: String
        if brightness < 0.38 {
            brood = "Likely capped brood band on darker cells — verify seal pattern on \(inspection.currentFrameLabel)."
            stores = "Stores look thin at edges; check nectar rim before next frame."
            pests = "Low light may hide mites — inspect cell bottoms with torch if available."
        } else if brightness > 0.62 {
            brood = "Open / young brood pattern suspected on brighter comb of \(inspection.currentFrameLabel)."
            stores = "Bright capped stores likely along top bar — nectar-green pass candidate."
            pests = "No strong pest sign from brightness alone; watch for spotty brood."
        } else {
            brood = "Mixed brood pattern on \(inspection.currentFrameLabel) — confirm queen right / worker cells."
            stores = "Mid stores band; mark nectar vs pollen before moving the rail."
            pests = "Watch for irregular empty cells; flag if chalk / SHB suspected."
        }
        _ = (w, h)
        return Result(
            broodSummary: brood,
            storesSummary: stores,
            pestSigns: pests,
            heatMarks: [
                (0.32, 0.40, 0.72, "brood"),
                (0.68, 0.28, 0.55, "stores"),
                (0.50, 0.70, 0.40, "check"),
            ]
        )
    }

    private static func averageBrightness(_ image: UIImage) -> Double {
        guard let cg = image.cgImage else { return 0.5 }
        let width = min(cg.width, 32)
        let height = min(cg.height, 32)
        guard width > 0, height > 0 else { return 0.5 }
        let colorSpace = CGColorSpaceCreateDeviceGray()
        var data = [UInt8](repeating: 0, count: width * height)
        guard let ctx = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return 0.5 }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        let sum = data.reduce(0) { $0 + Int($1) }
        return Double(sum) / Double(data.count * 255)
    }
}
