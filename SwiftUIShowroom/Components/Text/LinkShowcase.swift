import SwiftUI

struct LinkShowcase: View {
    @State private var titleText = "View Our Terms of Service"
    @State private var urlString = "https://www.example.com"
    @State private var foregroundColor: Color = .accentColor
    @State private var font: FontOption = .body
    @State private var interceptsOpen = false

    var body: some View {
        ShowcaseScreen(
            title: "Link",
            summary: "Opens a URL in-app or in the default browser; overridable via OpenURLAction.",
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
private extension LinkShowcase {
    var preview: some View {
        linkView(title: titleText, disabled: false)
            .environment(\.openURL, openURLAction)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label", text: $titleText)
        ShowcaseTextControl("URL", text: $urlString, prompt: "https://")
        ShowcasePicker("Font", selection: $font)
        ShowcaseColorControl("Color", selection: $foregroundColor, supportsOpacity: false)
        ShowcaseToggle("Intercept open (handled)", isOn: $interceptsOpen)
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        linkView(title: titleText, disabled: state == .disabled)
            .environment(\.openURL, openURLAction)
    }

    func linkView(title: String, disabled: Bool) -> some View {
        Link(title, destination: destination)
            .font(font.value)
            .foregroundStyle(foregroundColor)
            .disabled(disabled)
    }
}

// MARK: - Helpers
private extension LinkShowcase {
    var destination: URL {
        URL(string: urlString) ?? URL(string: "https://www.example.com") ?? URL(fileURLWithPath: "/")
    }

    var openURLAction: OpenURLAction {
        interceptsOpen
            ? OpenURLAction { _ in .handled }
            : OpenURLAction { _ in .systemAction }
    }
}

// MARK: - Configuration options (nested)
extension LinkShowcase {
    enum FontOption: ShowcasePickable {
        case body, callout, footnote, headline

        var label: String {
            switch self {
            case .body: "body"
            case .callout: "callout"
            case .footnote: "footnote"
            case .headline: "headline"
            }
        }

        var value: Font {
            switch self {
            case .body: .body
            case .callout: .callout
            case .footnote: .footnote
            case .headline: .headline
            }
        }

        var code: String { ".\(label)" }
    }
}

// MARK: - Code generation
private extension LinkShowcase {
    var generatedCode: String {
        var lines: [String] = []
        let urlExpr = "URL(string: \"\(escapedURL)\") ?? URL(fileURLWithPath: \"/\")"
        lines.append("Link(\"\(escapedTitle)\", destination: \(urlExpr))")
        lines.append("    .font(\(font.code))")
        lines.append("    .foregroundStyle(/* your color */)")
        if interceptsOpen {
            lines.append("    .environment(\\.openURL, OpenURLAction { _ in .handled })")
        }
        return lines.joined(separator: "\n")
    }

    var escapedTitle: String {
        titleText.replacingOccurrences(of: "\"", with: "\\\"")
    }

    var escapedURL: String {
        urlString.replacingOccurrences(of: "\"", with: "\\\"")
    }
}
