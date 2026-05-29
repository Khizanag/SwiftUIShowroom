import SwiftUI

/// Maps a `Screen` push destination to its view. The only place that resolves screens.
@MainActor
enum ScreenFactory {
    @ViewBuilder
    static func view(for screen: Screen) -> some View {
        switch screen {
        case .showcase(let entryID):
            if let entry = ShowcaseRegistry.entry(id: entryID) {
                entry.makeView()
            } else {
                ContentUnavailableView(
                    "Component not found",
                    systemImage: "questionmark.square.dashed",
                )
            }
        }
    }
}
