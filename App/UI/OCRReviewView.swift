import SwiftUI
import CuePartnerDomain
import AppRuntimeCore

struct OCRReviewView: View {
    @EnvironmentObject private var model: AppModel
    @FocusState private var focused: Bool

    var body: some View {
        RuntimeForm(dismissFocus: { focused = false }) {
            VStack(alignment: .leading, spacing: 12) {
                Text("OCR review")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CueTheme.ink)
                Text("Edit the recognized text, then Keep to save the ScriptPage and seed CueLines.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextEditor(text: $model.editingOCRText)
                    .frame(minHeight: 280)
                    .padding(8)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .focused($focused)
            }
            .padding()
        } actions: {
            HStack(spacing: 12) {
                Button(OCRReviewBar.reject) { model.discardOCRPage() }
                    .buttonStyle(.bordered)
                Button(OCRReviewBar.edit) { focused = true }
                    .buttonStyle(.bordered)
                Button(OCRReviewBar.confirm) { model.keepOCRPage() }
                    .buttonStyle(.borderedProminent)
                    .tint(CueTheme.amber)
            }
            .padding()
        }
        .background(CueTheme.background.ignoresSafeArea())
        .navigationTitle("OCR review")
    }
}
