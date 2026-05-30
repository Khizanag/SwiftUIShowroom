import SwiftUI

struct PasteButtonShowcase: View {
    enum PayloadTypeOption: ShowcasePickable {
        case string, url
        var label: String {
            switch self {
            case .string: "String.self"
            case .url: "URL.self"
            }
        }
        var code: String {
            switch self {
            case .string: "String.self"
            case .url: "URL.self"
            }
        }
    }

    enum BorderShapeOption: ShowcasePickable {
        case automatic, capsule, roundedRectangle, circle
        var label: String {
            switch self {
            case .automatic: "automatic"
            case .capsule: "capsule"
            case .roundedRectangle: "roundedRectangle"
            case .circle: "circle"
            }
        }
        var code: String { ".\(label)" }
    }

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

    enum PasteState: ShowcaseState {
        case `default`, disabled, empty
        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .empty: "Empty pasteboard"
            }
        }
    }

    @State private var payloadType: PayloadTypeOption = .string
    @State private var tint: Color = .accentColor
    @State private var borderShape: BorderShapeOption = .automatic
    @State private var labelStyle: LabelStyleOption = .automatic
    @State private var isEnabled = true
    @State private var pastedText: String?

    var body: some View {
        ShowcaseScreen(
            title: "PasteButton",
            summary: "A system button that reads Transferable items from the pasteboard into a closure.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PasteButtonShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            pasteButton(isEnabled: isEnabled)
            if let text = pastedText {
                Text("Pasted: \(text)")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Payload type", selection: $payloadType)
        ShowcasePicker("Border shape", selection: $borderShape)
        ShowcasePicker("Label style", selection: $labelStyle)
        ShowcaseColorControl("Tint", selection: $tint, supportsOpacity: false)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: PasteState) -> some View {
        switch state {
        case .default:
            pasteButton(isEnabled: true)
        case .disabled:
            pasteButton(isEnabled: false)
        case .empty:
            pasteButton(isEnabled: true)
                .opacity(0.5)
        }
    }

    @ViewBuilder
    func pasteButton(isEnabled enabled: Bool) -> some View {
        #if os(tvOS)
        Text("PasteButton not available on tvOS")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.secondary)
        #else
        configuredPasteButton(isEnabled: enabled)
        #endif
    }

    #if !os(tvOS)
    @ViewBuilder
    func configuredPasteButton(isEnabled enabled: Bool) -> some View {
        let shaped = styledPasteButton
            .tint(tint)
            .disabled(!enabled)
        switch labelStyle {
        case .automatic:
            shaped.labelStyle(.automatic)
        case .titleAndIcon:
            shaped.labelStyle(.titleAndIcon)
        case .iconOnly:
            shaped.labelStyle(.iconOnly)
        case .titleOnly:
            shaped.labelStyle(.titleOnly)
        }
    }

    var styledPasteButton: some View {
        let base = makePasteButton()
        switch borderShape {
        case .automatic:
            return AnyView(base.buttonBorderShape(.automatic))
        case .capsule:
            return AnyView(base.buttonBorderShape(.capsule))
        case .roundedRectangle:
            return AnyView(base.buttonBorderShape(.roundedRectangle))
        case .circle:
            return AnyView(base.buttonBorderShape(.circle))
        }
    }

    @ViewBuilder
    func makePasteButton() -> some View {
        switch payloadType {
        case .string:
            PasteButton(payloadType: String.self) { items in
                pastedText = items.first
            }
        case .url:
            PasteButton(payloadType: URL.self) { items in
                pastedText = items.first?.absoluteString
            }
        }
    }
    #endif
}

// MARK: - Code generation
private extension PasteButtonShowcase {
    var generatedCode: String {
        var lines = [
            "PasteButton(payloadType: \(payloadType.code)) { items in",
            "    // handle items",
            "}",
        ]
        if borderShape != .automatic {
            lines.append(".buttonBorderShape(\(borderShape.code))")
        }
        if labelStyle != .automatic {
            lines.append(".labelStyle(\(labelStyle.code))")
        }
        lines.append(".tint(\(tintCode))")
        if !isEnabled {
            lines.append(".disabled(true)")
        }
        return lines.joined(separator: "\n")
    }

    var tintCode: String {
        tint == .accentColor ? ".accentColor" : "Color(/* custom */)"
    }
}
