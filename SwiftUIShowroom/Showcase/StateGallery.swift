import SwiftUI

/// Renders a component once per state in an adaptive grid, each captioned.
/// Drive it with a small enum conforming to `ShowcaseState`.
struct StateGallery<State: ShowcaseState, Content: View>: View {
    @ViewBuilder let content: (State) -> Content

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: DesignSystem.Spacing.medium)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.medium) {
            ForEach(Array(State.allCases)) { state in
                LabeledExample(caption: state.caption) {
                    content(state)
                }
            }
        }
    }
}
