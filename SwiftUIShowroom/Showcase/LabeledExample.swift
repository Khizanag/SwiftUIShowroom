import SwiftUI

/// A single captioned example: the content centered above a small caption.
/// The atom the `StateGallery` is built from; also usable on its own.
struct LabeledExample<Content: View>: View {
    let caption: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            content()
                .frame(maxWidth: .infinity)
            Text(caption)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}
