import SwiftUI

struct BindingShowcase: View {
    @State private var boundValue = false
    @State private var source: BindingSource = .fromState
    @State private var useConstant = false
    @State private var animationOption: BindingAnimation = .none

    var body: some View {
        ShowcaseScreen(
            title: "@Binding",
            summary: "A two-way reference to a source of truth owned elsewhere.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension BindingShowcase {
    fileprivate enum BindingSource: ShowcasePickable {
        case fromState, constant, getSet, fromBindable

        var label: String {
            switch self {
            case .fromState: "$state"
            case .constant: "Binding.constant"
            case .getSet: "Binding(get:set:)"
            case .fromBindable: "$bindable.property"
            }
        }

        var codeExpression: String {
            switch self {
            case .fromState: "$ownedState"
            case .constant: "Binding.constant(false)"
            case .getSet: "Binding(get: { value }, set: { value = $0 })"
            case .fromBindable: "$model.isEnabled"
            }
        }

        var childDeclaration: String {
            switch self {
            case .fromState: "@Binding var value: Bool"
            case .constant: "@Binding var value: Bool"
            case .getSet: "@Binding var value: Bool"
            case .fromBindable: "@Binding var value: Bool"
            }
        }
    }

    fileprivate enum BindingAnimation: ShowcasePickable {
        case none, defaultAnim, easeInOut, spring, bouncy

        var label: String {
            switch self {
            case .none: "none"
            case .defaultAnim: ".default"
            case .easeInOut: ".easeInOut"
            case .spring: ".spring"
            case .bouncy: ".bouncy"
            }
        }

        var animationSuffix: String {
            switch self {
            case .none: ""
            case .defaultAnim: ".animation(.default)"
            case .easeInOut: ".animation(.easeInOut)"
            case .spring: ".animation(.spring)"
            case .bouncy: ".animation(.bouncy)"
            }
        }
    }

    fileprivate enum BindingDemoState: ShowcaseState {
        case liveBinding, constantBinding, getSetBinding, animatedBinding

        var caption: String {
            switch self {
            case .liveBinding: "Live ($state)"
            case .constantBinding: "Constant"
            case .getSetBinding: "get/set"
            case .animatedBinding: "Animated"
            }
        }
    }
}

// MARK: - Sub-views
private extension BindingShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            BindingDemoChild(
                value: effectiveBinding,
                label: source.label,
            )
            Text(boundValue ? "Value: true" : "Value: false")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    var effectiveBinding: Binding<Bool> {
        let base: Binding<Bool> = useConstant
            ? .constant(boundValue)
            : $boundValue
        switch animationOption {
        case .none:
            return base
        case .defaultAnim:
            return base.animation(.default)
        case .easeInOut:
            return base.animation(.easeInOut)
        case .spring:
            return base.animation(.spring)
        case .bouncy:
            return base.animation(.bouncy)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Value (source of truth)", isOn: $boundValue)
        ShowcasePicker("Source", selection: $source)
        ShowcaseToggle("Use Binding.constant (read-only)", isOn: $useConstant)
        ShowcasePicker("Animation", selection: $animationOption)
    }

    @ViewBuilder
    func stateView(_ state: BindingDemoState) -> some View {
        switch state {
        case .liveBinding:
            BindingDemoChild(value: $boundValue, label: "$state")
        case .constantBinding:
            BindingDemoChild(value: .constant(true), label: ".constant(true)")
        case .getSetBinding:
            BindingDemoChild(
                value: Binding(get: { boundValue }, set: { boundValue = $0 }),
                label: "get/set",
            )
        case .animatedBinding:
            BindingDemoChild(
                value: $boundValue.animation(.spring),
                label: ".animation(.spring)",
            )
        }
    }
}

// MARK: - Child demo view
private struct BindingDemoChild: View {
    @Binding var value: Bool
    let label: String

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Toggle(isOn: $value) {
                Text("Bound value")
                    .font(DesignSystem.Font.body)
            }
            .padding(DesignSystem.Spacing.medium)
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))

            Text("Binding source: \(label)")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Code generation
private extension BindingShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("// Child view")
        lines.append("struct ChildView: View {")
        lines.append("    \(source.childDeclaration)")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        Toggle(\"Bound value\", isOn: $value)")
        lines.append("    }")
        lines.append("}")
        lines.append("")
        lines.append("// Parent view")
        lines.append("struct ParentView: View {")
        lines.append("    @State private var ownedState = false")
        lines.append("")
        lines.append("    var body: some View {")
        let binding = bindingExpression
        lines.append("        ChildView(value: \(binding))")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var bindingExpression: String {
        var base = source.codeExpression
        if useConstant && source == .fromState {
            base = "Binding.constant(ownedState)"
        }
        let suffix = animationOption.animationSuffix
        return suffix.isEmpty ? base : "\(base)\(suffix)"
    }
}
