import SwiftUI

struct FullScreenCoverShowcase: View {
    // MARK: - Nested types
    enum BackgroundOption: ShowcasePickable {
        case system
        case regularMaterial
        case thinMaterial
        case clear

        var label: String {
            switch self {
            case .system: "system"
            case .regularMaterial: ".regularMaterial"
            case .thinMaterial: ".thinMaterial"
            case .clear: "Color.clear"
            }
        }

        var code: String { label }
    }

    enum CoverState: ShowcaseState {
        case `default`
        case longContent
        case loading

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            case .loading: "Loading"
            }
        }
    }

    // MARK: - State
    @State private var isPresented = false
    @State private var useOnDismiss = false
    @State private var background: BackgroundOption = .system
    @State private var dismissCount = 0

    // MARK: - Body
    var body: some View {
        ShowcaseScreen(
            title: "Full Screen Cover",
            summary: "Covers the entire screen with a modal view; requires an explicit dismiss action.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension FullScreenCoverShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            presentButton
            if dismissCount > 0 {
                Text("Dismissed \(dismissCount)×")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                    .contentTransition(.numericText())
                    .animation(.default, value: dismissCount)
            }
        }
        #if !os(macOS)
        .fullScreenCover(isPresented: $isPresented, onDismiss: onDismissHandler) {
            CoverContentView(style: .default, background: background)
        }
        #endif
    }

    var presentButton: some View {
        Button {
            isPresented = true
        } label: {
            Label("Present Cover", systemImage: "rectangle.expand.vertical")
        }
        .buttonStyle(.borderedProminent)
        #if os(macOS)
        .disabled(true)
        #endif
    }

    var onDismissHandler: (() -> Void)? {
        useOnDismiss ? { dismissCount += 1 } : nil
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("Present cover", isOn: $isPresented)
        ShowcaseToggle("onDismiss callback", isOn: $useOnDismiss)
        ShowcasePicker("Background", selection: $background)
    }

    @ViewBuilder
    func stateView(_ state: CoverState) -> some View {
        CoverStateCell(state: state)
    }
}

// MARK: - Code generation
private extension FullScreenCoverShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("@State private var isPresented = false")
        lines.append("")
        lines.append("Button(\"Present\") { isPresented = true }")
        lines.append("    .fullScreenCover(")
        lines.append("        isPresented: $isPresented,")
        if useOnDismiss {
            lines.append("        onDismiss: { /* handle dismiss */ }")
        } else {
            lines.append("        onDismiss: nil")
        }
        lines.append("    ) {")
        lines.append("        CoverContentView()")
        if background != .system {
            lines.append("            .presentationBackground(\(background.code))")
        }
        lines.append("            // Dismiss from inside:")
        lines.append("            // @Environment(\\.dismiss) private var dismiss")
        lines.append("    }")
        return lines.joined(separator: "\n")
    }
}

// MARK: - CoverContentView
private struct CoverContentView: View {
    enum ContentStyle {
        case `default`, longContent, loading
    }

    @Environment(\.dismiss) private var dismiss

    var style: ContentStyle
    var background: FullScreenCoverShowcase.BackgroundOption

    var body: some View {
        ZStack {
            backdropColor
                .ignoresSafeArea()
            contentBody
        }
    }

    @ViewBuilder
    private var contentBody: some View {
        switch style {
        case .default:
            defaultContent
        case .longContent:
            longContentView
        case .loading:
            loadingContent
        }
    }

    private var defaultContent: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Image(systemName: "rectangle.expand.vertical")
                .font(DesignSystem.Font.largeTitle)
                .imageScale(.large)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Full Screen Cover")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.primary)
            Text("The entire screen is covered.\nUse an explicit button to dismiss.")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
            dismissButton
        }
        .padding(DesignSystem.Spacing.xLarge)
    }

    private var longContentView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(0..<20, id: \.self) { index in
                    Text("Content row \(index + 1)")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(DesignSystem.Spacing.small)
                        .background(
                            DesignSystem.Color.cardBackground,
                            in: .rect(cornerRadius: DesignSystem.CornerRadius.small),
                        )
                }
                dismissButton
            }
            .padding(DesignSystem.Spacing.large)
        }
    }

    private var loadingContent: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading…")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.secondary)
            dismissButton
        }
        .padding(DesignSystem.Spacing.xLarge)
    }

    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Label("Dismiss", systemImage: "xmark.circle.fill")
        }
        .buttonStyle(.bordered)
    }

    private var backdropColor: Color {
        switch background {
        case .system, .regularMaterial: DesignSystem.Color.background
        case .thinMaterial: DesignSystem.Color.background.opacity(0.85)
        case .clear: .clear
        }
    }
}

// MARK: - CoverStateCell
private struct CoverStateCell: View {
    var state: FullScreenCoverShowcase.CoverState

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
            Text(state.caption)
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.primary)
        }
        .padding(DesignSystem.Spacing.small)
        .frame(maxWidth: .infinity)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }

    private var iconName: String {
        switch state {
        case .default: "rectangle.expand.vertical"
        case .longContent: "doc.text"
        case .loading: "arrow.trianglehead.2.counterclockwise"
        }
    }

    private var iconColor: Color {
        switch state {
        case .default: DesignSystem.Color.accent
        case .longContent: DesignSystem.Color.primary
        case .loading: DesignSystem.Color.secondary
        }
    }
}
