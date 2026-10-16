import Foundation

/// Frozen review_controls / interface confirm-reject-edit labels (en-US UI).
public enum BightstepReviewControls {
    public static let confirm = "Keep stage"
    public static let reject = "Not this"
    public static let edit = "Edit stage"
    public static let overlayConfirm = "Save overlay"
    public static let overlayReject = "Discard"

    public enum StageReviewBar {
        public static let confirm = BightstepReviewControls.confirm
        public static let reject = BightstepReviewControls.reject
        public static let edit = BightstepReviewControls.edit
    }

    public enum StepOverlayPreview {
        public static let confirm = BightstepReviewControls.overlayConfirm
        public static let reject = BightstepReviewControls.overlayReject
    }

    public enum HandsFreePlayer {
        public static let pause = "Pause"
        public static let next = "Next"
    }
}
