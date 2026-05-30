import SwiftUI

struct AccessibilityTextContentTypeShowcase: View {
    @State private var contentType: ContentTypeOption = .plain

    var body: some View {
        ShowcaseScreen(
            title: "Accessibility Text Content Type",
            summary: "Tells VoiceOver the semantic kind of text so it adapts navigation and speech.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AccessibilityTextContentTypeShowcase {
    var preview: some View {
        contentBlock(type: contentType, sample: contentType.sampleText)
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Content type", selection: $contentType)
    }

    @ViewBuilder func stateView(_ state: ContentTypeState) -> some View {
        contentBlock(type: state.option, sample: state.sampleText)
    }

    func contentBlock(type: ContentTypeOption, sample: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: type.systemImage)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(type.label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            Text(sample)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityTextContentType(type.contentType)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension AccessibilityTextContentTypeShowcase {
    var generatedCode: String {
        """
        Text(verbatim: content)
            .accessibilityTextContentType(.\(contentType.codeName))
        """
    }
}

// MARK: - Nested types
extension AccessibilityTextContentTypeShowcase {
    fileprivate enum ContentTypeOption: ShowcasePickable {
        case plain
        case console
        case fileSystem
        case messaging
        case narrative
        case sourceCode
        case spreadsheet
        case wordProcessing

        var label: String {
            switch self {
            case .plain: "plain"
            case .console: "console"
            case .fileSystem: "fileSystem"
            case .messaging: "messaging"
            case .narrative: "narrative"
            case .sourceCode: "sourceCode"
            case .spreadsheet: "spreadsheet"
            case .wordProcessing: "wordProcessing"
            }
        }

        var codeName: String { label }

        var contentType: AccessibilityTextContentType {
            switch self {
            case .plain: .plain
            case .console: .console
            case .fileSystem: .fileSystem
            case .messaging: .messaging
            case .narrative: .narrative
            case .sourceCode: .sourceCode
            case .spreadsheet: .spreadsheet
            case .wordProcessing: .wordProcessing
            }
        }

        var systemImage: String {
            switch self {
            case .plain: "text.alignleft"
            case .console: "terminal"
            case .fileSystem: "folder"
            case .messaging: "bubble.left.and.bubble.right"
            case .narrative: "book"
            case .sourceCode: "chevron.left.forwardslash.chevron.right"
            case .spreadsheet: "tablecells"
            case .wordProcessing: "doc.text"
            }
        }

        var sampleText: String {
            switch self {
            case .plain:
                "A simple paragraph of plain text with no special navigation semantics."
            case .console:
                "$ swift run\nBuild complete! (0.42s)\nServer started on :8080"
            case .fileSystem:
                "/Users/giga/Documents/Projects/SwiftUIShowroom/README.md"
            case .messaging:
                "Alice: Hey, are we still on for the demo?\nBob: Yes! Starting in 10 minutes."
            case .narrative:
                "Once upon a time, in a land of declarative layouts, a View composed itself from the ground up."
            case .sourceCode:
                "func greet(_ name: String) -> String {\n    \"Hello, \\(name)!\"\n}"
            case .spreadsheet:
                "Revenue\tQ1\tQ2\tQ3\nApp Store\t$12k\t$18k\t$21k"
            case .wordProcessing:
                "Introduction\n\nThis document outlines the architecture decisions"
                    + " made during the initial planning phase."
            }
        }
    }

    fileprivate enum ContentTypeState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default (plain)"
            case .longContent: "Source code (long)"
            }
        }

        var option: ContentTypeOption {
            switch self {
            case .default: .plain
            case .longContent: .sourceCode
            }
        }

        var sampleText: String {
            switch self {
            case .default:
                "A simple paragraph of plain text with no special navigation semantics."
            case .longContent:
                "import SwiftUI\n\nstruct ContentView: View {\n"
                    + "    @State private var count = 0\n"
                    + "    var body: some View {\n"
                    + "        Button(\"Count: \\(count)\") { count += 1 }\n"
                    + "    }\n}"
            }
        }
    }
}
