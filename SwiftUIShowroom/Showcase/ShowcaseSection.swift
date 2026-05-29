import SwiftUI

/// A titled section inside a showcase screen: a header label above a content card.
struct ShowcaseSection<Content: View>: View {
    let title: LocalizedStringKey
    var systemImage: String?
    @ViewBuilder let content: () -> Content

    init(
        _ title: LocalizedStringKey,
        systemImage: String? = nil,
        @ViewBuilder content: @escaping () -> Content,
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            header
            content()
        }
    }
}

// MARK: - Sub-views
private extension ShowcaseSection {
    @ViewBuilder
    var header: some View {
        if let systemImage {
            Label(title, systemImage: systemImage)
                .font(DesignSystem.Font.headline)
        } else {
            Text(title)
                .font(DesignSystem.Font.headline)
        }
    }
}
