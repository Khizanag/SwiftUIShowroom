import SwiftUI

struct IsFocusedEnvironmentShowcase: View {
    enum AccentOption: ShowcasePickable {
        case blue
        case orange
        case purple
        case green

        var label: String {
            switch self {
            case .blue: "Blue"
            case .orange: "Orange"
            case .purple: "Purple"
            case .green: "Green"
            }
        }

        var color: Color {
            switch self {
            case .blue: .accentColor
            case .orange: .orange
            case .purple: .purple
            case .green: .green
            }
        }
    }

    enum FocusDisplayState: ShowcaseState {
        case `default`
        case focused

        var caption: String {
            switch self {
            case .default: "Unfocused"
            case .focused: "Focused"
            }
        }
    }

    @State private var accentColorOption: AccentOption = .blue
    @State private var showScale = true
    @State private var showBackground = true
    @FocusState private var isPreviewFocused: Bool

    var body: some View {
        ShowcaseScreen(
            title: "\\.isFocused (Environment)",
            summary: "Read-only env value: true when the nearest focusable ancestor currently has focus.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension IsFocusedEnvironmentShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            focusInstructionLabel
            FocusReactiveCard(
                accentColor: accentColorOption.color,
                showScale: showScale,
                showBackground: showBackground,
            )
            .focused($isPreviewFocused)
            focusToggleButton
        }
        .padding(DesignSystem.Spacing.large)
    }

    var focusInstructionLabel: some View {
        Text(isPreviewFocused ? "Card is focused — isFocused = true" : "Card is unfocused — isFocused = false")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(isPreviewFocused ? accentColorOption.color : DesignSystem.Color.secondary)
            .animation(.easeInOut(duration: 0.2), value: isPreviewFocused)
    }

    var focusToggleButton: some View {
        Button(isPreviewFocused ? "Resign Focus" : "Give Focus") {
            isPreviewFocused.toggle()
        }
        .buttonStyle(.bordered)
        .tint(accentColorOption.color)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Accent color", selection: $accentColorOption)
        ShowcaseToggle("Scale effect on focus", isOn: $showScale)
        ShowcaseToggle("Background highlight on focus", isOn: $showBackground)
    }

    @ViewBuilder
    func stateView(_ state: FocusDisplayState) -> some View {
        StaticFocusCard(
            isFocused: state == .focused,
            accentColor: accentColorOption.color,
            showScale: showScale,
            showBackground: showBackground,
        )
    }
}

// MARK: - Code generation
private extension IsFocusedEnvironmentShowcase {
    var generatedCode: String {
        var lines = [
            "struct FocusReactiveRow: View {",
            "    @Environment(\\.isFocused) private var isFocused",
            "",
            "    var body: some View {",
            "        Text(\"Row\")",
            "            .padding()",
        ]
        if showBackground {
            lines.append(
                "            .background(isFocused ? Color.accentColor.opacity(0.15) : Color.clear)"
            )
        }
        if showScale {
            lines.append(
                "            .scaleEffect(isFocused ? 1.05 : 1.0)"
            )
        }
        lines.append(contentsOf: [
            "            .animation(.easeInOut(duration: 0.2), value: isFocused)",
            "            .focusable()",
            "    }",
            "}",
        ])
        return lines.joined(separator: "\n")
    }
}

// MARK: - FocusReactiveCard
private struct FocusReactiveCard: View {
    let accentColor: Color
    let showScale: Bool
    let showBackground: Bool

    @Environment(\.isFocused) private var isFocused

    var body: some View {
        cardContent
            .scaleEffect(showScale && isFocused ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
            .focusable()
    }

    private var cardContent: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: isFocused ? "bolt.fill" : "bolt")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isFocused ? accentColor : DesignSystem.Color.secondary)
            Text("FocusReactiveCard")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(isFocused ? "@Environment(\\.isFocused) → true" : "@Environment(\\.isFocused) → false")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(isFocused ? accentColor : DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(minWidth: 240)
        .background(
            showBackground
                ? (isFocused ? accentColor.opacity(0.12) : DesignSystem.Color.cardBackground)
                : DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(
                    isFocused ? accentColor : Color.clear,
                    lineWidth: 2
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - StaticFocusCard
private struct StaticFocusCard: View {
    let isFocused: Bool
    let accentColor: Color
    let showScale: Bool
    let showBackground: Bool

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: isFocused ? "bolt.fill" : "bolt")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isFocused ? accentColor : DesignSystem.Color.secondary)
            Text(isFocused ? "isFocused = true" : "isFocused = false")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(isFocused ? accentColor : DesignSystem.Color.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(minWidth: 200)
        .scaleEffect(showScale && isFocused ? 1.06 : 1.0)
        .background(
            showBackground
                ? (isFocused ? accentColor.opacity(0.12) : DesignSystem.Color.cardBackground)
                : DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(
                    isFocused ? accentColor : Color.clear,
                    lineWidth: 2
                )
        )
    }
}
