import SwiftUI

/// A labelled integer stepper with a live value read-out, for a configuration panel.
struct ShowcaseStepper: View {
    let title: LocalizedStringKey
    @Binding var value: Int
    let range: ClosedRange<Int>

    init(_ title: LocalizedStringKey, value: Binding<Int>, in range: ClosedRange<Int>) {
        self.title = title
        self._value = value
        self.range = range
    }

    var body: some View {
        Stepper(value: $value, in: range) {
            HStack {
                Text(title)
                    .font(DesignSystem.Font.body)
                Spacer()
                Text(value.formatted())
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }
}
