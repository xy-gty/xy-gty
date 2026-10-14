import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum CuePartnerStores {
    public static let scenes = "scenes"
    public static let scriptPages = "script_pages"
    public static let cueLines = "cue_lines"
    public static let partnerTurns = "partner_turns"
    public static let rehearsalMessages = "rehearsal_messages"
    public static let voiceNotes = "voice_notes"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.cuepartner"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"
}
