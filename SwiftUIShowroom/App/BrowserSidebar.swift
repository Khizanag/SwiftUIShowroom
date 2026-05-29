import SwiftUI

/// The leading column: every component category, with a count of shipped showcases.
struct BrowserSidebar: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        List(selection: $coordinator.selectedCategory) {
            ForEach(ComponentCategory.allCases) { category in
                row(for: category)
                    .tag(category)
            }
        }
        .navigationTitle("Showroom")
    }
}

// MARK: - Sub-views
private extension BrowserSidebar {
    func row(for category: ComponentCategory) -> some View {
        let count = ShowcaseRegistry.count(in: category)
        return Label(category.title, systemImage: category.systemImage)
            .badge(count == 0 ? nil : Text(count.formatted()))
    }
}
