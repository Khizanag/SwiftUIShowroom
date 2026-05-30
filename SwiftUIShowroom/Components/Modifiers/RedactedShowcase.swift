import SwiftUI

struct RedactedShowcase: View {
    enum RedactionOption: ShowcasePickable {
        case placeholder
        case privacy
        case invalidated
        case none

        var label: String {
            switch self {
            case .placeholder: ".placeholder"
            case .privacy: ".privacy"
            case .invalidated: ".invalidated"
            case .none: "[] (none)"
            }
        }

        var reasons: RedactionReasons {
            switch self {
            case .placeholder: .placeholder
            case .privacy: .privacy
            case .invalidated: .invalidated
            case .none: []
            }
        }

        var codeLabel: String {
            switch self {
            case .placeholder: ".placeholder"
            case .privacy: ".privacy"
            case .invalidated: ".invalidated"
            case .none: "[]"
            }
        }
    }

    enum RedactedState: ShowcaseState {
        case defaultLayout
        case longContent

        var caption: String {
            switch self {
            case .defaultLayout: "Placeholder"
            case .longContent: "Privacy (long)"
            }
        }
    }

    @State private var reason: RedactionOption = .placeholder

    var body: some View {
        ShowcaseScreen(
            title: "Redacted",
            summary: "Applies a placeholder or privacy redaction to a view hierarchy.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension RedactedShowcase {
    var preview: some View {
        accountCard(long: false, reasons: reason.reasons)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Reason", selection: $reason)
    }

    @ViewBuilder func stateView(_ state: RedactedState) -> some View {
        switch state {
        case .defaultLayout:
            accountCard(long: false, reasons: .placeholder)
        case .longContent:
            accountCard(long: true, reasons: .privacy)
        }
    }

    func accountCard(long: Bool, reasons: RedactionReasons) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text("Account balance")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("$1,234.56")
                .font(DesignSystem.Font.title)
                .foregroundStyle(DesignSystem.Color.primary)
            if long {
                longCardContent
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium),
        )
        .redacted(reason: reasons)
    }

    var longCardContent: some View {
        Group {
            Divider()
                .padding(.vertical, DesignSystem.Spacing.xSmall)
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                    Text("Card number")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.secondary)
                    Text("**** **** **** 4242")
                        .font(DesignSystem.Font.footnote)
                        .foregroundStyle(DesignSystem.Color.primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xSmall) {
                    Text("Expires")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.secondary)
                    Text("12/28")
                        .font(DesignSystem.Font.footnote)
                        .foregroundStyle(DesignSystem.Color.primary)
                }
            }
        }
    }
}

// MARK: - Code generation
private extension RedactedShowcase {
    var generatedCode: String {
        """
        VStack(alignment: .leading) {
            Text("Account balance")
            Text("$1,234.56").font(.title.bold())
        }
        .redacted(reason: \(reason.codeLabel))
        """
    }
}
