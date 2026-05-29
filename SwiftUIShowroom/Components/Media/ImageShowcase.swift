import SwiftUI

struct ImageShowcase: View {
    @State private var source: ImageSource = .systemSymbol
    @State private var isResizable = true
    @State private var resizingMode: ResizingModeOption = .stretch
    @State private var contentMode: ContentModeOption = .fit
    @State private var renderingMode: RenderingModeOption = .original
    @State private var interpolation: InterpolationOption = .high
    @State private var isAntialiased = true
    @State private var tintColor: Color = .accentColor
    @State private var frameWidth: Double = 120
    @State private var frameHeight: Double = 120
    @State private var isClipped = true
    @State private var accessibilityLabel = "Photo"

    var body: some View {
        ShowcaseScreen(
            title: "Image",
            summary: "Displays a bitmap, asset, or symbol with resizing, scaling, and rendering controls.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ImageShowcase {
    enum ImageSource: ShowcasePickable {
        case systemSymbol, asset, decorative
        var label: String {
            switch self {
            case .systemSymbol: "System symbol"
            case .asset: "Asset"
            case .decorative: "Decorative"
            }
        }
    }

    enum ResizingModeOption: ShowcasePickable {
        case stretch, tile
        var label: String {
            switch self {
            case .stretch: "stretch"
            case .tile: "tile"
            }
        }
        var value: Image.ResizingMode {
            switch self {
            case .stretch: .stretch
            case .tile: .tile
            }
        }
    }

    enum ContentModeOption: ShowcasePickable {
        case fit, fill
        var label: String {
            switch self {
            case .fit: "fit"
            case .fill: "fill"
            }
        }
        var value: ContentMode {
            switch self {
            case .fit: .fit
            case .fill: .fill
            }
        }
    }

    enum RenderingModeOption: ShowcasePickable {
        case original, template
        var label: String {
            switch self {
            case .original: "original"
            case .template: "template"
            }
        }
        var value: Image.TemplateRenderingMode {
            switch self {
            case .original: .original
            case .template: .template
            }
        }
    }

    enum InterpolationOption: ShowcasePickable {
        case none, low, medium, high
        var label: String {
            switch self {
            case .none: "none"
            case .low: "low"
            case .medium: "medium"
            case .high: "high"
            }
        }
        var value: Image.Interpolation {
            switch self {
            case .none: .none
            case .low: .low
            case .medium: .medium
            case .high: .high
            }
        }
    }

    enum ImageGalleryState: ShowcaseState {
        case symbolOriginal
        case symbolTemplate
        case scaledToFit
        case scaledToFill
        case decorative
        case tiled
        var caption: String {
            switch self {
            case .symbolOriginal: "Original"
            case .symbolTemplate: "Template tint"
            case .scaledToFit: "Scaled to fit"
            case .scaledToFill: "Scaled to fill"
            case .decorative: "Decorative"
            case .tiled: "Tile mode"
            }
        }
    }

    struct ImageConfig {
        var source: ImageSource
        var isResizable: Bool
        var resizingMode: ResizingModeOption
        var contentMode: ContentModeOption
        var renderingMode: RenderingModeOption
        var interpolation: InterpolationOption
        var isAntialiased: Bool
        var tintColor: Color
        var frameSize: CGSize
        var isClipped: Bool
        var accessibilityLabel: String
    }
}

// MARK: - Sub-views
private extension ImageShowcase {
    var preview: some View {
        ConfiguredImageView(config: currentConfig)
    }

    var currentConfig: ImageConfig {
        ImageConfig(
            source: source,
            isResizable: isResizable,
            resizingMode: resizingMode,
            contentMode: contentMode,
            renderingMode: renderingMode,
            interpolation: interpolation,
            isAntialiased: isAntialiased,
            tintColor: tintColor,
            frameSize: CGSize(width: frameWidth, height: frameHeight),
            isClipped: isClipped,
            accessibilityLabel: accessibilityLabel,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Source", selection: $source)
        ShowcaseToggle("Resizable", isOn: $isResizable)
        ShowcasePicker("Resizing mode", selection: $resizingMode)
        ShowcasePicker("Content mode", selection: $contentMode)
        ShowcasePicker("Rendering mode", selection: $renderingMode)
        ShowcasePicker("Interpolation", selection: $interpolation)
        ShowcaseToggle("Antialiased", isOn: $isAntialiased)
        ShowcaseColorControl("Tint", selection: $tintColor, supportsOpacity: false)
        ShowcaseSlider("Frame width", value: $frameWidth, in: 20...400, step: 1)
        ShowcaseSlider("Frame height", value: $frameHeight, in: 20...400, step: 1)
        ShowcaseToggle("Clipped", isOn: $isClipped)
        ShowcaseTextControl("Accessibility label", text: $accessibilityLabel)
    }

    @ViewBuilder
    func stateView(_ state: ImageGalleryState) -> some View {
        ConfiguredImageView(config: config(for: state))
    }

    func config(for state: ImageGalleryState) -> ImageConfig {
        switch state {
        case .symbolOriginal:
            return symbolConfig(renderingMode: .original, tint: .accentColor, label: "Mountain")
        case .symbolTemplate:
            return symbolConfig(renderingMode: .template, tint: .orange, label: "Mountain")
        case .scaledToFit:
            return resizeConfig(contentMode: .fit)
        case .scaledToFill:
            return resizeConfig(contentMode: .fill)
        case .decorative:
            return decorativeConfig()
        case .tiled:
            return tiledConfig()
        }
    }

    func symbolConfig(
        renderingMode: RenderingModeOption,
        tint: Color,
        label: String
    ) -> ImageConfig {
        ImageConfig(
            source: .systemSymbol,
            isResizable: true,
            resizingMode: .stretch,
            contentMode: .fit,
            renderingMode: renderingMode,
            interpolation: .high,
            isAntialiased: true,
            tintColor: tint,
            frameSize: CGSize(width: 100, height: 100),
            isClipped: false,
            accessibilityLabel: label,
        )
    }

    func resizeConfig(contentMode: ContentModeOption) -> ImageConfig {
        ImageConfig(
            source: .systemSymbol,
            isResizable: true,
            resizingMode: .stretch,
            contentMode: contentMode,
            renderingMode: .original,
            interpolation: .high,
            isAntialiased: true,
            tintColor: .accentColor,
            frameSize: CGSize(width: 80, height: 120),
            isClipped: true,
            accessibilityLabel: "Photo",
        )
    }

    func decorativeConfig() -> ImageConfig {
        ImageConfig(
            source: .decorative,
            isResizable: true,
            resizingMode: .stretch,
            contentMode: .fit,
            renderingMode: .original,
            interpolation: .high,
            isAntialiased: true,
            tintColor: .accentColor,
            frameSize: CGSize(width: 100, height: 100),
            isClipped: false,
            accessibilityLabel: "",
        )
    }

    func tiledConfig() -> ImageConfig {
        ImageConfig(
            source: .systemSymbol,
            isResizable: true,
            resizingMode: .tile,
            contentMode: .fit,
            renderingMode: .template,
            interpolation: .high,
            isAntialiased: true,
            tintColor: .purple,
            frameSize: CGSize(width: 120, height: 80),
            isClipped: true,
            accessibilityLabel: "Tiled pattern",
        )
    }
}

// MARK: - Code generation
private extension ImageShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append(imageInitLine)
        if isResizable {
            lines.append("    .resizable(resizingMode: .\(resizingMode.label))")
            lines.append("    .aspectRatio(contentMode: .\(contentMode.label))")
        }
        lines.append("    .renderingMode(.\(renderingMode.label))")
        lines.append("    .interpolation(.\(interpolation.label))")
        lines.append("    .antialiased(\(isAntialiased))")
        if renderingMode == .template {
            lines.append("    .foregroundStyle(\(tintColorCode))")
        }
        lines.append("    .frame(width: \(Int(frameWidth)), height: \(Int(frameHeight)))")
        if isClipped {
            lines.append("    .clipped()")
        }
        if source != .decorative {
            lines.append("    .accessibilityLabel(\"\(accessibilityLabel)\")")
        }
        return lines.joined(separator: "\n")
    }

    var imageInitLine: String {
        switch source {
        case .systemSymbol:
            return "Image(systemName: \"mountain.2.fill\")"
        case .asset:
            return "Image(\"YourAssetName\")"
        case .decorative:
            return "Image(decorative: \"YourAssetName\")"
        }
    }

    var tintColorCode: String {
        tintColor == .accentColor ? ".accentColor" : "Color(/* configured */)"
    }
}

// MARK: - ConfiguredImageView
private struct ConfiguredImageView: View {
    let config: ImageShowcase.ImageConfig
    var body: some View {
        styledImage
            .frame(width: config.frameSize.width, height: config.frameSize.height)
            .modifier(ConditionalClip(isClipped: config.isClipped))
    }

    @ViewBuilder
    private var styledImage: some View {
        let image = resolvedImage
            .renderingMode(config.renderingMode.value)
            .interpolation(config.interpolation.value)
            .antialiased(config.isAntialiased)
        if config.isResizable {
            image
                .resizable(resizingMode: config.resizingMode.value)
                .aspectRatio(contentMode: config.contentMode.value)
                .foregroundStyle(config.tintColor)
        } else {
            image
                .foregroundStyle(config.tintColor)
        }
    }

    private var resolvedImage: Image {
        switch config.source {
        case .systemSymbol:
            return Image(systemName: "mountain.2.fill")
        case .asset:
            return Image(systemName: "photo.fill")
        case .decorative:
            return Image(systemName: "mountain.2.fill")
        }
    }
}

// MARK: - ConditionalClip
private struct ConditionalClip: ViewModifier {
    let isClipped: Bool
    func body(content: Content) -> some View {
        if isClipped {
            content.clipped()
        } else {
            content
        }
    }
}
