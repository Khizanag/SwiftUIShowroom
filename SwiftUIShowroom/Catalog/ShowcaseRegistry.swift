import Foundation

/// The catalog of every showcase. Each category contributes its own `…Entries` array
/// from its folder, so adding components never touches this file.
@MainActor
enum ShowcaseRegistry {
    static let all: [ShowcaseEntry] =
        textEntries
        + buttonsEntries
        + selectionEntries
        + containersEntries
        + navigationEntries
        + presentationEntries
        + mediaEntries
        + indicatorsEntries
        + modifiersEntries
        + effectsEntries
        + accessibilityEntries
        + chartsEntries
        + gesturesEntries
        + dataFlowEntries

    static func entries(in category: ComponentCategory) -> [ShowcaseEntry] {
        all.filter { $0.category == category }
    }

    static func entry(id: String) -> ShowcaseEntry? {
        all.first { $0.id == id }
    }

    static func search(_ query: String) -> [ShowcaseEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return all.filter { $0.matches(trimmed) }
    }

    /// Categories that currently have at least one shipped showcase.
    static var populatedCategories: [ComponentCategory] {
        ComponentCategory.allCases.filter { !entries(in: $0).isEmpty }
    }

    static func count(in category: ComponentCategory) -> Int {
        entries(in: category).count
    }
}
