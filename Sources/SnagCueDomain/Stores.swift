import Foundation
import AppRuntimeCore

/// Domain store wiring to AppRuntimeCore persistence primitives.
public enum SnagCueStores {
    public static let audits = "audits"
    public static let walkthroughPhotos = "walkthrough_photos"
    public static let snagDrafts = "snag_drafts"
    public static let punchItems = "punch_items"
    public static let reportDrafts = "report_drafts"
    public static let aiConsentLocal = "ai_consent_local"

    public static let keychainService = "com.lingguang.snagcue"
    public static let keychainAPIKeyAccount = "deepseek_api_key"
    public static let keychainConsentAccount = "ai_consent_record"
}
