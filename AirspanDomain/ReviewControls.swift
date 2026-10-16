import Foundation

/// Frozen review_controls / interface confirm-reject-edit labels (en-US UI).
public enum AirspanReviewControls {
    public static let confirm = "Use"
    public static let reject = "Not this"
    public static let edit = "Edit sizes"
    public static let diagramConfirm = "Save diagram"
    public static let diagramReject = "Discard"

    public enum DuctRunReviewBar {
        public static let confirm = AirspanReviewControls.confirm
        public static let reject = AirspanReviewControls.reject
        public static let edit = AirspanReviewControls.edit
    }

    public enum SizeDiagramPreview {
        public static let confirm = AirspanReviewControls.diagramConfirm
        public static let reject = AirspanReviewControls.diagramReject
    }

    public enum FieldStepsPlayer {
        public static let pause = "Pause"
        public static let next = "Next"
    }
}
