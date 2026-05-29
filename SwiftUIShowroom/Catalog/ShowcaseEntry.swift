import SwiftUI

/// One entry in the catalog: metadata for browsing and search, plus a factory that
/// builds the component's showcase page on demand.
struct ShowcaseEntry: Identifiable {
    let id: String
    let title: String
    let category: ComponentCategory
    let subtitle: String
    let keywords: [String]
    let makeView: () -> AnyView

    init<Content: View>(
        id: String,
        title: String,
        category: ComponentCategory,
        subtitle: String = "",
        keywords: [String] = [],
        @ViewBuilder view: @escaping () -> Content,
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.subtitle = subtitle
        self.keywords = keywords
        self.makeView = { AnyView(view()) }
    }

    /// True when the entry matches a free-text query across title, subtitle, and keywords.
    func matches(_ query: String) -> Bool {
        let needle = query.lowercased()
        if title.lowercased().contains(needle) { return true }
        if subtitle.lowercased().contains(needle) { return true }
        return keywords.contains { $0.lowercased().contains(needle) }
    }
}
