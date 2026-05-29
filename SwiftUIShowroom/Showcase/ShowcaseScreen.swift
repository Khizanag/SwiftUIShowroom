import SwiftUI

/// The standard scaffold every component page is built on: a scrolling, width-clamped
/// column with an optional summary, set against the app background, with the title wired
/// into navigation. Compose `PreviewStage`, `ShowcaseSection`, `StateGallery`, and
/// `CodeBlock` inside it.
struct ShowcaseScreen<Content: View>: View {
    let title: String
    var summary: LocalizedStringKey?
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        summary: LocalizedStringKey? = nil,
        @ViewBuilder content: @escaping () -> Content,
    ) {
        self.title = title
        self.summary = summary
        self.content = content
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xLarge) {
                if let summary {
                    Text(summary)
                        .font(DesignSystem.Font.callout)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
                content()
            }
            .padding(DesignSystem.Spacing.large)
            .frame(maxWidth: 700, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle(title)
    }
}
