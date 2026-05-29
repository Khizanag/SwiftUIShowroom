import SwiftUI

/// The single navigation host. The only place in the app that declares a
/// `navigationDestination(for:)` or attaches the sheet presentation — every other view
/// routes through the coordinator instead.
struct CoordinatedNavigationStack<Root: View>: View {
    @Bindable var coordinator: AppCoordinator
    @ViewBuilder var root: () -> Root

    var body: some View {
        NavigationStack(path: $coordinator.detailPath) {
            root()
                .navigationDestination(for: Screen.self) { screen in
                    ScreenFactory.view(for: screen)
                }
        }
        .sheet(item: $coordinator.activeSheet) { sheet in
            SheetFactory.view(for: sheet)
        }
    }
}
