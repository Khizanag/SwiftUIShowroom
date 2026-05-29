import SwiftUI

/// Owns the app's navigation state: the selected category and component, the detail
/// push stack, the active sheet, and the search query. Injected through the environment.
@MainActor
@Observable
final class AppCoordinator {
    var selectedCategory: ComponentCategory?
    var selectedEntryID: String?
    var detailPath: [Screen] = []
    var activeSheet: Sheet?
    var searchText = ""
    var columnVisibility = NavigationSplitViewVisibility.all

    init() {
        let firstCategory = ShowcaseRegistry.populatedCategories.first
        selectedCategory = firstCategory
        if let firstCategory {
            selectedEntryID = ShowcaseRegistry.entries(in: firstCategory).first?.id
        }
    }

    func push(_ screen: Screen) {
        detailPath.append(screen)
    }

    func present(_ sheet: Sheet) {
        activeSheet = sheet
    }

    func popToRoot() {
        detailPath.removeAll()
    }
}
