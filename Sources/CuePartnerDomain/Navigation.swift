import Foundation

/// Frozen navigation destinations from technical_contract.v1.json.
public enum CuePartnerRoute: String, Codable, CaseIterable, Sendable {
    case scenesHome = "ScenesHome"
    case newScene = "NewScene"
    case importScript = "ImportScript"
    case ocrReview = "OCRReview"
    case sceneDetail = "SceneDetail"
    case partnerChat = "PartnerChat"
    case turnReview = "TurnReview"
    case cueRehearsal = "CueRehearsal"
    case voiceNoteCapture = "VoiceNoteCapture"
    case ambiencePicker = "AmbiencePicker"
    case settings = "Settings"
    case legalPages = "LegalPages"
    case consentSheet = "ConsentSheet"
}
