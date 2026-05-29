import SwiftUI

struct LabelShowcase: View {
    // MARK: - Nested types
    enum LabelStyleOption: ShowcasePickable {
        case automatic, titleAndIcon, titleOnly, iconOnly

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .titleAndIcon: "titleAndIcon"
            case .titleOnly: "titleOnly"
            case .iconOnly: "iconOnly"
            }
        }

        var codeValue: String { ".\(label)" }
    }

    enum SymbolRenderingModeOption: ShowcasePickable {
        case monochrome, hierarchical, palette, multicolor

        var label: String {
            switch self {
            case .monochrome: "monochrome"
            case .hierarchical: "hierarchical"
            case .palette: "palette"
            case .multicolor: "multicolor"
            }
        }

        var mode: SymbolRenderingMode {
            switch self {
            case .monochrome: .monochrome
            case .hierarchical: .hierarchical
            case .palette: .palette
            case .multicolor: .multicolor
            }
        }
    }

    enum LabelState: ShowcaseState {
        case `default`, disabled, selected

        var caption: String {
            switch self {
            case .default: "Default"
            case .disabled: "Disabled"
            case .selected: "Selected"
            }
        }
    }

    // MARK: - State
    @State private var titleText = "Lightning"
    @State private var systemImageName = "bolt.fill"
    @State private var labelStyle: LabelStyleOption = .automatic
    @State private var renderingMode: SymbolRenderingModeOption = .monochrome
    @State private var foregroundColor: Color = DesignSystem.Color.primary

    // MARK: - Body
    var body: some View {
        ShowcaseScreen(
            title: "Label",
            summary: "A standard title + icon pairing with switchable presentation via labelStyle.",
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
private extension LabelShowcase {
    var preview: some View {
        styledLabel(title: titleText, systemImage: systemImageName, isDisabled: false, isSelected: false)
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Title", text: $titleText)
        ShowcaseTextControl("SF Symbol", text: $systemImageName)
        ShowcasePicker("Style", selection: $labelStyle)
        ShowcasePicker("Symbol rendering", selection: $renderingMode)
        ShowcaseColorControl("Foreground", selection: $foregroundColor, supportsOpacity: false)
    }

    @ViewBuilder
    func stateView(_ state: LabelState) -> some View {
        styledLabel(
            title: titleText,
            systemImage: systemImageName,
            isDisabled: state == .disabled,
            isSelected: state == .selected,
        )
    }

    @ViewBuilder
    func styledLabel(
        title: String,
        systemImage: String,
        isDisabled: Bool,
        isSelected: Bool,
    ) -> some View {
        let fgStyle: Color = isSelected ? DesignSystem.Color.accent : foregroundColor
        let mode = renderingMode.mode
        let baseLabel = Label(title, systemImage: systemImage)
            .symbolRenderingMode(mode)
            .foregroundStyle(fgStyle)
            .disabled(isDisabled)
        switch labelStyle {
        case .automatic:
            baseLabel.labelStyle(.automatic)
        case .titleAndIcon:
            baseLabel.labelStyle(.titleAndIcon)
        case .titleOnly:
            baseLabel.labelStyle(.titleOnly)
        case .iconOnly:
            baseLabel.labelStyle(.iconOnly)
                .accessibilityLabel(title)
        }
    }
}

// MARK: - Code generation
private extension LabelShowcase {
    var generatedCode: String {
        [
            "Label(\"\(titleText)\", systemImage: \"\(systemImageName)\")",
            "    .labelStyle(\(labelStyle.codeValue))",
            "    .symbolRenderingMode(.\(renderingMode.label))",
            "    .foregroundStyle(.primary)",
        ].joined(separator: "\n")
    }
}
