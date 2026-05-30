import SwiftUI

struct AccessibilityAdjustableActionShowcase: View {
    @State private var handlerKind: HandlerKind = .incrementDecrement
    @State private var currentValue: Double = 50
    @State private var currentOption: Int = 0

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Adjustable Action",
            summary: "Handles VoiceOver swipe-up/down increment and decrement gestures for custom value controls.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityAdjustableActionShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            switch handlerKind {
            case .incrementDecrement:
                numericSlider(value: $currentValue, isDisabled: false)
            case .nextPreviousOption:
                optionStepper(option: $currentOption, isDisabled: false)
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Handler behavior", selection: $handlerKind)
    }

    @ViewBuilder func stateView(_ state: EnabledState) -> some View {
        switch state {
        case .enabled:
            stateRow(isDisabled: false)
        case .disabled:
            stateRow(isDisabled: true)
        }
    }

    @ViewBuilder func stateRow(isDisabled: Bool) -> some View {
        switch handlerKind {
        case .incrementDecrement:
            numericSlider(
                value: .constant(isDisabled ? 50 : 72),
                isDisabled: isDisabled,
            )
        case .nextPreviousOption:
            optionStepper(
                option: .constant(isDisabled ? 0 : 1),
                isDisabled: isDisabled,
            )
        }
    }

    func numericSlider(value: Binding<Double>, isDisabled: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(height: 64)
                HStack(spacing: DesignSystem.Spacing.medium) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(isDisabled ? DesignSystem.Color.secondary : DesignSystem.Color.accent)
                        .font(DesignSystem.Font.title2)
                    Text("\(Int(value.wrappedValue))%")
                        .font(DesignSystem.Font.title)
                        .foregroundStyle(DesignSystem.Color.primary)
                        .monospacedDigit()
                        .frame(minWidth: 64)
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(isDisabled ? DesignSystem.Color.secondary : DesignSystem.Color.accent)
                        .font(DesignSystem.Font.title2)
                }
            }
            .accessibilityLabel("Custom slider")
            .accessibilityValue("\(Int(value.wrappedValue)) percent")
            .accessibilityAdjustableAction { direction in
                guard !isDisabled else { return }
                switch direction {
                case .increment: value.wrappedValue = min(value.wrappedValue + 5, 100)
                case .decrement: value.wrappedValue = max(value.wrappedValue - 5, 0)
                @unknown default: break
                }
            }
            hintBadge(text: "Swipe up/down in VoiceOver to adjust", isDisabled: isDisabled)
        }
    }

    func optionStepper(option: Binding<Int>, isDisabled: Bool) -> some View {
        let options = ["Small", "Medium", "Large", "XL"]
        return VStack(spacing: DesignSystem.Spacing.small) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(DesignSystem.Color.cardBackground)
                    .frame(height: 64)
                HStack(spacing: DesignSystem.Spacing.medium) {
                    Image(systemName: "chevron.left.circle.fill")
                        .foregroundStyle(isDisabled ? DesignSystem.Color.secondary : DesignSystem.Color.accent)
                        .font(DesignSystem.Font.title2)
                    Text(options[option.wrappedValue])
                        .font(DesignSystem.Font.title)
                        .foregroundStyle(DesignSystem.Color.primary)
                        .frame(minWidth: 80)
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundStyle(isDisabled ? DesignSystem.Color.secondary : DesignSystem.Color.accent)
                        .font(DesignSystem.Font.title2)
                }
            }
            .accessibilityLabel("Size picker")
            .accessibilityValue(options[option.wrappedValue])
            .accessibilityAdjustableAction { direction in
                guard !isDisabled else { return }
                switch direction {
                case .increment:
                    option.wrappedValue = min(option.wrappedValue + 1, options.count - 1)
                case .decrement:
                    option.wrappedValue = max(option.wrappedValue - 1, 0)
                @unknown default: break
                }
            }
            hintBadge(text: "Swipe up/down in VoiceOver to cycle options", isDisabled: isDisabled)
        }
    }

    func hintBadge(text: String, isDisabled: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "hand.point.up.left")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(isDisabled ? DesignSystem.Color.secondary : DesignSystem.Color.accent)
            Text(text)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Code generation
private extension AccessibilityAdjustableActionShowcase {
    var generatedCode: String {
        switch handlerKind {
        case .incrementDecrement:
            return """
            CustomSlider(value: $value)
                .accessibilityValue("\\(Int(value)) percent")
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: value = min(value + 1, 100)
                    case .decrement: value = max(value - 1, 0)
                    @unknown default: break
                    }
                }
            """
        case .nextPreviousOption:
            return """
            OptionPicker(selection: $index, options: options)
                .accessibilityValue(options[index])
                .accessibilityAdjustableAction { direction in
                    switch direction {
                    case .increment: index = min(index + 1, options.count - 1)
                    case .decrement: index = max(index - 1, 0)
                    @unknown default: break
                    }
                }
            """
        }
    }
}

// MARK: - Nested types
extension AccessibilityAdjustableActionShowcase {
    fileprivate enum HandlerKind: ShowcasePickable {
        case incrementDecrement
        case nextPreviousOption

        var label: String {
            switch self {
            case .incrementDecrement: "increment / decrement"
            case .nextPreviousOption: "next / previous option"
            }
        }
    }
}
