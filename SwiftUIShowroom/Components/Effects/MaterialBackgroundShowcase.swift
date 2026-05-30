import SwiftUI

struct MaterialBackgroundShowcase: View {
    enum MaterialOption: ShowcasePickable {
        case ultraThin
        case thin
        case regular
        case thick
        case ultraThick
        #if !os(tvOS)
        case bar
        #endif

        var label: String {
            switch self {
            case .ultraThin: return "ultraThinMaterial"
            case .thin: return "thinMaterial"
            case .regular: return "regularMaterial"
            case .thick: return "thickMaterial"
            case .ultraThick: return "ultraThickMaterial"
            #if !os(tvOS)
            case .bar: return "bar"
            #endif
            }
        }

        var material: Material {
            switch self {
            case .ultraThin: return .ultraThinMaterial
            case .thin: return .thinMaterial
            case .regular: return .regularMaterial
            case .thick: return .thickMaterial
            case .ultraThick: return .ultraThickMaterial
            #if !os(tvOS)
            case .bar: return .bar
            #endif
            }
        }
    }

    enum MaterialShapeOption: ShowcasePickable {
        case rectangle
        case roundedRectangle
        case capsule
        case circle

        var label: String {
            switch self {
            case .rectangle: return "Rectangle"
            case .roundedRectangle: return "RoundedRectangle(cornerRadius:)"
            case .capsule: return "Capsule"
            case .circle: return "Circle"
            }
        }
    }

    enum MaterialState: ShowcaseState {
        case ultraThin
        case regular
        case ultraThick
        case capsule

        var caption: String {
            switch self {
            case .ultraThin: return "Ultra Thin"
            case .regular: return "Regular"
            case .ultraThick: return "Ultra Thick"
            case .capsule: return "Capsule shape"
            }
        }
    }

    @State private var material: MaterialOption = .regular
    @State private var selectedShape: MaterialShapeOption = .roundedRectangle
    @State private var cornerRadius: Double = 16

    var body: some View {
        ShowcaseScreen(
            title: "Material Background",
            summary: "Applies a system blur material as a background for translucency and vibrancy.",
        ) {
            PreviewStage(backdrop: .colorful) {
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
private extension MaterialBackgroundShowcase {
    var preview: some View {
        materialCard(
            mat: material.material,
            shapeOption: selectedShape,
            radius: cornerRadius,
            labelText: material.label,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Material", selection: $material)
        ShowcasePicker("Shape", selection: $selectedShape)
        if selectedShape == .roundedRectangle {
            ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...48, step: 1)
        }
    }

    @ViewBuilder func stateView(_ state: MaterialState) -> some View {
        switch state {
        case .ultraThin:
            materialCard(
                mat: .ultraThinMaterial,
                shapeOption: .roundedRectangle,
                radius: 16,
                labelText: ".ultraThinMaterial",
            )
        case .regular:
            materialCard(
                mat: .regularMaterial,
                shapeOption: .roundedRectangle,
                radius: 16,
                labelText: ".regularMaterial",
            )
        case .ultraThick:
            materialCard(
                mat: .ultraThickMaterial,
                shapeOption: .roundedRectangle,
                radius: 16,
                labelText: ".ultraThickMaterial",
            )
        case .capsule:
            materialCard(
                mat: .regularMaterial,
                shapeOption: .capsule,
                radius: 16,
                labelText: ".capsule",
            )
        }
    }

    func materialCard(
        mat: Material,
        shapeOption: MaterialShapeOption,
        radius: Double,
        labelText: String,
    ) -> some View {
        Text(labelText)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(.primary)
            .padding(DesignSystem.Spacing.medium)
            .background(materialBackground(mat: mat, shapeOption: shapeOption, radius: radius))
    }

    @ViewBuilder func materialBackground(
        mat: Material,
        shapeOption: MaterialShapeOption,
        radius: Double,
    ) -> some View {
        switch shapeOption {
        case .rectangle:
            Rectangle().fill(mat)
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: radius).fill(mat)
        case .capsule:
            Capsule().fill(mat)
        case .circle:
            Circle().fill(mat)
        }
    }
}

// MARK: - Code generation
private extension MaterialBackgroundShowcase {
    var generatedCode: String {
        let shapeCode = resolvedShapeCode
        return """
        content
            .padding()
            .background(.\(material.label), in: \(shapeCode))
        """
    }

    var resolvedShapeCode: String {
        switch selectedShape {
        case .rectangle: return ".rect"
        case .roundedRectangle: return ".rect(cornerRadius: \(Int(cornerRadius)))"
        case .capsule: return ".capsule"
        case .circle: return ".circle"
        }
    }
}
