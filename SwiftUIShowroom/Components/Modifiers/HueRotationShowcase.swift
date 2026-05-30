import SwiftUI

struct HueRotationShowcase: View {
    @State private var angleDegrees: Double = 0

    enum HueState: ShowcaseState {
        case zero
        case quarter
        case half
        case threeQuarter
        case full

        var caption: String {
            switch self {
            case .zero: "0 deg (original)"
            case .quarter: "90 deg"
            case .half: "180 deg"
            case .threeQuarter: "270 deg"
            case .full: "360 deg (original)"
            }
        }

        var degrees: Double {
            switch self {
            case .zero: 0
            case .quarter: 90
            case .half: 180
            case .threeQuarter: 270
            case .full: 360
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "Hue Rotation",
            summary: "Shifts every color's hue around the color wheel by the given angle.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension HueRotationShowcase {
    var preview: some View {
        hueSwatch(degrees: angleDegrees)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Angle (degrees)", value: $angleDegrees, in: 0...360, step: 1)
    }

    @ViewBuilder func stateView(_ state: HueState) -> some View {
        hueSwatch(degrees: state.degrees)
    }

    func hueSwatch(degrees: Double) -> some View {
        ZStack {
            LinearGradient(
                colors: [.red, .orange, .yellow, .green, .blue, .purple],
                startPoint: .leading,
                endPoint: .trailing,
            )
            Text("Hue")
                .font(DesignSystem.Font.title)
                .foregroundStyle(.white)
        }
        .frame(width: 220, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .hueRotation(.degrees(degrees))
    }
}

// MARK: - Code generation
private extension HueRotationShowcase {
    var generatedCode: String {
        let degreesStr = angleDegrees == angleDegrees.rounded()
            ? String(Int(angleDegrees))
            : String(format: "%.1f", angleDegrees)
        return """
        yourView
            .hueRotation(.degrees(\(degreesStr)))
        """
    }
}
