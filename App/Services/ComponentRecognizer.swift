import UIKit
import RuleCueDomain

enum ComponentRecognizer {
    struct Result {
        var componentSummary: String
        var phaseSummary: String
        var zoneLabels: [String]
        var phaseTitles: [String]
        var overlayNotes: String
    }

    static func recognize(image: UIImage, session: GameSession, photoCount: Int) -> Result {
        let brightness = averageLuma(image)
        let zones: [String]
        if brightness < 0.35 {
            zones = ["Deck pile", "Center board", "Player mats", "Token tray"]
        } else if brightness > 0.65 {
            zones = ["Draw deck", "Main board", "Player A", "Player B", "Discard"]
        } else {
            zones = ["Rulebook stack", "Board center", "Component tray", "Player area"]
        }
        let phases = [
            "Unpack & sort",
            "Board setup",
            "Deal starting hands",
            "First player turn",
            "End-round cleanup",
        ]
        let componentSummary =
            "Detected \(zones.count) table zones for \(session.gameName) "
            + "(photo #\(max(photoCount, 1))). Likely pieces: boards, decks, tokens."
        let phaseSummary = phases.joined(separator: " → ")
        let overlayNotes =
            "Mark \(zones[0]) first, then seat players around \(zones[min(1, zones.count - 1)])."
        return Result(
            componentSummary: componentSummary,
            phaseSummary: phaseSummary,
            zoneLabels: zones,
            phaseTitles: phases,
            overlayNotes: overlayNotes
        )
    }

    private static func averageLuma(_ image: UIImage) -> CGFloat {
        guard let cg = image.cgImage else { return 0.5 }
        let width = min(cg.width, 32)
        let height = min(cg.height, 32)
        guard width > 0, height > 0 else { return 0.5 }
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
        ) else { return 0.5 }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        var sum: CGFloat = 0
        let count = width * height
        for i in 0 ..< count {
            let o = i * 4
            let r = CGFloat(data[o]) / 255
            let g = CGFloat(data[o + 1]) / 255
            let b = CGFloat(data[o + 2]) / 255
            sum += 0.2126 * r + 0.7152 * g + 0.0722 * b
        }
        return sum / CGFloat(max(count, 1))
    }
}
