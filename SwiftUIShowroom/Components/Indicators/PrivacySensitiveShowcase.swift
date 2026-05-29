import SwiftUI

struct PrivacySensitiveShowcase: View {
    enum PrivacyDisplayState: ShowcaseState {
        case visible
        case sensitiveObscured
        case nonSensitive

        var caption: String {
            switch self {
            case .visible: "Sensitive, visible"
            case .sensitiveObscured: "Sensitive, obscured"
            case .nonSensitive: "Not sensitive"
            }
        }

        var isSensitive: Bool {
            switch self {
            case .visible: true
            case .sensitiveObscured: true
            case .nonSensitive: false
            }
        }

        var isObscured: Bool {
            self == .sensitiveObscured
        }
    }

    @State private var sensitive = true
    @State private var demoForcePrivacy = false

    var body: some View {
        ShowcaseScreen(
            title: "Privacy Sensitive",
            summary: "Marks content private so the system redacts it during screen sharing, recording, or Always-On.",
        ) {
            PreviewStage {
                preview
            }
            ShowcaseSection("Configuration") {
                controls
            }
            ShowcaseSection("States") {
                StateGallery(content: stateView)
            }
            ShowcaseSection("Generated code") {
                CodeBlock(code: generatedCode)
            }
        }
    }
}

// MARK: - Sub-views
private extension PrivacySensitiveShowcase {
    var preview: some View {
        sensitiveCard(
            balance: 4_209.50,
            cardNumber: "•••• •••• •••• 4321",
            isSensitive: sensitive,
            forcePrivacy: demoForcePrivacy,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Sensitive", isOn: $sensitive)
        ShowcaseToggle("Simulate obscured (demo)", isOn: $demoForcePrivacy)
    }

    @ViewBuilder
    func stateView(_ state: PrivacyDisplayState) -> some View {
        sensitiveCard(
            balance: 4_209.50,
            cardNumber: "•••• •••• •••• 4321",
            isSensitive: state.isSensitive,
            forcePrivacy: state.isObscured,
        )
    }
}

// MARK: - Reusable card
private extension PrivacySensitiveShowcase {
    func sensitiveCard(
        balance: Double,
        cardNumber: String,
        isSensitive: Bool,
        forcePrivacy: Bool,
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Account Balance")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)

            Text(balance, format: .currency(code: "USD"))
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.primary)
                .privacySensitive(isSensitive)
                .redacted(reason: forcePrivacy ? .privacy : [])

            Divider()

            Text(cardNumber)
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.secondary)
                .privacySensitive(isSensitive)
                .redacted(reason: forcePrivacy ? .privacy : [])
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: 300, alignment: .leading)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }
}

// MARK: - Code generation
private extension PrivacySensitiveShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("Text(balance, format: .currency(code: \"USD\"))")
        lines.append("    .privacySensitive(\(sensitive))")
        if demoForcePrivacy {
            lines.append("    .redacted(reason: .privacy)")
        }
        lines.append("")
        lines.append("// @Environment(\\.isSceneCaptured) private var isCaptured")
        return lines.joined(separator: "\n")
    }
}
