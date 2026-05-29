import SwiftUI

/// A labelled numeric slider with a live value read-out, for a configuration panel.
struct ShowcaseSlider: View {
    let title: LocalizedStringKey
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1

    init(
        _ title: LocalizedStringKey,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double = 1,
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            HStack {
                Text(title)
                    .font(DesignSystem.Font.body)
                Spacer()
                Text(value.formatted(.number.precision(.fractionLength(0...2))))
                    .font(DesignSystem.Font.codeInline)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}
