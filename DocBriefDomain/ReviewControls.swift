import Foundation

/// Frozen review_controls / interface confirm-reject-edit labels (en-US UI).
public enum DocBriefReviewControls {
    public static let confirm = "Save"
    public static let reject = "Not this"
    public static let edit = "Edit fields"

    public enum SummaryCardPreview {
        public static let confirm = "Use"
        public static let reject = "Discard"
    }

    public enum RecognitionReviewBar {
        public static let confirm = DocBriefReviewControls.confirm
        public static let reject = DocBriefReviewControls.reject
        public static let edit = DocBriefReviewControls.edit
    }

    public enum ActionReview {
        public static let confirm = DocBriefReviewControls.confirm
        public static let reject = DocBriefReviewControls.reject
    }
}
