import SwiftUI

/// A labelled enum picker for a configuration panel. The property name sits on the
/// leading edge and the menu picker (showing the selected value) on the trailing edge,
/// so it stays readable even outside a `Form`.
struct ShowcasePicker<Value: ShowcasePickable>: View {
    let title: LocalizedStringKey
    @Binding var selection: Value

    init(_ title: LocalizedStringKey, selection: Binding<Value>) {
        self.title = title
        self._selection = selection
    }

    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Font.body)
            Spacer(minLength: DesignSystem.Spacing.medium)
            Picker(title, selection: $selection) {
                ForEach(Array(Value.allCases)) { option in
                    Text(option.label).tag(option)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
        }
    }
}
