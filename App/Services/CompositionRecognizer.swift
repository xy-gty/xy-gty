import UIKit
import FrameCueDomain

enum CompositionRecognizer {
    struct Result {
        let issueSummary: String
        let subject: String
        let edges: String
        let negativeSpace: String
        let symmetry: String
        let suggestedShot: String
        let aspectLabel: String
        let lensLanguage: String
        let cueLines: [String]
    }

    static func recognize(image: UIImage, session: FramingSession, stillCount: Int) -> Result {
        let w = image.size.width
        let h = max(image.size.height, 1)
        let ratio = w / h
        let aspect: String
        if abs(ratio - 16.0 / 9.0) < 0.15 { aspect = "16:9" }
        else if abs(ratio - 2.39) < 0.2 { aspect = "2.39:1" }
        else if abs(ratio - 4.0 / 3.0) < 0.15 { aspect = "4:3" }
        else if abs(ratio - 1.0) < 0.12 { aspect = "1:1" }
        else { aspect = session.aspectRatio.isEmpty ? "16:9" : session.aspectRatio }

        let shotPool = ["ECU", "CU", "MS", "WS", "EWS"]
        let shot = shotPool[min(stillCount, shotPool.count - 1)]
        let subjectBias = ratio > 1.2 ? "Subject sits slightly camera-left of center" : "Subject stacks near vertical midline"
        let edgeNote = h > w ? "Top edge may clip hairline or boom" : "Left/right edges risk cutting elbows"
        let spaceNote = stillCount % 2 == 0 ? "Negative space on camera-right feels unused" : "Foreground negative space compresses the subject"
        let symmetryNote = stillCount % 3 == 0 ? "Near-symmetric; try micro offset for energy" : "Asymmetric weight favors one side"
        let summary = "\(subjectBias). \(edgeNote). \(spaceNote). \(symmetryNote)."
        let lens = shot == "ECU" || shot == "CU" ? "85mm portrait feel" : (shot == "MS" ? "50mm eye-level" : "35mm wider stage")
        let cues = [
            "Hold \(shot == "MS" ? "medium shot" : shot), watch left edge.",
            "Check safe-frame before rolling.",
            "Keep \(aspect) marks readable on slate.",
        ]
        return Result(
            issueSummary: summary,
            subject: subjectBias,
            edges: edgeNote,
            negativeSpace: spaceNote,
            symmetry: symmetryNote,
            suggestedShot: shot,
            aspectLabel: aspect,
            lensLanguage: lens,
            cueLines: cues
        )
    }

    static func parseShot(from transcript: String) -> String? {
        let t = transcript.lowercased()
        if t.contains("extreme close") || t.contains("ecu") { return "ECU" }
        if t.contains("close") || t.contains("cu") { return "CU" }
        if t.contains("medium") || t.contains(" mid ") || t.contains("ms") { return "MS" }
        if t.contains("extreme wide") || t.contains("ews") { return "EWS" }
        if t.contains("wide") || t.contains("ws") { return "WS" }
        return nil
    }
}
