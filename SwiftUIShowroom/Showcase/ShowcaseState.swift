import Foundation

/// A finite set of states a component can be shown in inside a `StateGallery`.
/// Conform a small enum and provide a human caption per case.
protocol ShowcaseState: CaseIterable, Identifiable, Hashable {
    var caption: String { get }
}

// MARK: - Defaults
extension ShowcaseState {
    var id: Self { self }
}
