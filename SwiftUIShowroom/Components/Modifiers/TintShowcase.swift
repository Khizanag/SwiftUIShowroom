import SwiftUI

struct TintShowcase: View {
    @State private var tintColor: Color = .accentColor
    @State private var applyTint: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "Tint",
            summary: "Overrides the accent color for controls within the view hierarchy.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension TintShowcase {
    var preview: some View {
        controlGroup(tintColor: tintColor, applyTint: applyTint)
    }

    @ViewBuilder var controls: some View {
        ShowcaseColorControl("Tint color", selection: $tintColor)
        ShowcaseToggle("Apply tint", isOn: $applyTint)
    }

    @ViewBuilder func stateView(_ state: TintState) -> some View {
        switch state {
        case .accentColor:
            controlGroup(tintColor: .accentColor, applyTint: true)
        case .custom:
            controlGroup(tintColor: .orange, applyTint: true)
        case .inherited:
            controlGroup(tintColor: .accentColor, applyTint: false)
        }
    }

    func controlGroup(tintColor: Color, applyTint: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Toggle("Toggle", isOn: .constant(true))
            Button("Action Button") {}
                .buttonStyle(.bordered)
            ProgressView(value: 0.6)
        }
        .padding(DesignSystem.Spacing.medium)
        .tint(applyTint ? tintColor : nil)
    }
}

// MARK: - Code generation
private extension TintShowcase {
    var generatedCode: String {
        let components = UIColorComponents(tintColor)
        let red = String(format: "%.2f", components.red)
        let green = String(format: "%.2f", components.green)
        let blue = String(format: "%.2f", components.blue)
        let colorArg = "Color(red: \(red), green: \(green), blue: \(blue))"
        if applyTint {
            return """
            VStack {
                Toggle("Toggle", isOn: $flag)
                Button("Action") {}
            }
            .tint(\(colorArg))
            """
        } else {
            return """
            VStack {
                Toggle("Toggle", isOn: $flag)
                Button("Action") {}
            }
            .tint(nil) // reverts to inherited accent
            """
        }
    }

    struct UIColorComponents {
        let red: Double
        let green: Double
        let blue: Double

        init(_ color: Color) {
            #if canImport(UIKit)
            let uiColor = UIColor(color)
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            self.red = Double(red)
            self.green = Double(green)
            self.blue = Double(blue)
            #elseif canImport(AppKit)
            let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
            self.red = Double(nsColor.redComponent)
            self.green = Double(nsColor.greenComponent)
            self.blue = Double(nsColor.blueComponent)
            #else
            self.red = 0
            self.green = 0
            self.blue = 0
            #endif
        }
    }
}

// MARK: - Nested types
extension TintShowcase {
    fileprivate enum TintState: ShowcaseState {
        case accentColor
        case custom
        case inherited

        var caption: String {
            switch self {
            case .accentColor: "Accent color"
            case .custom: "Custom (.orange)"
            case .inherited: "Nil (inherited)"
            }
        }
    }
}
