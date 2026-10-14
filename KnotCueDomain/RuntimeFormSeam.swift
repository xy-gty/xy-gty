import Foundation

/// RuntimeForm seam marker: native Done, interactive scroll, keyboard toolbar avoidance.
/// Product CoachChat screens own actual SwiftUI forms via AppRuntimeCore.RuntimeForm on iOS.
public enum KnotCueRuntimeFormSeam {
    public static let libraryTypeName = "RuntimeForm"
    public static let usedByRoute = "CoachChat"
}
