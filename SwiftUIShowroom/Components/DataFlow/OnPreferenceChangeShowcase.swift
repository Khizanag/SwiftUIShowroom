import SwiftUI

struct OnPreferenceChangeShowcase: View {
    @State private var itemCount: Int = 3
    @State private var reduceStrategy: ReduceStrategyOption = .max
    @State private var capturedValue: CGFloat = 0

    var body: some View {
        ShowcaseScreen(
            title: "onPreferenceChange",
            summary: "Runs a closure whenever a PreferenceKey's reduced value changes in the view tree.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension OnPreferenceChangeShowcase {
    fileprivate enum ReduceStrategyOption: ShowcasePickable {
        case max, min, sum, takeLast

        var label: String {
            switch self {
            case .max: "max"
            case .min: "min"
            case .sum: "sum"
            case .takeLast: "takeLast"
            }
        }

        var reduceBody: String {
            switch self {
            case .max: "value = max(value, nextValue())"
            case .min: "value = min(value, nextValue())"
            case .sum: "value += nextValue()"
            case .takeLast: "value = nextValue()"
            }
        }

        func reduce(current: inout CGFloat, next: CGFloat) {
            switch self {
            case .max: current = Swift.max(current, next)
            case .min: current = Swift.min(current, next)
            case .sum: current += next
            case .takeLast: current = next
            }
        }
    }

    fileprivate enum DemoState: ShowcaseState {
        case singleItem
        case manyItems
        case sumStrategy

        var caption: String {
            switch self {
            case .singleItem: "Single item"
            case .manyItems: "Many items"
            case .sumStrategy: "Sum strategy"
            }
        }
    }
}

// MARK: - Sub-views
private extension OnPreferenceChangeShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            itemsStack(count: itemCount, strategy: reduceStrategy)
            captureLabel
        }
        .padding(DesignSystem.Spacing.medium)
    }

    func itemsStack(count: Int, strategy: ReduceStrategyOption) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ForEach(0..<count, id: \.self) { index in
                let width = CGFloat(60 + index * 20)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.accent.opacity(0.2))
                    .frame(width: width, height: 36)
                    .overlay(
                        Text("\(Int(width)) pt")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.secondary),
                    )
                    .preference(key: SumWidthKey.self, value: width)
            }
        }
        .onPreferenceChange(SumWidthKey.self) { @MainActor newValue in
            capturedValue = newValue
        }
    }

    var captureLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "arrow.up.to.line")
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Captured: \(Int(capturedValue)) pt")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .animation(.easeInOut, value: capturedValue)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseStepper("Item count", value: $itemCount, in: 1...6)
        ShowcasePicker("Reduce strategy", selection: $reduceStrategy)
    }

    @ViewBuilder
    func stateView(_ state: DemoState) -> some View {
        switch state {
        case .singleItem:
            stateItemsStack(count: 1, label: "60 pt")
        case .manyItems:
            stateItemsStack(count: 5, label: "140 pt")
        case .sumStrategy:
            sumStrategyView
        }
    }

    func stateItemsStack(count: Int, label: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            ForEach(0..<count, id: \.self) { index in
                let width = CGFloat(60 + index * 20)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                    .fill(DesignSystem.Color.accent.opacity(0.15))
                    .frame(width: width, height: 28)
            }
            Text("max → \(label)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    var sumStrategyView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Text("reduce(value:nextValue:)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("value += nextValue()")
                .font(DesignSystem.Font.codeInline)
                .foregroundStyle(DesignSystem.Color.primary)
                .padding(DesignSystem.Spacing.small)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
        }
    }
}

// MARK: - Code generation
private extension OnPreferenceChangeShowcase {
    var generatedCode: String {
        let lines = [
            "struct MaxWidthKey: PreferenceKey {",
            "    static let defaultValue: CGFloat = 0",
            "    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {",
            "        \(reduceStrategy.reduceBody)",
            "    }",
            "}",
            "",
            "VStack {",
            "    ForEach(items) { item in",
            "        Row(item: item)",
            "            .preference(key: MaxWidthKey.self, value: item.width)",
            "    }",
            "}",
            ".onPreferenceChange(MaxWidthKey.self) { @MainActor newValue in",
            "    capturedWidth = newValue",
            "}",
        ]
        return lines.joined(separator: "\n")
    }
}

// MARK: - PreferenceKey
private struct SumWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
