import SwiftUI

struct DynamicTypeSizeShowcase: View {
    @State private var selectedSize: TypeSizeOption = .large
    @State private var selectedRange: TypeRangeOption = .full
    @State private var useRange = false

    var body: some View {
        ShowcaseScreen(
            title: "Dynamic Type Size",
            summary: "Constrains or overrides the Dynamic Type size for a subtree.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension DynamicTypeSizeShowcase {
    var preview: some View {
        DemoCard(
            size: selectedSize.value,
            range: selectedRange.value,
            useRange: useRange,
            label: "Dynamic Type",
            detail: "Text scales with the user's preference.",
        )
        .padding(DesignSystem.Spacing.medium)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Size", selection: $selectedSize)
        ShowcaseToggle("Use range instead of fixed size", isOn: $useRange)
        ShowcasePicker("Range", selection: $selectedRange)
    }

    @ViewBuilder func stateView(_ state: ContentState) -> some View {
        switch state {
        case .default:
            DemoCard(
                size: DynamicTypeSize.large,
                range: TypeRangeOption.full.value,
                useRange: false,
                label: "Dynamic Type",
                detail: "Text scales with the user's preference.",
            )
        case .longContent:
            DemoCard(
                size: DynamicTypeSize.large,
                range: TypeRangeOption.full.value,
                useRange: false,
                label: "Longer body content",
                detail: "When text is long it wraps gracefully. Support all sizes through accessibility5.",
            )
        }
    }
}

// MARK: - Code generation
private extension DynamicTypeSizeShowcase {
    var generatedCode: String {
        if useRange {
            return """
            VStack {
                Text("Scales with Dynamic Type")
            }
            .dynamicTypeSize(\(selectedRange.rangeLabel))
            """
        } else {
            return """
            VStack {
                Text("Scales with Dynamic Type")
            }
            .environment(\\.dynamicTypeSize, .\(selectedSize.codeLabel))
            """
        }
    }
}

// MARK: - Demo components
private struct DemoCard: View {
    let size: DynamicTypeSize
    let range: ClosedRange<DynamicTypeSize>
    let useRange: Bool
    let label: String
    let detail: String

    private var isAxSize: Bool { size.isAccessibilitySize }

    var body: some View {
        Group {
            if isAxSize {
                axLayout
            } else {
                standardLayout
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .applyDynamicType(size: size, range: range, useRange: useRange)
    }

    private var standardLayout: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.small) {
            Image(systemName: "text.magnifyingglass")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text(label)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(detail)
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }

    private var axLayout: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "text.magnifyingglass")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(label)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(detail)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - View modifier helper
private extension View {
    @ViewBuilder func applyDynamicType(
        size: DynamicTypeSize,
        range: ClosedRange<DynamicTypeSize>,
        useRange: Bool,
    ) -> some View {
        if useRange {
            self.dynamicTypeSize(range)
        } else {
            self.environment(\.dynamicTypeSize, size)
        }
    }
}

// MARK: - Nested types
extension DynamicTypeSizeShowcase {
    fileprivate enum TypeSizeOption: ShowcasePickable {
        case xSmall, small, medium, large, xLarge, xxLarge, xxxLarge
        case accessibility1, accessibility2, accessibility3, accessibility4, accessibility5

        private static let metadata: [(TypeSizeOption, String, DynamicTypeSize)] = [
            (.xSmall, "xSmall", .xSmall),
            (.small, "small", .small),
            (.medium, "medium", .medium),
            (.large, "large (default)", .large),
            (.xLarge, "xLarge", .xLarge),
            (.xxLarge, "xxLarge", .xxLarge),
            (.xxxLarge, "xxxLarge", .xxxLarge),
            (.accessibility1, "accessibility1", .accessibility1),
            (.accessibility2, "accessibility2", .accessibility2),
            (.accessibility3, "accessibility3", .accessibility3),
            (.accessibility4, "accessibility4", .accessibility4),
            (.accessibility5, "accessibility5", .accessibility5),
        ]

        var label: String {
            Self.metadata.first(where: { $0.0 == self })?.1 ?? ""
        }

        var codeLabel: String {
            switch self {
            case .large: "large"
            default: label
            }
        }

        var value: DynamicTypeSize {
            Self.metadata.first(where: { $0.0 == self })?.2 ?? .large
        }
    }

    fileprivate enum TypeRangeOption: ShowcasePickable {
        case full
        case standardOnly
        case capped

        var label: String {
            switch self {
            case .full: "xSmall...accessibility5"
            case .standardOnly: "large...xxxLarge"
            case .capped: "xSmall...xxxLarge"
            }
        }

        var rangeLabel: String {
            switch self {
            case .full: ".xSmall ... .accessibility5"
            case .standardOnly: ".large ... .xxxLarge"
            case .capped: ".xSmall ... .xxxLarge"
            }
        }

        var value: ClosedRange<DynamicTypeSize> {
            switch self {
            case .full: .xSmall ... .accessibility5
            case .standardOnly: .large ... .xxxLarge
            case .capped: .xSmall ... .xxxLarge
            }
        }
    }

    fileprivate enum ContentState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (large)"
            case .longContent: "Long content"
            }
        }
    }
}
