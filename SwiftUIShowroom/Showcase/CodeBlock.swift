import SwiftUI

/// Monospaced, horizontally scrollable source with a copy-to-clipboard button.
/// Renders the code generated from a showcase's current configuration.
struct CodeBlock: View {
    let code: String

    @State private var didCopy = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(DesignSystem.Font.code)
                .textSelection(.enabled)
                .padding(DesignSystem.Spacing.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(alignment: .topTrailing) {
            if Clipboard.isAvailable {
                copyButton
            }
        }
    }
}

// MARK: - Sub-views
private extension CodeBlock {
    var copyButton: some View {
        Button {
            Clipboard.copy(code)
            withAnimation { didCopy = true }
        } label: {
            Label(
                didCopy ? "Copied" : "Copy",
                systemImage: didCopy ? "checkmark" : "doc.on.doc",
            )
            .font(DesignSystem.Font.caption)
            .labelStyle(.titleAndIcon)
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.capsule)
        .padding(DesignSystem.Spacing.small)
        .accessibilityLabel(didCopy ? "Code copied" : "Copy code")
        .task(id: didCopy) {
            guard didCopy else { return }
            try? await Task.sleep(for: .seconds(2))
            withAnimation { didCopy = false }
        }
    }
}
