import SwiftUI

/// The middle column: the components in the selected category, or global search results
/// when a query is active.
struct ComponentListView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        List(selection: $coordinator.selectedEntryID) {
            ForEach(entries) { entry in
                row(for: entry)
                    .tag(entry.id)
            }
        }
        .navigationTitle(navigationTitle)
        .searchable(text: $coordinator.searchText, prompt: "Search components")
        .overlay {
            if entries.isEmpty {
                emptyState
            }
        }
    }
}

// MARK: - Data
private extension ComponentListView {
    var entries: [ShowcaseEntry] {
        let query = coordinator.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            return ShowcaseRegistry.search(query)
        }
        if let category = coordinator.selectedCategory {
            return ShowcaseRegistry.entries(in: category)
        }
        return []
    }

    var navigationTitle: String {
        if !coordinator.searchText.isEmpty {
            return "Results"
        }
        return coordinator.selectedCategory?.title ?? "Components"
    }
}

// MARK: - Sub-views
private extension ComponentListView {
    func row(for entry: ShowcaseEntry) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
            Text(entry.title)
                .font(DesignSystem.Font.body)
            if !entry.subtitle.isEmpty {
                Text(entry.subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }

    @ViewBuilder
    var emptyState: some View {
        if coordinator.searchText.isEmpty {
            ContentUnavailableView(
                "Coming soon",
                systemImage: "hammer",
                description: Text("Showcases for this category are on the way."),
            )
        } else {
            ContentUnavailableView.search(text: coordinator.searchText)
        }
    }
}
