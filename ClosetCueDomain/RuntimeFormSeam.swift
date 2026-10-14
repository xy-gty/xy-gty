import Foundation

/// RuntimeForm seam marker: native Done, interactive scroll, keyboard toolbar avoidance.
/// Product StylistChat screens own actual SwiftUI forms via AppRuntimeCore.RuntimeForm on iOS.
public enum ClosetCueRuntimeFormSeam {
    public static let libraryTypeName = "RuntimeForm"
    public static let usedByRoute = "StylistChat"
}
