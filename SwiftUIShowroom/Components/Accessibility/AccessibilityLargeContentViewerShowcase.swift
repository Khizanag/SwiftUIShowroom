import SwiftUI

struct AccessibilityLargeContentViewerShowcase: View {
    fileprivate enum ViewerState: ShowcaseState {
        case viewerEnabled
        case viewerDisabled

        var caption: String {
            switch self {
            case .viewerEnabled: "Viewer enabled"
            case .viewerDisabled: "Viewer disabled"
            }
        }

        var isEnabled: Bool {
            switch self {
            case .viewerEnabled: true
            case .viewerDisabled: false
            }
        }
    }

    @State private var isEnabled = true
    @State private var labelText = "Home"
    @State private var isViewerActive = false

    var body: some View {
        ShowcaseScreen(
            title: "Large Content Viewer",
            summary: "Shows an enlarged HUD of label/image when a Larger Text user long-presses it.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityLargeContentViewerShowcase {
    var preview: some View {
        tabBarMockup(label: labelText, isEnabled: isEnabled)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl(
            "Label",
            text: $labelText,
            prompt: "e.g. Home",
        )
        ShowcaseToggle("Large Content Viewer enabled", isOn: $isEnabled)
        ShowcaseToggle("Simulate viewer active (env)", isOn: $isViewerActive)
    }

    @ViewBuilder func stateView(_ state: ViewerState) -> some View {
        tabBarMockup(label: "Home", isEnabled: state.isEnabled)
    }

    @ViewBuilder func tabBarMockup(label: String, isEnabled: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            hudPreview(label: label, isViewerSimulated: isViewerActive)
            tabBarRow(label: label, isEnabled: isEnabled)
            Text(
                isEnabled
                    ? "Long-press any tab icon to see the enlarged HUD"
                    : "Large Content Viewer disabled",
            )
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func tabBarRow(label: String, isEnabled: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.large) {
            tabIcon(systemImage: "house", label: label, isEnabled: isEnabled)
            tabIcon(systemImage: "magnifyingglass", label: "Search", isEnabled: isEnabled)
            tabIcon(systemImage: "bell", label: "Notifications", isEnabled: isEnabled)
            tabIcon(systemImage: "person", label: "Profile", isEnabled: isEnabled)
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
        .background(.bar)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder func tabIcon(systemImage: String, label: String, isEnabled: Bool) -> some View {
        let iconView = Image(systemName: systemImage)
            .font(DesignSystem.Font.title2)
            .foregroundStyle(DesignSystem.Color.accent)
            .accessibilityLabel(label)
#if !os(macOS)
        if isEnabled {
            iconView.accessibilityShowsLargeContentViewer {
                Label(label, systemImage: systemImage)
            }
        } else {
            iconView
        }
#else
        iconView
#endif
    }

    @ViewBuilder func hudPreview(label: String, isViewerSimulated: Bool) -> some View {
        if isViewerSimulated {
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "house")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                Text(label)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
            .padding(DesignSystem.Spacing.medium)
            .background(Color.black.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
    }
}

// MARK: - Code generation
private extension AccessibilityLargeContentViewerShowcase {
    var generatedCode: String {
        if isEnabled {
            return """
            TabIconView(systemImage: "house")
                .accessibilityShowsLargeContentViewer {
                    Label("\(labelText)", systemImage: "house")
                }
            """
        } else {
            return """
            TabIconView(systemImage: "house")
            """
        }
    }
}
