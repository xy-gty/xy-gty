import Foundation

/// Frozen review_controls / interface confirm-reject-edit labels (en-US UI).
public enum HemlineReviewControls {
    public static let confirm = "Keep"
    public static let reject = "Not this"
    public static let edit = "Edit tags"
    public static let flatLayConfirm = "Save look"
    public static let flatLayReject = "Discard"

    public enum GarmentReviewBar {
        public static let confirm = HemlineReviewControls.confirm
        public static let reject = HemlineReviewControls.reject
        public static let edit = HemlineReviewControls.edit
    }

    public enum FlatLayPreview {
        public static let confirm = HemlineReviewControls.flatLayConfirm
        public static let reject = HemlineReviewControls.flatLayReject
    }

    public enum MorningBriefingPlayer {
        public static let pause = "Pause"
        public static let next = "Next"
    }
}
