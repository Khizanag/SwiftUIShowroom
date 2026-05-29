import SwiftUI

struct TextShowcase: View {
    @State private var content = "To be, or not to be, that is the question."
    @State private var font: FontOption = .body
    @State private var fontWeight: FontWeightOption = .regular
    @State private var fontDesign: FontDesignOption = .default
    @State private var fontWidth: FontWidthOption = .standard
    @State private var foregroundStyle: Color = DesignSystem.Color.primary
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderline = false
    @State private var isStrikethrough = false
    @State private var lineLimit = 0
    @State private var truncationMode: TruncationModeOption = .tail
    @State private var multilineAlignment: MultilineAlignmentOption = .leading
    @State private var lineSpacing: Double = 0
    @State private var kerning: Double = 0
    @State private var minimumScaleFactor: Double = 1.0
    @State private var allowsTightening = false
    @State private var isMarkdown = false
    #if !os(tvOS)
    @State private var textSelection = false
    #endif
    @State private var textCase: TextCaseOption = .none

    var body: some View {
        ShowcaseScreen(
            title: "Text",
            summary: "Read-only text with full control over font, weight, design, color, spacing, and truncation.",
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
private extension TextShowcase {
    var preview: some View {
        configured(textView(for: displayContent))
            .frame(maxWidth: 320)
            .multilineTextAlignment(multilineAlignment.value)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("Content", text: $content)
        ShowcasePicker("Font", selection: $font)
        ShowcasePicker("Weight", selection: $fontWeight)
        ShowcasePicker("Design", selection: $fontDesign)
        ShowcasePicker("Width", selection: $fontWidth)
        ShowcaseColorControl("Color", selection: $foregroundStyle)
        ShowcaseToggle("Bold", isOn: $isBold)
        ShowcaseToggle("Italic", isOn: $isItalic)
        ShowcaseToggle("Underline", isOn: $isUnderline)
        ShowcaseToggle("Strikethrough", isOn: $isStrikethrough)
        ShowcaseStepper("Line limit (0 = unlimited)", value: $lineLimit, in: 0...20)
        ShowcasePicker("Truncation mode", selection: $truncationMode)
        ShowcasePicker("Multiline alignment", selection: $multilineAlignment)
        ShowcaseSlider("Line spacing", value: $lineSpacing, in: 0...20, step: 0.5)
        ShowcaseSlider("Kerning", value: $kerning, in: -5...20, step: 0.5)
        ShowcaseSlider("Minimum scale factor", value: $minimumScaleFactor, in: 0.3...1.0, step: 0.05)
        ShowcaseToggle("Allows tightening", isOn: $allowsTightening)
        ShowcaseToggle("Markdown content", isOn: $isMarkdown)
        #if !os(tvOS)
        ShowcaseToggle("Text selection", isOn: $textSelection)
        #endif
        ShowcasePicker("Text case", selection: $textCase)
    }

    @ViewBuilder
    func stateView(_ state: TextContentState) -> some View {
        configured(textView(for: state.content))
            .multilineTextAlignment(.leading)
    }

    func textView(for string: String) -> Text {
        if isMarkdown, let attributed = try? AttributedString(markdown: string) {
            return Text(attributed)
        }
        return Text(verbatim: string)
    }

    @ViewBuilder
    func configured(_ text: Text) -> some View {
        let styled = text
            .font(font.value)
            .fontWeight(fontWeight.value)
            .fontDesign(fontDesign.value)
            .fontWidth(fontWidth.value)
            .foregroundStyle(foregroundStyle)
            .bold(isBold)
            .italic(isItalic)
            .underline(isUnderline)
            .strikethrough(isStrikethrough)
            .lineLimit(lineLimit == 0 ? nil : lineLimit)
            .truncationMode(truncationMode.value)
            .lineSpacing(lineSpacing)
            .kerning(kerning)
            .minimumScaleFactor(minimumScaleFactor)
            .allowsTightening(allowsTightening)
            .textCase(textCase.value)
        #if os(tvOS)
        styled
        #else
        if textSelection {
            styled.textSelection(.enabled)
        } else {
            styled.textSelection(.disabled)
        }
        #endif
    }

    var displayContent: String {
        isMarkdown ? "**To be**, or *not to be*, that is the question." : content
    }
}

// MARK: - Configuration enums (nested)
extension TextShowcase {
    enum FontOption: ShowcasePickable {
        case largeTitle, title, title2, title3, headline, subheadline,
             body, callout, footnote, caption, caption2

        var label: String {
            switch self {
            case .largeTitle: "largeTitle"
            case .title: "title"
            case .title2: "title2"
            case .title3: "title3"
            case .headline: "headline"
            case .subheadline: "subheadline"
            case .body: "body"
            case .callout: "callout"
            case .footnote: "footnote"
            case .caption: "caption"
            case .caption2: "caption2"
            }
        }

        var value: Font {
            switch self {
            case .largeTitle: .largeTitle
            case .title: .title
            case .title2: .title2
            case .title3: .title3
            case .headline: .headline
            case .subheadline: .subheadline
            case .body: .body
            case .callout: .callout
            case .footnote: .footnote
            case .caption: .caption
            case .caption2: .caption2
            }
        }
    }

    enum FontWeightOption: ShowcasePickable {
        case ultraLight, thin, light, regular, medium, semibold, bold, heavy, black

        var label: String {
            switch self {
            case .ultraLight: "ultraLight"
            case .thin: "thin"
            case .light: "light"
            case .regular: "regular"
            case .medium: "medium"
            case .semibold: "semibold"
            case .bold: "bold"
            case .heavy: "heavy"
            case .black: "black"
            }
        }

        var value: Font.Weight {
            switch self {
            case .ultraLight: .ultraLight
            case .thin: .thin
            case .light: .light
            case .regular: .regular
            case .medium: .medium
            case .semibold: .semibold
            case .bold: .bold
            case .heavy: .heavy
            case .black: .black
            }
        }
    }

    enum FontDesignOption: ShowcasePickable {
        case `default`, serif, rounded, monospaced

        var label: String {
            switch self {
            case .default: "default"
            case .serif: "serif"
            case .rounded: "rounded"
            case .monospaced: "monospaced"
            }
        }

        var value: Font.Design {
            switch self {
            case .default: .default
            case .serif: .serif
            case .rounded: .rounded
            case .monospaced: .monospaced
            }
        }
    }

    enum FontWidthOption: ShowcasePickable {
        case compressed, condensed, standard, expanded

        var label: String {
            switch self {
            case .compressed: "compressed"
            case .condensed: "condensed"
            case .standard: "standard"
            case .expanded: "expanded"
            }
        }

        var value: Font.Width {
            switch self {
            case .compressed: .compressed
            case .condensed: .condensed
            case .standard: .standard
            case .expanded: .expanded
            }
        }
    }

    enum TruncationModeOption: ShowcasePickable {
        case head, middle, tail

        var label: String {
            switch self {
            case .head: "head"
            case .middle: "middle"
            case .tail: "tail"
            }
        }

        var value: Text.TruncationMode {
            switch self {
            case .head: .head
            case .middle: .middle
            case .tail: .tail
            }
        }
    }

    enum MultilineAlignmentOption: ShowcasePickable {
        case leading, center, trailing

        var label: String {
            switch self {
            case .leading: "leading"
            case .center: "center"
            case .trailing: "trailing"
            }
        }

        var value: TextAlignment {
            switch self {
            case .leading: .leading
            case .center: .center
            case .trailing: .trailing
            }
        }
    }

    enum TextCaseOption: ShowcasePickable {
        case none, uppercase, lowercase

        var label: String {
            switch self {
            case .none: "none"
            case .uppercase: "uppercase"
            case .lowercase: "lowercase"
            }
        }

        var value: Text.Case? {
            switch self {
            case .none: nil
            case .uppercase: .uppercase
            case .lowercase: .lowercase
            }
        }
    }

    enum TextContentState: ShowcaseState {
        case short, longContent, markdown, caps

        var caption: String {
            switch self {
            case .short: "Default"
            case .longContent: "Long content"
            case .markdown: "Markdown"
            case .caps: "Uppercase"
            }
        }

        var content: String {
            switch self {
            case .short: "To be, or not to be."
            case .longContent:
                "To be, or not to be, that is the question: whether 'tis nobler in the mind"
                + " to suffer the slings and arrows of outrageous fortune."
            case .markdown:
                "**Bold**, *italic*, and `code` via Markdown."
            case .caps:
                "text case uppercase example"
            }
        }
    }
}

// MARK: - Code generation
private extension TextShowcase {
    var generatedCode: String {
        var lines: [String] = []
        let textInit = isMarkdown
            ? "Text(try! AttributedString(markdown: \"\(escapedContent)\"))"
            : "Text(\"\(escapedContent)\")"
        lines.append(textInit)
        lines.append("    .font(.\(font.label))")
        if fontWeight != .regular && !isBold {
            lines.append("    .fontWeight(.\(fontWeight.label))")
        }
        if fontDesign != .default {
            lines.append("    .fontDesign(.\(fontDesign.label))")
        }
        if fontWidth != .standard {
            lines.append("    .fontWidth(.\(fontWidth.label))")
        }
        lines.append("    .foregroundStyle(DesignSystem.Color.primary)")
        if isBold { lines.append("    .bold()") }
        if isItalic { lines.append("    .italic()") }
        if isUnderline { lines.append("    .underline()") }
        if isStrikethrough { lines.append("    .strikethrough()") }
        if lineLimit > 0 { lines.append("    .lineLimit(\(lineLimit))") }
        if truncationMode != .tail { lines.append("    .truncationMode(.\(truncationMode.label))") }
        if multilineAlignment != .leading {
            lines.append("    .multilineTextAlignment(.\(multilineAlignment.label))")
        }
        if lineSpacing > 0 { lines.append("    .lineSpacing(\(formatted(lineSpacing)))") }
        if kerning != 0 { lines.append("    .kerning(\(formatted(kerning)))") }
        if minimumScaleFactor < 1.0 {
            lines.append("    .minimumScaleFactor(\(formatted(minimumScaleFactor)))")
        }
        if allowsTightening { lines.append("    .allowsTightening(true)") }
        if textCase != .none { lines.append("    .textCase(.\(textCase.label))") }
        #if !os(tvOS)
        if textSelection { lines.append("    .textSelection(.enabled)") }
        #endif
        return lines.joined(separator: "\n")
    }

    var escapedContent: String {
        content.replacingOccurrences(of: "\"", with: "\\\"")
    }

    func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.2f", value)
    }
}
