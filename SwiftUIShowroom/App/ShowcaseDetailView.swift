import SwiftUI

/// The detail column: hosts the selected component's showcase inside the coordinated
/// navigation stack, with an About entry point in the toolbar.
struct ShowcaseDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        CoordinatedNavigationStack(coordinator: coordinator) {
            selectedShowcase
                .toolbar {
                    ToolbarItem {
                        Button {
                            coordinator.present(.about)
                        } label: {
                            Label("About", systemImage: "info.circle")
                        }
                    }
                }
        }
    }
}

// MARK: - Sub-views
private extension ShowcaseDetailView {
    @ViewBuilder
    var selectedShowcase: some View {
        if let id = coordinator.selectedEntryID, let entry = ShowcaseRegistry.entry(id: id) {
            entry.makeView()
        } else {
            ContentUnavailableView(
                "Pick a component",
                systemImage: "square.grid.2x2",
                description: Text("Choose a component from the list to start exploring."),
            )
        }
    }
}
