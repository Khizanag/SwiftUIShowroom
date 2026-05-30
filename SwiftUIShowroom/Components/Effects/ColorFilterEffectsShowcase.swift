import SwiftUI

struct ColorFilterEffectsShowcase: View {
    @State private var filter: FilterKind = .saturation
    @State private var amount: Double = 1.0
    @State private var hueAngle: Double = 0.0
    @State private var multiplyColor: Color = .white

    var body: some View {
        ShowcaseScreen(
            title: "Color Filter Effects",
            summary: "Per-pixel color adjustment filters: hue, saturation, brightness, contrast, grayscale, multiply.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ColorFilterEffectsShowcase {
    var preview: some View {
        filteredSwatch(
            filter: filter,
            amount: amount,
            hueAngle: hueAngle,
            multiplyColor: multiplyColor,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Filter", selection: $filter)
        if filter == .hueRotation {
            ShowcaseSlider("Hue angle (°)", value: $hueAngle, in: 0...360, step: 1)
        } else if filter == .colorMultiply {
            ShowcaseColorControl("Multiply color", selection: $multiplyColor, supportsOpacity: false)
        } else {
            ShowcaseSlider("Amount", value: $amount, in: 0.0...2.0, step: 0.05)
        }
    }

    @ViewBuilder func stateView(_ state: FilterState) -> some View {
        filteredSwatch(
            filter: state.filter,
            amount: state.amount,
            hueAngle: state.hueAngle,
            multiplyColor: state.multiplyColor,
        )
    }

    func filteredSwatch(
        filter: FilterKind,
        amount: Double,
        hueAngle: Double,
        multiplyColor: Color
    ) -> some View {
        sampleContent
            .modifier(
                ColorFilterModifier(
                    filter: filter,
                    amount: amount,
                    hueAngle: hueAngle,
                    multiplyColor: multiplyColor,
                )
            )
    }

    var sampleContent: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Circle().fill(Color.red).frame(width: DesignSystem.Size.Icon.large, height: DesignSystem.Size.Icon.large)
            Circle().fill(Color.green).frame(width: DesignSystem.Size.Icon.large, height: DesignSystem.Size.Icon.large)
            Circle().fill(Color.blue).frame(width: DesignSystem.Size.Icon.large, height: DesignSystem.Size.Icon.large)
            Circle().fill(Color.orange).frame(width: DesignSystem.Size.Icon.large, height: DesignSystem.Size.Icon.large)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Code generation
private extension ColorFilterEffectsShowcase {
    var generatedCode: String {
        switch filter {
        case .hueRotation:
            return "view\n    .hueRotation(.degrees(\(Int(hueAngle))))"
        case .saturation:
            return "view\n    .saturation(\(amount.formatted(.number.precision(.fractionLength(0...2)))))"
        case .brightness:
            return "view\n    .brightness(\(amount.formatted(.number.precision(.fractionLength(0...2)))))"
        case .contrast:
            return "view\n    .contrast(\(amount.formatted(.number.precision(.fractionLength(0...2)))))"
        case .grayscale:
            return "view\n    .grayscale(\(amount.formatted(.number.precision(.fractionLength(0...2)))))"
        case .colorMultiply:
            return "view\n    .colorMultiply(Color(...))"
        }
    }
}

// MARK: - ViewModifier
private struct ColorFilterModifier: ViewModifier {
    let filter: ColorFilterEffectsShowcase.FilterKind
    let amount: Double
    let hueAngle: Double
    let multiplyColor: Color

    func body(content: Content) -> some View {
        switch filter {
        case .hueRotation:
            content.hueRotation(.degrees(hueAngle))
        case .saturation:
            content.saturation(amount)
        case .brightness:
            content.brightness(amount - 1.0)
        case .contrast:
            content.contrast(amount)
        case .grayscale:
            content.grayscale(amount > 1 ? 1 : amount)
        case .colorMultiply:
            content.colorMultiply(multiplyColor)
        }
    }
}

// MARK: - Nested types
extension ColorFilterEffectsShowcase {
    fileprivate enum FilterKind: String, ShowcasePickable, CaseIterable {
        case hueRotation
        case saturation
        case brightness
        case contrast
        case grayscale
        case colorMultiply

        var label: String {
            switch self {
            case .hueRotation: "hueRotation"
            case .saturation: "saturation"
            case .brightness: "brightness"
            case .contrast: "contrast"
            case .grayscale: "grayscale"
            case .colorMultiply: "colorMultiply"
            }
        }
    }

    fileprivate enum FilterState: ShowcaseState {
        case normal
        case desaturated
        case hueShifted
        case highContrast
        case grayscaleOnly
        case multiplied

        var caption: String {
            switch self {
            case .normal: "Normal (saturation 1.0)"
            case .desaturated: "Desaturated (0.0)"
            case .hueShifted: "Hue +180°"
            case .highContrast: "High contrast (2.0)"
            case .grayscaleOnly: "Grayscale (1.0)"
            case .multiplied: "Multiply magenta"
            }
        }

        var filter: FilterKind {
            switch self {
            case .normal: .saturation
            case .desaturated: .saturation
            case .hueShifted: .hueRotation
            case .highContrast: .contrast
            case .grayscaleOnly: .grayscale
            case .multiplied: .colorMultiply
            }
        }

        var amount: Double {
            switch self {
            case .normal: 1.0
            case .desaturated: 0.0
            case .hueShifted: 0.0
            case .highContrast: 2.0
            case .grayscaleOnly: 1.0
            case .multiplied: 1.0
            }
        }

        var hueAngle: Double {
            switch self {
            case .hueShifted: 180.0
            default: 0.0
            }
        }

        var multiplyColor: Color {
            switch self {
            case .multiplied: Color(red: 1.0, green: 0.4, blue: 0.8)
            default: .white
            }
        }
    }
}
