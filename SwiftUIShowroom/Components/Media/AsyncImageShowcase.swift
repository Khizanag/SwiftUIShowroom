import SwiftUI

struct AsyncImageShowcase: View {
    @State private var urlString = "https://picsum.photos/300"
    @State private var scale = 1.0
    @State private var usePhaseContent = true
    @State private var contentMode: ContentModeOption = .fill
    @State private var placeholderStyle: PlaceholderStyleOption = .progressView
    @State private var animateTransition = true
    @State private var frameSize = 200.0
    @State private var cornerRadius = 16.0

    // MARK: - Nested types
    enum ContentModeOption: ShowcasePickable {
        case fit
        case fill

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

    enum PlaceholderStyleOption: ShowcasePickable {
        case progressView
        case skeleton
        case color

        var label: String {
            switch self {
            case .progressView: "progressView"
            case .skeleton: "skeleton"
            case .color: "color"
            }
        }
    }

    enum ImagePhaseState: ShowcaseState {
        case loading
        case empty
        case error
        case success

        var caption: String {
            switch self {
            case .loading: "Loading"
            case .empty: "Empty (nil URL)"
            case .error: "Error"
            case .success: "Success"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "AsyncImage",
            summary: "Asynchronously loads a remote image with placeholder and phase-based content.",
        ) {
            PreviewStage {
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
private extension AsyncImageShowcase {
    var preview: some View {
        asyncImageView(
            url: URL(string: urlString),
            size: frameSize,
            radius: cornerRadius,
        )
    }

    @ViewBuilder
    func asyncImageView(url: URL?, size: Double, radius: Double) -> some View {
        if usePhaseContent {
            AsyncImage(
                url: url,
                scale: scale,
                transaction: Transaction(animation: animateTransition ? .easeInOut : nil),
            ) { phase in
                phaseContent(phase)
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        } else {
            AsyncImage(url: url, scale: scale) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode.value)
            } placeholder: {
                placeholderView
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("URL", text: $urlString, prompt: "https://…")
        ShowcaseSlider("Scale", value: $scale, in: 1...3, step: 1)
        ShowcaseToggle("Phase-driven init", isOn: $usePhaseContent)
        ShowcasePicker("Content mode", selection: $contentMode)
        ShowcasePicker("Placeholder style", selection: $placeholderStyle)
        ShowcaseToggle("Animate transition", isOn: $animateTransition)
        ShowcaseSlider("Frame size", value: $frameSize, in: 80...320, step: 1)
        ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...60, step: 1)
    }

    @ViewBuilder
    func stateView(_ state: ImagePhaseState) -> some View {
        switch state {
        case .loading:
            placeholderFallbackView
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .empty:
            asyncImageView(url: nil, size: 120, radius: 12)
        case .error:
            errorView
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .success:
            asyncImageView(
                url: URL(string: "https://picsum.photos/seed/showcase/300"),
                size: 120,
                radius: 12,
            )
        }
    }

    @ViewBuilder
    func phaseContent(_ phase: AsyncImagePhase) -> some View {
        switch phase {
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: contentMode.value)
        case .failure:
            errorView
        case .empty:
            placeholderView
        @unknown default:
            EmptyView()
        }
    }

    var placeholderView: some View {
        placeholderFallbackView
    }

    @ViewBuilder
    var placeholderFallbackView: some View {
        switch placeholderStyle {
        case .progressView:
            ZStack {
                DesignSystem.Color.cardBackground
                ProgressView()
            }
        case .skeleton:
            SkeletonRect()
        case .color:
            DesignSystem.Color.cardBackground
        }
    }

    var errorView: some View {
        ZStack {
            DesignSystem.Color.cardBackground
            Image(systemName: "photo.badge.exclamationmark")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }
}

// MARK: - Skeleton helper
private struct SkeletonRect: View {
    @State private var phase = 0.0

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.secondary.opacity(0.15),
                        Color.secondary.opacity(0.3),
                        Color.secondary.opacity(0.15),
                    ],
                    startPoint: UnitPoint(x: phase - 0.5, y: 0),
                    endPoint: UnitPoint(x: phase + 0.5, y: 0),
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
    }
}

// MARK: - Code generation
private extension AsyncImageShowcase {
    var generatedCode: String {
        let urlExpr = urlString.isEmpty ? "nil" : "URL(string: \"\(urlString)\")"
        let scaleInt = Int(scale)
        let radiusInt = Int(cornerRadius)
        let sizeInt = Int(frameSize)
        let animExpr = animateTransition ? ".easeInOut" : "nil"
        let contentModeLabel = contentMode.label

        if usePhaseContent {
            return """
            AsyncImage(
                url: \(urlExpr),
                scale: \(scaleInt),
                transaction: Transaction(animation: \(animExpr))
            ) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .\(contentModeLabel))
                case .failure:
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: \(sizeInt), height: \(sizeInt))
            .clipShape(RoundedRectangle(cornerRadius: \(radiusInt), style: .continuous))
            """
        } else {
            return """
            AsyncImage(url: \(urlExpr), scale: \(scaleInt)) { image in
                image.resizable().aspectRatio(contentMode: .\(contentModeLabel))
            } placeholder: {
                ProgressView()
            }
            .frame(width: \(sizeInt), height: \(sizeInt))
            .clipShape(RoundedRectangle(cornerRadius: \(radiusInt), style: .continuous))
            """
        }
    }
}
