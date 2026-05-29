import SwiftUI

/// A labelled enum picker for a configuration panel. Defaults to a menu style so it
/// stays compact regardless of the number of options.
struct ShowcasePicker<Value: ShowcasePickable>: View {
    let title: LocalizedStringKey
    @Binding var selection: Value

    init(_ title: LocalizedStringKey, selection: Binding<Value>) {
        self.title = title
        self._selection = selection
    }

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(Array(Value.allCases)) { option in
                Text(option.label).tag(option)
            }
        }
        .font(DesignSystem.Font.body)
    }
}
