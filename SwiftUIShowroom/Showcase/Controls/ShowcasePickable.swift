import Foundation

/// An option set a `ShowcasePicker` can drive. Conform a small enum and give each
/// case a human label.
protocol ShowcasePickable: CaseIterable, Hashable, Identifiable {
    var label: String { get }
}

// MARK: - Defaults
extension ShowcasePickable {
    var id: Self { self }
}
