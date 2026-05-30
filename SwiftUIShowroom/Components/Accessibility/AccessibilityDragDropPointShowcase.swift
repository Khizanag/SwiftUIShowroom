import SwiftUI

struct AccessibilityDragDropPointShowcase: View {
    enum DragDropPointOption: ShowcasePickable {
        case center, top, bottom, leading, trailing

        var label: String {
            switch self {
            case .center: return "center"
            case .top: return "top"
            case .bottom: return "bottom"
            case .leading: return "leading"
            case .trailing: return "trailing"
            }
        }

        var unitPoint: UnitPoint {
            switch self {
            case .center: return .center
            case .top: return .top
            case .bottom: return .bottom
            case .leading: return .leading
            case .trailing: return .trailing
            }
        }
    }

    enum DragDropState: ShowcaseState {
        case dragAndDrop
        case dragOnly
        case disabled

        var caption: String {
            switch self {
            case .dragAndDrop: return "Drag & drop (both)"
            case .dragOnly: return "Drag only"
            case .disabled: return "isEnabled: false"
            }
        }
    }

    @State private var dragPoint = DragDropPointOption.center
    @State private var dropPoint = DragDropPointOption.center
    @State private var descriptionText = "Move to Favorites"
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Drag & Drop Points",
            summary: "Exposes drag-and-drop targets to assistive tech as discrete, described points.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityDragDropPointShowcase {
    var preview: some View {
        dragDropCard(
            dragPoint: dragPoint.unitPoint,
            dropPoint: dropPoint.unitPoint,
            description: descriptionText,
            isEnabled: isEnabled,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Drag point", selection: $dragPoint)
        ShowcasePicker("Drop point", selection: $dropPoint)
        ShowcaseTextControl(
            "Description",
            text: $descriptionText,
            prompt: "e.g. Move to Favorites",
        )
        ShowcaseToggle("isEnabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: DragDropState) -> some View {
        switch state {
        case .dragAndDrop:
            dragDropCard(
                dragPoint: .center,
                dropPoint: .center,
                description: "Move to Favorites",
                isEnabled: true,
            )
        case .dragOnly:
            dragOnlyCard(description: "Drag item")
        case .disabled:
            dragDropCard(
                dragPoint: .center,
                dropPoint: .center,
                description: "Move to Favorites",
                isEnabled: false,
            )
        }
    }
}

// MARK: - Component builders
private extension AccessibilityDragDropPointShowcase {
    func dragDropCard(
        dragPoint: UnitPoint,
        dropPoint: UnitPoint,
        description: String,
        isEnabled: Bool
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            cardContent(
                icon: "hand.draw",
                title: "Draggable Card",
                subtitle: "Drag or drop with VoiceOver",
            )
            badgeRow(dragPoint: dragPoint, dropPoint: dropPoint, isEnabled: isEnabled)
        }
        .padding(DesignSystem.Spacing.large)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        #if !os(tvOS)
        .accessibilityDragPoint(dragPoint, description: description)
        .accessibilityDropPoint(dropPoint, description: description)
        #endif
        .disabled(!isEnabled)
    }

    func dragOnlyCard(description: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            cardContent(
                icon: "arrow.up.and.down.and.arrow.left.and.right",
                title: "Source Card",
                subtitle: "Only a drag point — no drop target",
            )
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "hand.point.up.left")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("Drag: center")
                    .font(DesignSystem.Font.footnote)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.large)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        #if !os(tvOS)
        .accessibilityDragPoint(.center, description: description)
        #endif
    }

    func cardContent(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(
                    width: DesignSystem.Size.Icon.xLarge,
                    height: DesignSystem.Size.Icon.xLarge,
                )
            Text(title)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(subtitle)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
    }

    func badgeRow(dragPoint: UnitPoint, dropPoint: UnitPoint, isEnabled: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            pointBadge(systemImage: "hand.point.up.left", label: "Drag: \(pointName(dragPoint))")
            pointBadge(systemImage: "arrow.down.to.line", label: "Drop: \(pointName(dropPoint))")
            if !isEnabled {
                pointBadge(systemImage: "slash.circle", label: "Disabled")
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }

    func pointBadge(systemImage: String, label: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: systemImage)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.small)
        .padding(.vertical, DesignSystem.Spacing.xSmall)
        .background(DesignSystem.Color.accent.opacity(0.1))
        .clipShape(Capsule())
    }

    func pointName(_ point: UnitPoint) -> String {
        switch point {
        case .center: return "center"
        case .top: return "top"
        case .bottom: return "bottom"
        case .leading: return "leading"
        case .trailing: return "trailing"
        case .topLeading: return "topLeading"
        case .topTrailing: return "topTrailing"
        case .bottomLeading: return "bottomLeading"
        case .bottomTrailing: return "bottomTrailing"
        default: return "custom"
        }
    }
}

// MARK: - Code generation
private extension AccessibilityDragDropPointShowcase {
    var generatedCode: String {
        let dragArg = dragPoint.label
        let dropArg = dropPoint.label
        if isEnabled {
            return """
            DraggableCard()
                .accessibilityDragPoint(.\(dragArg), description: "\(descriptionText)")
                .accessibilityDropPoint(.\(dropArg), description: "\(descriptionText)")
            """
        } else {
            return """
            DraggableCard()
                .accessibilityDragPoint(.\(dragArg), description: "\(descriptionText)")
                .accessibilityDropPoint(.\(dropArg), description: "\(descriptionText)")
                .disabled(true)
            """
        }
    }
}
