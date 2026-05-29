import SwiftUI

struct AttributedStringShowcase: View {
    @State private var markdownSource = "_Hamlet_ by **William Shakespeare**"
    @State private var baseFont: BaseFontOption = .body
    @State private var highlightIntent: IntentOption = .emphasized
    @State private var showLink = false
    #if !os(tvOS)
    @State private var foregroundColor: Color = .primary
    #endif

    var body: some View {
        ShowcaseScreen(
            title: "AttributedString",
            summary: "A Unicode string with typed, run-based attributes — rendered by Text for mixed styling.",
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
private extension AttributedStringShowcase {
    var preview: some View {
        #if os(tvOS)
        Text(builtAttributedString)
            .font(baseFont.value)
            .multilineTextAlignment(.center)
            .padding(DesignSystem.Spacing.medium)
        #else
        Text(builtAttributedString)
            .font(baseFont.value)
            .foregroundStyle(foregroundColor)
            .multilineTextAlignment(.center)
            .padding(DesignSystem.Spacing.medium)
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Markdown", text: $markdownSource, prompt: "_italic_ **bold** `code`")
        ShowcasePicker("Base font", selection: $baseFont)
        #if !os(tvOS)
        ShowcaseColorControl("Foreground color", selection: $foregroundColor, supportsOpacity: false)
        #endif
        ShowcasePicker("First-run intent", selection: $highlightIntent)
        ShowcaseToggle("Append link run", isOn: $showLink)
    }

    @ViewBuilder
    func stateView(_ state: AttributedStringState) -> some View {
        Text(state.attributedString)
            .font(DesignSystem.Font.body)
            .multilineTextAlignment(.center)
    }
}

// MARK: - AttributedString building
private extension AttributedStringShowcase {
    var builtAttributedString: AttributedString {
        var base = (try? AttributedString(markdown: markdownSource)) ?? AttributedString(markdownSource)
        applyFirstRunIntent(highlightIntent, to: &base)
        if showLink, let url = URL(string: "https://developer.apple.com") {
            var linkRun = AttributedString(" (docs)")
            linkRun[linkRun.startIndex..<linkRun.endIndex].link = url
            base.append(linkRun)
        }
        return base
    }

    func applyFirstRunIntent(_ intent: IntentOption, to string: inout AttributedString) {
        guard string.startIndex < string.endIndex else { return }
        let firstCharEnd = string.index(afterCharacter: string.startIndex)
        let firstRange = string.startIndex..<firstCharEnd
        switch intent {
        case .emphasized:
            string[firstRange].inlinePresentationIntent = .emphasized
        case .stronglyEmphasized:
            string[firstRange].inlinePresentationIntent = .stronglyEmphasized
        case .code:
            string[firstRange].inlinePresentationIntent = .code
        case .strikethrough:
            string[firstRange].inlinePresentationIntent = .strikethrough
        }
    }
}

// MARK: - Nested types
extension AttributedStringShowcase {
    enum BaseFontOption: ShowcasePickable {
        case body, callout, title3, headline, caption

        var label: String {
            switch self {
            case .body: "body"
            case .callout: "callout"
            case .title3: "title3"
            case .headline: "headline"
            case .caption: "caption"
            }
        }

        var value: Font {
            switch self {
            case .body: .body
            case .callout: .callout
            case .title3: .title3
            case .headline: .headline
            case .caption: .caption
            }
        }

        var codeName: String { label }
    }

    enum IntentOption: ShowcasePickable {
        case emphasized, stronglyEmphasized, code, strikethrough

        var label: String {
            switch self {
            case .emphasized: "emphasized (italic)"
            case .stronglyEmphasized: "stronglyEmphasized (bold)"
            case .code: "code (monospaced)"
            case .strikethrough: "strikethrough"
            }
        }

        var codeName: String {
            switch self {
            case .emphasized: ".emphasized"
            case .stronglyEmphasized: ".stronglyEmphasized"
            case .code: ".code"
            case .strikethrough: ".strikethrough"
            }
        }
    }

    enum AttributedStringState: ShowcaseState {
        case markdown
        case boldAndItalic
        case codeRun
        case linkRun
        case strikethroughRun

        var caption: String {
            switch self {
            case .markdown: "Parsed Markdown"
            case .boldAndItalic: "Bold + Italic"
            case .codeRun: "Code run"
            case .linkRun: "Link run"
            case .strikethroughRun: "Strikethrough"
            }
        }

        var attributedString: AttributedString {
            switch self {
            case .markdown:
                return (try? AttributedString(markdown: "_Hello_ **World** — `swift`"))
                    ?? AttributedString("Hello World")
            case .boldAndItalic:
                var bold = AttributedString("Bold")
                bold[bold.startIndex..<bold.endIndex].inlinePresentationIntent = .stronglyEmphasized
                let spacer = AttributedString(" + ")
                var italic = AttributedString("Italic")
                italic[italic.startIndex..<italic.endIndex].inlinePresentationIntent = .emphasized
                bold.append(spacer)
                bold.append(italic)
                return bold
            case .codeRun:
                var result = AttributedString("Call ")
                var code = AttributedString("init(markdown:)")
                code[code.startIndex..<code.endIndex].inlinePresentationIntent = .code
                result.append(code)
                return result
            case .linkRun:
                var result = AttributedString("Open ")
                var link = AttributedString("Apple Docs")
                link[link.startIndex..<link.endIndex].link = URL(string: "https://developer.apple.com")
                result.append(link)
                return result
            case .strikethroughRun:
                var result = AttributedString("Deprecated API")
                result[result.startIndex..<result.endIndex].inlinePresentationIntent = .strikethrough
                return result
            }
        }
    }
}

// MARK: - Code generation
private extension AttributedStringShowcase {
    var escapedMarkdown: String {
        markdownSource.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    var generatedCode: String {
        var lines: [String] = []
        lines.append("var attributed = (try? AttributedString(markdown: \"\(escapedMarkdown)\"))")
        lines.append("    ?? AttributedString(\"\(escapedMarkdown)\")")
        lines.append("")
        lines.append("let firstRange = attributed.startIndex")
        lines.append("    ..<attributed.index(afterCharacter: attributed.startIndex)")
        lines.append("attributed[firstRange].inlinePresentationIntent = \(highlightIntent.codeName)")
        if showLink {
            lines.append("")
            lines.append("if let url = URL(string: \"https://developer.apple.com\") {")
            lines.append("    var linkRun = AttributedString(\" (docs)\")")
            lines.append("    linkRun[linkRun.startIndex..<linkRun.endIndex].link = url")
            lines.append("    attributed.append(linkRun)")
            lines.append("}")
        }
        lines.append("")
        lines.append("Text(attributed)")
        lines.append("    .font(.\(baseFont.codeName))")
        #if !os(tvOS)
        if foregroundColor != .primary {
            lines.append("    .foregroundStyle(Color(/* configured */))")
        }
        #endif
        return lines.joined(separator: "\n")
    }
}
