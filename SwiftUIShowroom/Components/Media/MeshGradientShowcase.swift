import SwiftUI

struct MeshGradientShowcase: View {
    @State private var gridWidth: Int = 3
    @State private var gridHeight: Int = 3
    @State private var cornerColorA: Color = .purple
    @State private var cornerColorB: Color = .pink
    @State private var cornerColorC: Color = .orange
    @State private var smoothsColors: Bool = true
    @State private var animateVertices: Bool = true
    @State private var size: Double = 280
    @State private var phase: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ShowcaseScreen(
            title: "MeshGradient",
            summary: "A 2D grid of positioned colors interpolated across Bezier patches for rich multi-color blends.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
private extension MeshGradientShowcase {
    enum MeshState: ShowcaseState {
        case vibrant, muted, minimal

        var caption: String {
            switch self {
            case .vibrant: "Vibrant"
            case .muted: "Muted"
            case .minimal: "Minimal"
            }
        }
    }
}

// MARK: - Sub-views
private extension MeshGradientShowcase {
    var preview: some View {
        ZStack {
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
                MeshGradient(
                    width: gridWidth,
                    height: gridHeight,
                    points: meshPoints(
                        width: gridWidth,
                        height: gridHeight,
                        phase: animateVertices && !reduceMotion ? phase : 0,
                    ),
                    colors: meshColors(width: gridWidth, height: gridHeight),
                    smoothsColors: smoothsColors,
                )
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
            } else {
                LinearGradient(
                    colors: [cornerColorA, cornerColorB, cornerColorC],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing,
                )
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
            }
        }
        .onAppear {
            guard !reduceMotion && animateVertices else { return }
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
        .onChange(of: animateVertices) { _, newValue in
            if newValue && !reduceMotion {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            } else {
                withAnimation(.default) { phase = 0 }
            }
        }
    }

    @ViewBuilder var controls: some View {
        ShowcaseStepper("Grid Width", value: $gridWidth, in: 2...5)
        ShowcaseStepper("Grid Height", value: $gridHeight, in: 2...5)
        ShowcaseColorControl("Corner Color A", selection: $cornerColorA, supportsOpacity: false)
        ShowcaseColorControl("Corner Color B", selection: $cornerColorB, supportsOpacity: false)
        ShowcaseColorControl("Corner Color C", selection: $cornerColorC, supportsOpacity: false)
        ShowcaseToggle("Smooths Colors", isOn: $smoothsColors)
        ShowcaseToggle("Animate Vertices", isOn: $animateVertices)
        ShowcaseSlider("Size", value: $size, in: 120...360, step: 4)
    }

    @ViewBuilder func stateView(_ state: MeshState) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, *) {
            MeshGradient(
                width: 3,
                height: 3,
                points: staticPoints3x3(),
                colors: stateColors(state),
                smoothsColors: true,
            )
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
        } else {
            LinearGradient(
                colors: stateColors(state),
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
        }
    }
}

// MARK: - Mesh helpers
private extension MeshGradientShowcase {
    func meshPoints(width: Int, height: Int, phase: Double) -> [SIMD2<Float>] {
        var points: [SIMD2<Float>] = []
        for row in 0..<height {
            for col in 0..<width {
                let baseX = Float(col) / Float(width - 1)
                let baseY = Float(row) / Float(height - 1)
                let isEdge = col == 0 || col == width - 1 || row == 0 || row == height - 1
                if isEdge {
                    points.append(SIMD2<Float>(baseX, baseY))
                } else {
                    let jitterX = Float(sin(phase + Double(col + row * width) * 0.7)) * 0.06
                    let jitterY = Float(cos(phase + Double(col * height + row) * 0.5)) * 0.06
                    points.append(SIMD2<Float>(baseX + jitterX, baseY + jitterY))
                }
            }
        }
        return points
    }

    func staticPoints3x3() -> [SIMD2<Float>] {
        [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5], [0.5, 0.5], [1, 0.5],
            [0, 1], [0.5, 1], [1, 1],
        ]
    }

