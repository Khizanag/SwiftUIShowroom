import SwiftUI

/// Maps a `Sheet` to its view. The only place that resolves sheets.
@MainActor
enum SheetFactory {
    @ViewBuilder
    static func view(for sheet: Sheet) -> some View {
        switch sheet {
        case .about:
            AboutView()
        }
    }
}
