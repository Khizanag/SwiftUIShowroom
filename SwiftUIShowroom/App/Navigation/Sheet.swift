import Foundation

/// Modal sheets presented over the app.
enum Sheet: Identifiable {
    case about

    var id: String { String(describing: self) }
}
