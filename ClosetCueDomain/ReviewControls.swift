import Foundation

/// Frozen review_controls / interface confirm-reject-edit labels (en-US UI).
public enum ClosetCueReviewControls {
    public static let confirm = "Keep"
    public static let reject = "Not this"
    public static let edit = "Edit tags"
    public static let flatLayConfirm = "Save look"
    public static let flatLayReject = "Discard"

    public enum GarmentReviewBar {
        public static let confirm = ClosetCueReviewControls.confirm
        public static let reject = ClosetCueReviewControls.reject
        public static let edit = ClosetCueReviewControls.edit
    }

    public enum FlatLayPreview {
        public static let confirm = ClosetCueReviewControls.flatLayConfirm
        public static let reject = ClosetCueReviewControls.flatLayReject
    }

    public enum MorningBriefingPlayer {
        public static let pause = "Pause"
        public static let next = "Next"
    }
}
