import SwiftUI

struct SharelinkShowcase: View {
    @State private var titleText = "Share"
    @State private var urlString = "https://developer.apple.com"
    @State private var subjectText = ""
    @State private var messageText = ""
    @State private var showPreview = false
    @State private var labelStyle: LabelStyleOption = .automatic
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "ShareLink",
            summary: "Presents the system share sheet for any Transferable item, with optional preview.",
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

// MARK: - Configuration enums
extension SharelinkShowcase {
    enum LabelStyleOption: ShowcasePickable {
        case automatic, titleAndIcon, iconOnly, titleOnly

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .titleAndIcon: "titleAndIcon"
            case .iconOnly: "iconOnly"
            case .titleOnly: "titleOnly"
            }
        }

        var code: String { ".\(label)" }
    }

    enum ShareLinkState: ShowcaseState {
        case `default`
        case withPreview
        case customTitle
        case disabled

        var caption: String {
            switch self {
            case .default: "Default"
            case .withPreview: "With Preview"
            case .customTitle: "Custom Title"
            case .disabled: "Disabled"
            }
        }

        var title: String {
            switch self {
            case .default: "Share"
            case .withPreview: "Share Article"
            case .customTitle: "Send Link"
            case .disabled: "Share"
            }
        }

        var showPreview: Bool { self == .withPreview }
        var isEnabled: Bool { self != .disabled }
    }
}

// MARK: - Sub-views
private extension SharelinkShowcase {
    var preview: some View {
        #if os(tvOS)
        unavailableView
        #else
        shareLinkView(Config(
            title: titleText,
            url: resolvedURL,
            subjectText: subjectText,
            messageText: messageText,
            showPreview: showPreview,
            labelStyle: labelStyle,
            isEnabled: isEnabled
        ))
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Button title", text: $titleText)
        ShowcaseTextControl("URL", text: $urlString, prompt: "https://…")
        ShowcaseTextControl("Subject", text: $subjectText, prompt: "Optional")
        ShowcaseTextControl("Message", text: $messageText, prompt: "Optional")
        ShowcaseToggle("Show preview", isOn: $showPreview)
        ShowcasePicker("Label style", selection: $labelStyle)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: ShareLinkState) -> some View {
        #if os(tvOS)
        unavailableView
        #else
        shareLinkView(Config(
            title: state.title,
            url: fallbackURL,
            subjectText: "",
            messageText: "",
            showPreview: state.showPreview,
            labelStyle: .automatic,
            isEnabled: state.isEnabled
        ))
        #endif
    }

    var unavailableView: some View {
        Text("ShareLink is not available on tvOS")
            .font(DesignSystem.Font.callout)
            .foregroundStyle(DesignSystem.Color.secondary)
    }
}

// MARK: - ShareLink builder
#if !os(tvOS)
private extension SharelinkShowcase {
    struct Config {
        var title: String
        var url: URL
        var subjectText: String
        var messageText: String
        var showPreview: Bool
        var labelStyle: LabelStyleOption
        var isEnabled: Bool
    }

    var resolvedURL: URL {
        URL(string: urlString.isEmpty ? "https://developer.apple.com" : urlString) ?? fallbackURL
    }

    var fallbackURL: URL {
        URL(string: "https://developer.apple.com") ?? URL(fileURLWithPath: "/")
    }

    @ViewBuilder
    func shareLinkView(_ config: Config) -> some View {
        let subject: Text? = config.subjectText.isEmpty ? nil : Text(config.subjectText)
        let message: Text? = config.messageText.isEmpty ? nil : Text(config.messageText)

        Group {
            if config.showPreview {
                applyLabelStyle(
                    ShareLink(
                        config.title,
                        item: config.url,
                        subject: subject,
                        message: message,
                        preview: SharePreview(config.title, image: Image(systemName: "globe"))
                    ),
                    style: config.labelStyle
                )
            } else {
                applyLabelStyle(
                    ShareLink(config.title, item: config.url, subject: subject, message: message),
                    style: config.labelStyle
                )
            }
        }
        .disabled(!config.isEnabled)
        .buttonStyle(.bordered)
    }

    @ViewBuilder
    func applyLabelStyle(_ link: some View, style: LabelStyleOption) -> some View {
        switch style {
        case .automatic: link.labelStyle(.automatic)
        case .titleAndIcon: link.labelStyle(.titleAndIcon)
        case .iconOnly: link.labelStyle(.iconOnly)
        case .titleOnly: link.labelStyle(.titleOnly)
        }
    }
}
#endif

// MARK: - Code generation
private extension SharelinkShowcase {
    var generatedCode: String {
        let resolvedURL = urlString.isEmpty ? "https://developer.apple.com" : urlString
        var lines: [String] = []

        if showPreview {
            lines.append("ShareLink(")
            lines.append("    \"\(titleText)\",")
            lines.append("    item: URL(string: \"\(resolvedURL)\")!,")
            if !subjectText.isEmpty {
                lines.append("    subject: Text(\"\(subjectText)\"),")
            }
            if !messageText.isEmpty {
                lines.append("    message: Text(\"\(messageText)\"),")
            }
            lines.append("    preview: SharePreview(")
            lines.append("        \"\(titleText)\",")
            lines.append("        image: Image(systemName: \"globe\")")
            lines.append("    )")
            lines.append(")")
        } else {
            let hasExtras = !subjectText.isEmpty || !messageText.isEmpty
            if hasExtras {
                lines.append("ShareLink(")
                lines.append("    \"\(titleText)\",")
                lines.append("    item: URL(string: \"\(resolvedURL)\")!,")
                if !subjectText.isEmpty {
                    lines.append("    subject: Text(\"\(subjectText)\"),")
                }
                if !messageText.isEmpty {
                    lines.append("    message: Text(\"\(messageText)\")")
                }
                lines.append(")")
            } else {
                lines.append("ShareLink(\"\(titleText)\", item: URL(string: \"\(resolvedURL)\")!)")
            }
        }

        if labelStyle != .automatic {
            lines.append(".labelStyle(\(labelStyle.code))")
        }
        if !isEnabled {
            lines.append(".disabled(true)")
        }

        return lines.joined(separator: "\n")
    }
}
