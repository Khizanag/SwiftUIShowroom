import SwiftUI

struct AccessibilityIdentifierShowcase: View {
    @State private var identifier = "favorite-button"
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Identifier",
            summary: "Sets a stable, non-localized identifier for UI tests and automation, not spoken to users.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityIdentifierShowcase {
    var preview: some View {
        identifierDemo(
            identifier: identifier,
            isEnabled: isEnabled,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl(
            "Identifier",
            text: $identifier,
            prompt: "e.g. favorite-button",
        )
        ShowcaseToggle("isEnabled", isOn: $isEnabled)
    }

    @ViewBuilder func stateView(_ state: IdentifierState) -> some View {
        identifierDemo(
            identifier: state.identifier,
            isEnabled: state.isApplied,
        )
    }

    @ViewBuilder func identifierDemo(
        identifier: String,
        isEnabled: Bool,
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Button {
            } label: {
                Label("Favorite", systemImage: "heart.fill")
                    .font(DesignSystem.Font.body)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier(identifier, isEnabled: isEnabled)

            VStack(spacing: DesignSystem.Spacing.xSmall) {
                HStack(spacing: DesignSystem.Spacing.xSmall) {
                    Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle.dashed")
                        .foregroundStyle(isEnabled ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                    Text(isEnabled ? "ID applied: \"\(identifier)\"" : "ID not applied")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
                Text("XCUITest: app.buttons[\"\(identifier)\"]")
                    .font(DesignSystem.Font.code)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .opacity(isEnabled ? 1 : 0.4)
            }
        }
        .padding(DesignSystem.Spacing.medium)
    }
}

// MARK: - Code generation
private extension AccessibilityIdentifierShowcase {
    var generatedCode: String {
        let enabledArg = isEnabled ? "" : ", isEnabled: false"
        return """
        Button("Favorite") { }
            .accessibilityIdentifier("\(identifier)"\(enabledArg))
        """
    }
}

// MARK: - Nested types
extension AccessibilityIdentifierShowcase {
    fileprivate enum IdentifierState: ShowcaseState {
        case `default`
        case disabled

        var caption: String {
            switch self {
            case .default: "Identifier applied"
            case .disabled: "isEnabled: false — no ID set"
            }
        }

        var identifier: String {
            switch self {
            case .default: "favorite-button"
            case .disabled: "favorite-button"
            }
        }

        var isApplied: Bool {
            switch self {
            case .default: true
            case .disabled: false
            }
        }
    }
}
