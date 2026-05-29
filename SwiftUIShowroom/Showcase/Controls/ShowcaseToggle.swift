import SwiftUI

/// A labelled boolean control for a showcase configuration panel.
struct ShowcaseToggle: View {
    let title: LocalizedStringKey
    @Binding var isOn: Bool

    init(_ title: LocalizedStringKey, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    var body: some View {
        Toggle(title, isOn: $isOn)
            .font(DesignSystem.Font.body)
    }
}
