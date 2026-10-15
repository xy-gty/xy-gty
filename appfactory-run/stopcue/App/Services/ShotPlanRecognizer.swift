import UIKit
import StopCueDomain

enum ShotPlanRecognizer {
    struct Result {
        let shotPlanSummary: String
        let timingSummary: String
        let alignmentHint: String
        let displacementNote: String
    }

    static func recognize(image: UIImage, project: Project, frameCount: Int) -> Result {
        let w = Int(image.size.width)
        let h = Int(image.size.height)
        let aspect = w > 0 ? Double(h) / Double(w) : 1.0
        let interval = max(120, Int(1000.0 / max(project.targetFrameRate, 1.0)))
        let shot = "Frame \(frameCount + 1): hold subject center, nudge \(aspect > 1.2 ? "vertical" : "lateral") by ~1 sprocket for stop-motion continuity."
        let timing = "Suggested interval \(interval)ms · countdown ‘3-2-1-click’ · keep hands free for set."
        let align = "Onion-skin prior frame at 35% — match front edge of subject."
        let displace = aspect > 1.2
            ? "Lift subject slightly for next beat."
            : "Slide subject a bit closer toward camera for next frame."
        return Result(shotPlanSummary: shot, timingSummary: timing, alignmentHint: align, displacementNote: displace)
    }
}
