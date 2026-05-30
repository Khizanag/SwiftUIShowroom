import SwiftUI

struct TransformPreferenceShowcase: View {
    @State private var transformOp: TransformOp = .addOne
    @State private var itemCount: Int = 3
    @State private var applyTransform = true

    var body: some View {
        ShowcaseScreen(
            title: ".transformPreference(_:_:)",
            summary: "Modifies a PreferenceKey value in place as it propagates up, deriving it from the current value.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension TransformPreferenceShowcase {
    fileprivate enum TransformOp: ShowcasePickable {
        case addOne, double, clamp, noop

        var label: String {
            switch self {
            case .addOne: "value += 1"
            case .double: "value *= 2"
            case .clamp: "clamp to 5"
            case .noop: "no-op"
            }
        }

        var codeSnippet: String {
            switch self {
            case .addOne: "value += 1"
            case .double: "value *= 2"
            case .clamp: "value = min(value, 5)"
            case .noop: "_ = value"
            }
        }
    }

    fileprivate enum DemoState: ShowcaseState {
        case baseline, addOffset, chainedTransforms, clampedMax

        var caption: String {
            switch self {
            case .baseline: "Baseline"
            case .addOffset: "Add offset"
            case .chainedTransforms: "Chained"
            case .clampedMax: "Clamped max"
            }
        }
    }

    fileprivate struct CountKey: PreferenceKey {
        static let defaultValue: Int = 0
        static func reduce(value: inout Int, nextValue: () -> Int) {
            value += nextValue()
        }
    }
}

// MARK: - Sub-views
private extension TransformPreferenceShowcase {
    var preview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Items reporting count = 1; transform adjusts the total")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            itemRows
            reportedValueRow
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var itemRows: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            ForEach(0..<itemCount, id: \.self) { index in
                rowView(index: index)
            }
        }
        .transformPreference(CountKey.self) { value in
            if applyTransform {
                applyOp(transformOp, to: &value)
            }
        }
        .onPreferenceChange(CountKey.self) { _ in }
    }

    func rowView(index: Int) -> some View {
        HStack {
            Text("Item \(index + 1)")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
            Text("count: 1")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .preference(key: CountKey.self, value: 1)
    }

    var reportedValueRow: some View {
        HStack {
            Text("Reported total after transform:")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
            Spacer()
            Text(computedTotal)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }

    var computedTotal: String {
        var value = itemCount
        if applyTransform {
            applyOp(transformOp, to: &value)
        }
        return "\(value)"
    }

    func applyOp(_ operation: TransformOp, to value: inout Int) {
        switch operation {
        case .addOne: value += 1
        case .double: value *= 2
        case .clamp: value = min(value, 5)
        case .noop: break
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Transform operation", selection: $transformOp)
        ShowcaseStepper("Item count", value: $itemCount, in: 1...6)
        ShowcaseToggle("Apply transform", isOn: $applyTransform)
    }

    @ViewBuilder
    func stateView(_ state: DemoState) -> some View {
        switch state {
        case .baseline:
            baselineDemo
        case .addOffset:
            addOffsetDemo
        case .chainedTransforms:
            chainedDemo
        case .clampedMax:
            clampedDemo
        }
    }

    var baselineDemo: some View {
        demoCard(label: "No transform — total = item count") {
            twoItemStack
                .onPreferenceChange(CountKey.self) { _ in }
        }
    }

    var addOffsetDemo: some View {
        demoCard(label: "transformPreference: value += 10") {
            twoItemStack
                .transformPreference(CountKey.self) { $0 += 10 }
                .onPreferenceChange(CountKey.self) { _ in }
        }
    }

    var chainedDemo: some View {
        demoCard(label: "Chain: += 1, then *= 2") {
            twoItemStack
                .transformPreference(CountKey.self) { $0 += 1 }
                .transformPreference(CountKey.self) { $0 *= 2 }
                .onPreferenceChange(CountKey.self) { _ in }
        }
    }

    var clampedDemo: some View {
        demoCard(label: "transformPreference: clamp to max 3") {
            twoItemStack
                .transformPreference(CountKey.self) { $0 = min($0, 3) }
                .onPreferenceChange(CountKey.self) { _ in }
        }
    }

    var twoItemStack: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            staticRow(label: "Item A")
            staticRow(label: "Item B")
        }
    }

    func staticRow(label: String) -> some View {
        HStack {
            Text(label)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
            Spacer()
        }
        .padding(DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.background)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        .preference(key: CountKey.self, value: 1)
    }

    func demoCard(label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
            content()
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension TransformPreferenceShowcase {
    var generatedCode: String {
        let transform = transformOp.codeSnippet
        let applyLine = applyTransform
            ? "    .transformPreference(CountKey.self) { value in\n        \(transform)\n    }"
            : "    // transform disabled"
        return [
            "struct CountKey: PreferenceKey {",
            "    static let defaultValue: Int = 0",
            "    static func reduce(value: inout Int, nextValue: () -> Int) {",
            "        value += nextValue()",
            "    }",
            "}",
            "",
            "// In the container view:",
            "content",
            applyLine,
            "    .onPreferenceChange(CountKey.self) { total in",
            "        reportedTotal = total",
            "    }",
        ].joined(separator: "\n")
    }
}
