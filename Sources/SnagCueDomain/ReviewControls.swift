import Foundation

/// Review affordances and AI consent literals from technical contract.
public enum SnagReviewBar {
    public static let confirm = "Save"
    public static let reject = "Not this"
    public static let edit = "Edit snag"
}

public enum PunchFieldReview {
    public static let confirm = "Save"
    public static let reject = "Not this"
}

public enum AnnotatedReportPreview {
    public static let confirm = "Use"
    public static let reject = "Discard"
}

public enum AIConsentContract {
    public static let provider = "DeepSeek"
    public static let disclosureVersion = "snagcue.consent.v1"
    public static let fields = [
        "walkthrough_photo_bytes", "punch_item_fields", "chat_text", "snag_labels"
    ]
}

/// ChecklistTTS is session-scoped readout; UI deferred to Builder.
public enum ChecklistTTSContract {
    public static let interfaceName = "ChecklistTTS"
}