    func meshColors(width: Int, height: Int) -> [Color] {
        let palette: [Color] = [
            cornerColorA, .blue, cornerColorB,
            .green, .white, .yellow,
            cornerColorC, .red, .mint,
            .teal, .indigo, .cyan,
            .brown, .gray, .pink,
            .orange, .purple, .accentColor,
            cornerColorA, cornerColorB, cornerColorC,
            .blue, .green, .red,
            .mint, .teal, .yellow,
        ]
        let count = width * height
        return Array(palette.prefix(count))
    }

    func stateColors(_ state: MeshState) -> [Color] {
        switch state {
        case .vibrant:
            return [.purple, .blue, .pink, .orange, .yellow, .red, .indigo, .mint, .teal]
        case .muted:
            return [
                .purple.opacity(0.4), .blue.opacity(0.4), .pink.opacity(0.4),
                .orange.opacity(0.4), .gray.opacity(0.3), .yellow.opacity(0.4),
                .indigo.opacity(0.4), .teal.opacity(0.4), .mint.opacity(0.4),
            ]
        case .minimal:
            return [
                .white, .gray.opacity(0.3), .white, .gray.opacity(0.2),
                .white, .gray.opacity(0.2), .white, .gray.opacity(0.3), .white,
            ]
        }
    }
}

// MARK: - Code generation
private extension MeshGradientShowcase {
    var generatedCode: String {
        let pointLines = gridPointLines(width: gridWidth, height: gridHeight)
        let colorLines = gridColorLines(width: gridWidth, height: gridHeight)
        return """
        MeshGradient(
            width: \(gridWidth),
            height: \(gridHeight),
            points: [
        \(pointLines)
            ],
            colors: [
        \(colorLines)
            ],
            smoothsColors: \(smoothsColors)
        )
        .frame(width: \(Int(size)), height: \(Int(size)))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        """
    }

    func gridPointLines(width: Int, height: Int) -> String {
        var rows: [String] = []
        for row in 0..<height {
            var rowParts: [String] = []
            for col in 0..<width {
                let xVal = col == 0 ? "0" : col == width - 1 ? "1" : "0.5"
                let yVal = row == 0 ? "0" : row == height - 1 ? "1" : "0.5"
                rowParts.append("[\(xVal),\(yVal)]")
            }
            rows.append("        " + rowParts.joined(separator: ", ") + ",")
        }
        return rows.joined(separator: "\n")
    }

    func gridColorLines(width: Int, height: Int) -> String {
        let palette = meshColors(width: width, height: height)
        let names = palette.map { colorName($0) }
        var rows: [String] = []
        var idx = 0
        for _ in 0..<height {
            var rowParts: [String] = []
            for _ in 0..<width {
                rowParts.append(idx < names.count ? names[idx] : ".clear")
                idx += 1
            }
            rows.append("        " + rowParts.joined(separator: ", ") + ",")
        }
        return rows.joined(separator: "\n")
    }

    func colorName(_ color: Color) -> String {
        if let named = namedColorToken(color) { return named }
        return cornerColorToken(color)
    }

    private func namedColorToken(_ color: Color) -> String? {
        let named: [(Color, String)] = [
            (.purple, ".purple"), (.blue, ".blue"), (.pink, ".pink"), (.orange, ".orange"),
            (.yellow, ".yellow"), (.red, ".red"), (.green, ".green"), (.mint, ".mint"),
            (.teal, ".teal"), (.indigo, ".indigo"), (.cyan, ".cyan"), (.brown, ".brown"),
            (.gray, ".gray"), (.white, ".white"), (.accentColor, ".accentColor"),
        ]
        return named.first { $0.0 == color }?.1
    }

    private func cornerColorToken(_ color: Color) -> String {
        if color == cornerColorA { return ".purple" }
        if color == cornerColorB { return ".pink" }
        if color == cornerColorC { return ".orange" }
        return ".accentColor"
    }
}
