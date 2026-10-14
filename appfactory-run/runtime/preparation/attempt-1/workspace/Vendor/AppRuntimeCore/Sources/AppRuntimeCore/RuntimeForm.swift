#if os(iOS)
import SwiftUI
import PhotosUI
import UIKit

/// Callers own focus, validation, field content and action styling.
public struct RuntimeForm<Content: View, Actions: View>: View {
    private let content: Content
    private let actions: Actions
    private let dismissFocus: () -> Void
    @State private var keyboardTop: CGFloat?
    public init(dismissFocus: @escaping () -> Void,
                @ViewBuilder content: () -> Content, @ViewBuilder actions: () -> Actions) {
        self.dismissFocus = dismissFocus; self.content = content(); self.actions = actions()
    }
    public var body: some View {
        GeometryReader { geometry in
            // Some OS versions exclude the keyboard but retain its accessory
            // toolbar in the content area. Reserve the observed overlap.
            let overlap = keyboardTop.map { max(0, geometry.frame(in: .global).maxY - $0) } ?? 0
            ScrollView { content }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 0) { actions }.padding(.bottom, overlap)
                }
        }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                keyboardTop = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.minY
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardTop = nil
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissFocus)
                }
            }
    }
}

public extension PhotoImportSession {
    /// nil represents picker cancellation; a selected unsupported type throws.
    func importSelection(_ item: PhotosPickerItem?) async throws -> Result {
        guard let item else { cancel(); return .cancelled }
        return try await importSelection { try await item.loadTransferable(type: Data.self) }
    }
}
#endif
