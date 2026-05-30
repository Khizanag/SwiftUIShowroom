import SwiftUI

struct CornerRadiusShowcase: View {
    enum CornerRadiusState: ShowcaseState {
        case none
        case small
        case medium
        case large
        case capsule

        var caption: String {
            switch self {
            case .none: "radius 0"
            case .small: "radius 8"
            case .medium: "radius 16"
            case .large: "radius 28"
            case .capsule: "radius 45"
            }
        }

        var radius: CGFloat {
            switch self {
            case .none: 0
            case .small: 8
            case .medium: 16
            case .large: 28
            case .capsule: 45
            }
        }
    }

    @State private var radius: Double = 12
    @State private var antialiased: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Corner Radius (Deprecated)",
            summary: "Clips view to a rounded rect. Prefer clipShape(.rect(cornerRadius:)).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension CornerRadiusShowcase {
    var preview: some View {
        Color.accentColor
            .frame(width: 140, height: 90)
            .cornerRadius(CGFloat(radius), antialiased: antialiased)
    }

    @ViewBuilder var controls: some View {
        ShowcaseSlider("Radius", value: $radius, in: 0...48, step: 1)
        ShowcaseToggle("Antialiased", isOn: $antialiased)
    }

    @ViewBuilder func stateView(_ state: CornerRadiusState) -> some View {
        Color.accentColor
            .frame(width: 100, height: 64)
            .cornerRadius(state.radius, antialiased: true)
            .overlay(
                Text(state.caption)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.onAccent),
            )
    }
}

// MARK: - Code generation
private extension CornerRadiusShowcase {
    var generatedCode: String {
        let radiusValue = Int(radius)
        let antialiasedValue = antialiased ? "true" : "false"
        return """
            Color.accentColor
                .frame(width: 120, height: 80)
                .cornerRadius(\(radiusValue), antialiased: \(antialiasedValue))
            """
    }
}
