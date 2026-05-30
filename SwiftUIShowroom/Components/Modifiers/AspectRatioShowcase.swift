import SwiftUI

struct AspectRatioShowcase: View {
    @State private var ratioValue: Double = 1.0
    @State private var useCustomRatio: Bool = true
    @State private var contentModeOption: ContentModeOption = .fit

    var body: some View {
        ShowcaseScreen(
            title: "Aspect Ratio",
            summary: "Constrains dimensions to a width-to-height ratio, fitting or filling the parent context.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension AspectRatioShowcase {
    var preview: some View {
        ratioCard(
            ratio: useCustomRatio ? ratioValue : nil,
            mode: contentModeOption.value,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcaseToggle("Use custom ratio", isOn: $useCustomRatio)
        if useCustomRatio {
            ShowcaseSlider("Ratio (w/h)", value: $ratioValue, in: 0.25...4, step: 0.05)
        }
        ShowcasePicker("Content mode", selection: $contentModeOption)
    }

    @ViewBuilder func stateView(_ state: AspectRatioState) -> some View {
        switch state {
        case .defaultState:
            ratioCard(ratio: 1.0, mode: .fit)
        case .widescreen:
            ratioCard(ratio: 16.0 / 9.0, mode: .fit)
        case .portrait:
            ratioCard(ratio: 3.0 / 4.0, mode: .fit)
        case .fill:
            ratioCard(ratio: 4.0 / 3.0, mode: .fill)
                .clipped()
        case .intrinsic:
            ratioCard(ratio: nil, mode: .fit)
        }
    }

    func ratioCard(ratio: CGFloat?, mode: ContentMode) -> some View {
        ZStack {
            LinearGradient(
                colors: [DesignSystem.Color.accent, DesignSystem.Color.accent.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "photo.fill")
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                if let ratio {
                    Text(ratioLabel(ratio))
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.8))
                } else {
                    Text("intrinsic")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.8))
                }
            }
        }
        .frame(maxWidth: 240)
        .aspectRatio(ratio, contentMode: mode)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func ratioLabel(_ ratio: CGFloat) -> String {
        let formatted = ratio == ratio.rounded() ? String(format: "%.0f:1", ratio) : String(format: "%.2f", ratio)
        return formatted
    }
}

// MARK: - Code generation
private extension AspectRatioShowcase {
    var generatedCode: String {
        let ratioArg: String
        if useCustomRatio {
            let rounded = (ratioValue * 100).rounded() / 100
            ratioArg = String(format: "%.2f", rounded)
        } else {
            ratioArg = "nil"
        }
        let modeArg = contentModeOption.value == .fit ? "fit" : "fill"
        return "Image(\"photo\")\n    .resizable()\n    .aspectRatio(\(ratioArg), contentMode: .\(modeArg))"
    }
}

// MARK: - Nested enums
extension AspectRatioShowcase {
    enum ContentModeOption: ShowcasePickable {
        case fit
        case fill

        var label: String {
            switch self {
            case .fit: ".fit"
            case .fill: ".fill"
            }
        }

        var value: ContentMode {
            switch self {
            case .fit: .fit
            case .fill: .fill
            }
        }
    }

    enum AspectRatioState: ShowcaseState {
        case defaultState
        case widescreen
        case portrait
        case fill
        case intrinsic

        var caption: String {
            switch self {
            case .defaultState: "1:1 fit"
            case .widescreen: "16:9 fit"
            case .portrait: "3:4 fit"
            case .fill: "4:3 fill"
            case .intrinsic: "nil (intrinsic)"
            }
        }
    }
}
