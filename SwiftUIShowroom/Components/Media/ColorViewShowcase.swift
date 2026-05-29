import SwiftUI

struct ColorViewShowcase: View {
    @State private var colorSource: ColorSourceKind = .system
    @State private var systemColor: Color = .accentColor
    @State private var opacity: Double = 1
    @State private var asGradient: Bool = false
    @State private var clipShape: ClipShapeKind = .roundedRectangle
    @State private var cornerRadius: Double = 16
    @State private var width: Double = 220
    @State private var height: Double = 140

    var body: some View {
        ShowcaseScreen(
            title: "Color (as View)",
            summary: "Color as a View — fills its frame, adapts to light/dark, and supports .opacity and .gradient.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension ColorViewShowcase {
    enum ColorSourceKind: ShowcasePickable {
        case system, custom, asset

        var label: String {
            switch self {
            case .system: "system"
            case .custom: "custom RGB"
            case .asset: "asset catalog"
            }
        }
    }

    enum ClipShapeKind: ShowcasePickable {
        case rectangle, roundedRectangle, capsule, circle

        var label: String {
            switch self {
            case .rectangle: "rectangle"
            case .roundedRectangle: "roundedRectangle"
            case .capsule: "capsule"
            case .circle: "circle"
            }
        }
    }

    enum ColorViewState: ShowcaseState {
        case flat, withOpacity, withGradient, clippedCircle

        var caption: String {
            switch self {
            case .flat: "Flat fill"
            case .withOpacity: "50% opacity"
            case .withGradient: "Auto gradient"
            case .clippedCircle: "Circle clip"
            }
        }
    }
}

// MARK: - Sub-views
private extension ColorViewShowcase {
    var preview: some View {
        clipped(colorSwatch(color: systemColor, opacity: opacity, useGradient: asGradient))
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Color source", selection: $colorSource)
        ShowcaseColorControl("Color", selection: $systemColor)
        ShowcaseSlider("Opacity", value: $opacity, in: 0...1, step: 0.05)
        ShowcaseToggle("Use .gradient", isOn: $asGradient)
        ShowcasePicker("Clip shape", selection: $clipShape)
        ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...60)
        ShowcaseSlider("Width", value: $width, in: 40...320)
        ShowcaseSlider("Height", value: $height, in: 40...320)
    }

    @ViewBuilder
    func stateView(_ state: ColorViewState) -> some View {
        switch state {
        case .flat:
            clippedState(
                color: .accentColor,
                opacity: 1,
                useGradient: false,
                shape: .roundedRectangle,
                radius: 16
            )
        case .withOpacity:
            clippedState(
                color: .accentColor,
                opacity: 0.5,
                useGradient: false,
                shape: .roundedRectangle,
                radius: 16
            )
        case .withGradient:
            clippedState(
                color: .accentColor,
                opacity: 1,
                useGradient: true,
                shape: .roundedRectangle,
                radius: 16
            )
        case .clippedCircle:
            clippedState(
                color: .accentColor,
                opacity: 1,
                useGradient: false,
                shape: .circle,
                radius: 0
            )
        }
    }

    @ViewBuilder
    func colorSwatch(color: Color, opacity: Double, useGradient: Bool) -> some View {
        if useGradient {
            Rectangle()
                .fill(color.opacity(opacity).gradient)
                .frame(width: width, height: height)
        } else {
            color.opacity(opacity)
                .frame(width: width, height: height)
        }
    }

    @ViewBuilder
    func clipped(_ content: some View) -> some View {
        switch clipShape {
        case .rectangle:
            content
        case .roundedRectangle:
            content.clipShape(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
        case .capsule:
            content.clipShape(Capsule())
        case .circle:
            content.clipShape(Circle())
        }
    }

    @ViewBuilder
    func clippedState(
        color: Color,
        opacity: Double,
        useGradient: Bool,
        shape: ClipShapeKind,
        radius: Double
    ) -> some View {
        let base: AnyView = useGradient
            ? AnyView(Rectangle().fill(color.opacity(opacity).gradient).frame(width: 100, height: 64))
            : AnyView(color.opacity(opacity).frame(width: 100, height: 64))
        switch shape {
        case .rectangle:
            base
        case .roundedRectangle:
            base.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        case .capsule:
            base.clipShape(Capsule())
        case .circle:
            base.clipShape(Circle())
        }
    }
}

// MARK: - Code generation
private extension ColorViewShowcase {
    var generatedCode: String {
        var lines: [String] = []
        let colorToken = colorSourceToken
        if asGradient {
            lines.append("\(colorToken).opacity(\(formatDouble(opacity))).gradient")
        } else {
            lines.append(colorToken)
            lines.append("    .opacity(\(formatDouble(opacity)))")
        }
        lines.append("    .frame(width: \(formatDouble(width)), height: \(formatDouble(height)))")
        lines.append("    \(clipShapeModifier)")
        return lines.joined(separator: "\n")
    }

    var colorSourceToken: String {
        switch colorSource {
        case .system, .custom:
            return ".accentColor"
        case .asset:
            return "Color(\"YourColorName\")"
        }
    }

    var clipShapeModifier: String {
        switch clipShape {
        case .rectangle:
            return ""
        case .roundedRectangle:
            return ".clipShape(RoundedRectangle(cornerRadius: \(formatDouble(cornerRadius)), style: .continuous))"
        case .capsule:
            return ".clipShape(Capsule())"
        case .circle:
            return ".clipShape(Circle())"
        }
    }

    func formatDouble(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.2f", value)
    }
}
