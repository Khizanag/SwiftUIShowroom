import SwiftUI

/// A labelled color well for a configuration panel.
struct ShowcaseColorControl: View {
    let title: LocalizedStringKey
    @Binding var selection: Color
    var supportsOpacity = true

    init(_ title: LocalizedStringKey, selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.title = title
        self._selection = selection
        self.supportsOpacity = supportsOpacity
    }

    var body: some View {
        ColorPicker(title, selection: $selection, supportsOpacity: supportsOpacity)
            .font(DesignSystem.Font.body)
    }
}
