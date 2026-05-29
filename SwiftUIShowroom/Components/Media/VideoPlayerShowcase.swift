import AVKit
import SwiftUI

struct VideoPlayerShowcase: View {
    @State private var urlString = VideoPlayerShowcase.defaultURLString
    @State private var autoplay = false
    @State private var showsOverlay = false
    @State private var overlayText = "LIVE"
    @State private var width = 320.0
    @State private var height = 180.0
    @State private var cornerRadius = 12.0
    @State private var accessibilityLabel = "Sample video"
    @State private var player: AVPlayer?

    enum VideoPlayerState: ShowcaseState {
        case defaultPlayer
        case loading
        case empty

        var caption: String {
            switch self {
            case .defaultPlayer: "Default"
            case .loading: "Loading"
            case .empty: "No URL"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "VideoPlayer",
            summary: "Embeds an AVPlayer with Apple's standard playback controls, plus optional SwiftUI overlays.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
        .task {
            guard let url = URL(string: urlString) else { return }
            let newPlayer = AVPlayer(url: url)
            if autoplay { newPlayer.play() }
            player = newPlayer
        }
    }
}

// MARK: - Constants
private extension VideoPlayerShowcase {
    static let defaultURLString =
        "https://devstreaming-cdn.apple.com/videos/streaming/examples" +
        "/bipbop_16x9/bipbop_16x9_variant.m3u8"
}

// MARK: - Sub-views
private extension VideoPlayerShowcase {
    var preview: some View {
        playerView(
            player: player,
            overlayText: showsOverlay ? overlayText : nil,
            width: width,
            height: height,
            radius: cornerRadius,
        )
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    func playerView(
        player: AVPlayer?,
        overlayText: String?,
        width: Double,
        height: Double,
        radius: Double,
    ) -> some View {
        if let overlayText {
            VideoPlayer(player: player) {
                overlayBadge(text: overlayText)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        } else {
            VideoPlayer(player: player)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }

    @ViewBuilder
    func overlayBadge(text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.caption)
            .bold()
            .padding(DesignSystem.Spacing.xSmall)
            .background(.red, in: Capsule())
            .padding(DesignSystem.Spacing.small)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder var controls: some View {
        ShowcaseTextControl("URL", text: $urlString, prompt: "https://…")
        ShowcaseToggle("Autoplay", isOn: $autoplay)
        ShowcaseToggle("Show overlay", isOn: $showsOverlay)
        ShowcaseTextControl("Overlay text", text: $overlayText, prompt: "Label…")
        ShowcaseSlider("Width", value: $width, in: 160...360, step: 1)
        ShowcaseSlider("Height", value: $height, in: 90...240, step: 1)
        ShowcaseSlider("Corner radius", value: $cornerRadius, in: 0...40, step: 1)
        ShowcaseTextControl("Accessibility label", text: $accessibilityLabel, prompt: "Describe the video…")
    }

    @ViewBuilder
    func stateView(_ state: VideoPlayerState) -> some View {
        switch state {
        case .defaultPlayer:
            playerView(
                player: URL(string: urlString).map { AVPlayer(url: $0) },
                overlayText: nil,
                width: 200,
                height: 113,
                radius: 12,
            )
        case .loading:
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DesignSystem.Color.cardBackground)
                ProgressView()
            }
            .frame(width: 200, height: 113)
        case .empty:
            playerView(
                player: nil,
                overlayText: nil,
                width: 200,
                height: 113,
                radius: 12,
            )
        }
    }
}

// MARK: - Code generation
private extension VideoPlayerShowcase {
    var generatedCode: String {
        let radiusInt = Int(cornerRadius)
        let widthInt = Int(width)
        let heightInt = Int(height)
        let overlayBlock = showsOverlay ? overlaySnippet : ""

        return """
        VideoPlayer(player: player)\(overlayBlock)
            .frame(width: \(widthInt), height: \(heightInt))
            .clipShape(RoundedRectangle(cornerRadius: \(radiusInt), style: .continuous))
            .accessibilityLabel("\(accessibilityLabel)")
            .task {
                guard let url = URL(string: "\(urlString)") else { return }
                let player = AVPlayer(url: url)
                \(autoplay ? "player.play()" : "// autoplay off")
                self.player = player
            }
        """
    }

    var overlaySnippet: String {
        """
         {
            Text("\(overlayText)")
                .font(.caption).bold()
                .padding(6)
                .background(.red, in: Capsule())
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        """
    }
}
