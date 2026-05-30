import SwiftUI

struct ScaledToFitFillShowcase: View {
    @State private var mode: ContentModeOption = .fill
    @State private var frameWidth: Double = 120
    @State private var frameHeight: Double = 120

    var body: some View {
        ShowcaseScreen(
            title: "Scaled To Fit / Fill",
            summary: "Scales a resizable view to fit inside or fill its frame, preserving aspect ratio.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ScaledToFitFillShowcase {
    var preview: some View {
        imageSwatch(
            mode: mode,
            width: frameWidth,
            height: frameHeight,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Content Mode", selection: $mode)
        ShowcaseSlider("Frame Width", value: $frameWidth, in: 60...240, step: 1)
        ShowcaseSlider("Frame Height", value: $frameHeight, in: 60...240, step: 1)
    }

    @ViewBuilder func stateView(_ state: ScaledState) -> some View {
        imageSwatch(
            mode: state.mode,
            width: state.width,
            height: state.height,
        )
    }

    func imageSwatch(mode contentMode: ContentModeOption, width: Double, height: Double) -> some View {
        ZStack {
            LinearGradient(
                colors: [DesignSystem.Color.accent, DesignSystem.Color.accent.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            Image(systemName: "photo.fill")
                .resizable()
                .foregroundStyle(.white.opacity(0.6))
        }
        .modifier(ScaledContentModifier(option: contentMode))
        .frame(width: width, height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension ScaledToFitFillShowcase {
    var generatedCode: String {
        let modifierName = mode == .fit ? "scaledToFit()" : "scaledToFill()"
        let widthStr = frameWidth == frameWidth.rounded() ? "\(Int(frameWidth))" : String(format: "%.1f", frameWidth)
        let heightStr = frameHeight == frameHeight.rounded()
            ? "\(Int(frameHeight))"
            : String(format: "%.1f", frameHeight)
        return """
        Image("photo")
            .resizable()
            .\(modifierName)
            .frame(width: \(widthStr), height: \(heightStr))
            .clipped()
        """
    }
}

// MARK: - Content mode modifier
private struct ScaledContentModifier: ViewModifier {
    let option: ScaledToFitFillShowcase.ContentModeOption

    func body(content: Content) -> some View {
        switch option {
        case .fit:
            content.scaledToFit()
        case .fill:
            content.scaledToFill()
        }
    }
}

// MARK: - Nested types
extension ScaledToFitFillShowcase {
    enum ContentModeOption: ShowcasePickable {
        case fit
        case fill

        var label: String {
            switch self {
            case .fit: "scaledToFit"
            case .fill: "scaledToFill"
            }
        }
    }

    enum ScaledState: ShowcaseState {
        case fitSquare
        case fillSquare
        case fitWide
        case fillWide

        var caption: String {
            switch self {
            case .fitSquare: "Fit 120×120"
            case .fillSquare: "Fill 120×120"
            case .fitWide: "Fit 160×90"
            case .fillWide: "Fill 90×160"
            }
        }

        var mode: ContentModeOption {
            switch self {
            case .fitSquare, .fitWide: .fit
            case .fillSquare, .fillWide: .fill
            }
        }

        var width: Double {
            switch self {
            case .fitSquare, .fillSquare: 120
            case .fitWide: 160
            case .fillWide: 90
            }
        }

        var height: Double {
            switch self {
            case .fitSquare, .fillSquare: 120
            case .fitWide: 90
            case .fillWide: 160
            }
        }
    }
}
