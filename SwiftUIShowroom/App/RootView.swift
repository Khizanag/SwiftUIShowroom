import SwiftUI

/// The app root: a three-column browser (categories → components → showcase) that
/// collapses to a stack on compact widths. Owns and injects the `AppCoordinator`.
struct RootView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationSplitView(columnVisibility: $coordinator.columnVisibility) {
            BrowserSidebar()
        } content: {
            ComponentListView()
        } detail: {
            ShowcaseDetailView()
        }
        .environment(coordinator)
    }
}

#Preview {
    RootView()
}
