import SwiftUI

struct RedactionPlaceholderShowcase: View {

    // MARK: - Nested types
    enum RedactionReasonOption: ShowcasePickable {
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

        var codeArgument: String {
            switch self {
            case .placeholder: ".placeholder"
            case .privacy: ".privacy"
            case .invalidated: ".invalidated"
            case .none: "[]"
            }
        }
    }

    enum RedactionDisplayState: ShowcaseState {
        case loaded
        case loading
        case privacy

        var caption: String {
            switch self {
            case .loaded: "Loaded"
            case .loading: "Placeholder (skeleton)"
            case .privacy: "Privacy"
            }
        }

        var reasons: RedactionReasons {
            switch self {
            case .loaded: []
            case .loading: .placeholder
            case .privacy: .privacy
            }
        }
    }

    // MARK: - State
    @State private var reason: RedactionReasonOption = .placeholder
    @State private var isRedacted = true
    @State private var unredactInteractive = false

    // MARK: - Body
    var body: some View {
        ShowcaseScreen(
            title: "Redaction",
            summary: "Replaces text and images with neutral shapes to build skeleton loading states.",
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
private extension RedactionPlaceholderShowcase {
    var preview: some View {
        sampleCard(
            reasons: isRedacted ? reason.reasons : [],
            unredactInteractive: unredactInteractive,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Reason", selection: $reason)
        ShowcaseToggle("Apply redaction", isOn: $isRedacted)
        ShowcaseToggle("Unredact interactive element", isOn: $unredactInteractive)
    }

    @ViewBuilder
    func stateView(_ state: RedactionDisplayState) -> some View {
        sampleCard(
            reasons: state.reasons,
            unredactInteractive: false,
        )
    }

    func sampleCard(reasons: RedactionReasons, unredactInteractive: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(DesignSystem.Color.separator)
                .frame(height: 96)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text("Article Title Goes Here")
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text("A short description of the article content, spanning a couple of lines.")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .lineLimit(2)
            }

            HStack {
                Text("Read more")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .unredacted()
                    .opacity(unredactInteractive ? 1 : 0)
                Spacer()
                Text("3 min read")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.large),
        )
        .redacted(reason: reasons)
        .frame(maxWidth: 340)
    }
}

// MARK: - Code generation
private extension RedactionPlaceholderShowcase {
    var generatedCode: String {
        let reasonArg = isRedacted ? reason.codeArgument : "[]"
        var lines: [String] = [
            "CardView(item: placeholderItem)",
            "    .redacted(reason: \(reasonArg))",
        ]
        if unredactInteractive {
            lines += [
                "",
                "// Keep one element live:",
                "Button(\"Read more\") { }",
                "    .unredacted()",
            ]
        }
        lines += [
            "",
            "// Read the active reason inside a custom view:",
            "// @Environment(\\.redactionReasons) private var reasons",
        ]
        return lines.joined(separator: "\n")
    }
}
