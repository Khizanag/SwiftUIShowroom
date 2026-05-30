import SwiftUI

struct AccessibilitySortPriorityShowcase: View {
    @State private var priority: Double = 0

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Sort Priority",
            summary: "Adjusts the order VoiceOver visits elements in a container; higher value visited first.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilitySortPriorityShowcase {
    var preview: some View {
        sortPriorityDemo(priority: priority)
    }

    @ViewBuilder var controls: some View {
        ShowcaseStepper("Priority", value: Binding(
            get: { Int(priority) },
            set: { priority = Double($0) }
        ), in: -10...10)
    }

    @ViewBuilder func stateView(_ state: SortPriorityState) -> some View {
        sortPriorityDemo(priority: state.priority)
    }

    @ViewBuilder func sortPriorityDemo(priority: Double) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack(spacing: DesignSystem.Spacing.small) {
                priorityBadge(priority: priority)
                Text("Call to action")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                    .accessibilitySortPriority(priority)
                Spacer()
            }
            .padding(DesignSystem.Spacing.small)
            .background(
                DesignSystem.Color.accent.opacity(0.12),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )

            HStack(spacing: DesignSystem.Spacing.small) {
                priorityBadge(priority: 0)
                Text("Secondary detail")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .accessibilitySortPriority(0)
                Spacer()
            }
            .padding(DesignSystem.Spacing.small)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )

            Text("Priority \(formattedPriority(priority)) — element visited \(visitOrder(priority))")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder func priorityBadge(priority: Double) -> some View {
        Text(formattedPriority(priority))
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.xSmall)
            .padding(.vertical, DesignSystem.Spacing.hairline)
            .background(badgeColor(priority: priority), in: Capsule())
    }

    func formattedPriority(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(format: "%.1f", value)
    }

    func visitOrder(_ value: Double) -> String {
        value > 0 ? "before default elements" : value < 0 ? "after default elements" : "in layout order"
    }

    func badgeColor(priority: Double) -> Color {
        priority > 0 ? DesignSystem.Color.accent : priority < 0 ? DesignSystem.Color.secondary : .gray
    }
}

// MARK: - Code generation
private extension AccessibilitySortPriorityShowcase {
    var generatedCode: String {
        let priorityArg = formattedPriority(priority)
        return """
        VStack {
            DetailText()
            CallToActionButton()
                .accessibilitySortPriority(\(priorityArg))
        }
        .accessibilityElement(children: .contain)
        """
    }
}

// MARK: - Nested types
extension AccessibilitySortPriorityShowcase {
    fileprivate enum SortPriorityState: ShowcaseState {
        case `default`
        case elevated
        case deprioritized

        var caption: String {
            switch self {
            case .default: "Default (0)"
            case .elevated: "Elevated (+5)"
            case .deprioritized: "Deprioritized (-5)"
            }
        }

        var priority: Double {
            switch self {
            case .default: 0
            case .elevated: 5
            case .deprioritized: -5
            }
        }
    }
}
