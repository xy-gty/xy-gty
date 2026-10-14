import Foundation

/// Frozen review_controls / interface confirm-reject-edit labels (en-US UI).
public enum BendCoachReviewControls {
    public static let confirm = "Save"
    public static let reject = "Not this"
    public static let edit = "Edit marks"

    public enum BendReviewBar {
        public static let confirm = BendCoachReviewControls.confirm
        public static let reject = BendCoachReviewControls.reject
        public static let edit = BendCoachReviewControls.edit
    }

    public enum DiagramPreview {
        public static let confirm = "Use"
        public static let reject = "Discard"
    }

    public enum CoachingPlayer {
        public static let pause = "Pause"
        public static let next = "Next"
    }
}
