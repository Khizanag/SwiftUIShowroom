import SwiftUI

struct WindowDragGestureShowcase: View {
    @State private var isEnabled: Bool = true
    @State private var allowsWindowActivation: Bool = true
    #if os(macOS)
    @GestureState private var isDragging: Bool = false
    #endif

    var body: some View {
        ShowcaseScreen(
            title: "Window Drag Gesture",
            summary: "Recognizes a drag and moves the containing window, for custom title-bar regions.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension WindowDragGestureShowcase {
    var preview: some View {
        #if os(macOS)
        macOSPreview
        #else
        platformUnavailableNotice
        #endif
    }

    #if os(macOS)
    var macOSPreview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            dragHandle
            previewHint
        }
        .padding(DesignSystem.Spacing.medium)
    }

    var dragHandle: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(handleFill)
            .frame(width: 200, height: 80)
            .overlay(handleOverlay)
            .animation(.easeInOut(duration: 0.15), value: isDragging)
            .gesture(
                WindowDragGesture()
                    .updating($isDragging) { _, state, _ in state = true },
                isEnabled: isEnabled
            )
            .allowsWindowActivationEvents(allowsWindowActivation)
    }

    var handleFill: some ShapeStyle {
        if isDragging {
            return AnyShapeStyle(Color.green.opacity(0.85))
        } else if isEnabled {
            return AnyShapeStyle(DesignSystem.Color.accent.opacity(0.85))
        } else {
            return AnyShapeStyle(DesignSystem.Color.secondary.opacity(0.4))
        }
    }

    var handleOverlay: some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: isDragging ? "arrow.up.and.down.and.left.and.right" : "minus.rectangle")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.onAccent)
            Text(isDragging ? "Dragging window…" : (isEnabled ? "Drag to move window" : "Drag disabled"))
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
    }

    var previewHint: some View {
        Text("Dragging the handle above moves this window")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
            .multilineTextAlignment(.center)
    }
    #endif

    var platformUnavailableNotice: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: "macwindow.slash")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("macOS only")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("WindowDragGesture requires macOS 15.0+")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.large)
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Enabled", isOn: $isEnabled)
        ShowcaseToggle("Allows window activation events", isOn: $allowsWindowActivation)
    }

    @ViewBuilder func stateView(_ state: WindowDragState) -> some View {
        switch state {
        case .default:
            galleryHandle(
                fill: DesignSystem.Color.accent.opacity(0.85),
                icon: "minus.rectangle",
                label: "Idle"
            )
        case .disabled:
            galleryHandle(
                fill: DesignSystem.Color.secondary.opacity(0.4),
                icon: "minus.rectangle",
                label: "Disabled"
            )
        case .selected:
            galleryHandle(
                fill: Color.green.opacity(0.85),
                icon: "arrow.up.and.down.and.left.and.right",
                label: "Dragging"
            )
        }
    }

    func galleryHandle(fill: some ShapeStyle, icon: String, label: String) -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(fill)
            .frame(width: 140, height: 60)
            .overlay(
                HStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: icon)
                        .font(DesignSystem.Font.callout)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                    Text(label)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                }
            )
    }
}

// MARK: - Nested types
extension WindowDragGestureShowcase {
    fileprivate enum WindowDragState: ShowcaseState {
        case `default`
        case disabled
        case selected

        var caption: String {
            switch self {
            case .default: "Idle — ready to drag"
            case .disabled: "Disabled — gesture inactive"
            case .selected: "Active — window moving"
            }
        }
    }
}

// MARK: - Code generation
private extension WindowDragGestureShowcase {
    var generatedCode: String {
        let activationLine = allowsWindowActivation
            ? ".allowsWindowActivationEvents(true)"
            : ".allowsWindowActivationEvents(false)"
        let enabledLine = isEnabled
            ? ""
            : ",\n        isEnabled: false"
        return [
            "#if os(macOS)",
            "struct WindowDragDemo: View {",
            "    @GestureState private var isDragging = false",
            "",
            "    var body: some View {",
            "        RoundedRectangle(cornerRadius: 16)",
            "            .fill(isDragging ? Color.green : .blue)",
            "            .frame(width: 200, height: 80)",
            "            .gesture(",
            "                WindowDragGesture()\(enabledLine)",
            "                    .updating($isDragging) { _, state, _ in state = true }",
            "            )",
            "            \(activationLine)",
            "    }",
            "}",
            "#endif",
        ].joined(separator: "\n")
    }
}
