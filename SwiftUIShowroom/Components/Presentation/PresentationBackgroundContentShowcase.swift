import SwiftUI

struct PresentationBackgroundContentShowcase: View {
    @State private var isPresented = false
    @State private var alignmentOption: AlignmentOption = .center
    @State private var backgroundContent: BackgroundContentOption = .linearGradient
    @State private var startColor: Color = .accentColor
    @State private var endColor: Color = .purple

    var body: some View {
        ShowcaseScreen(
            title: "Custom Presentation Background",
            summary: "Places a custom view behind a sheet or popover via presentationBackground(alignment:content:).",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension PresentationBackgroundContentShowcase {
    var preview: some View {
        Button {
            isPresented = true
        } label: {
            Label("Present Sheet", systemImage: "rectangle.on.rectangle")
        }
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $isPresented) {
            sheetContent
                .presentationBackground(alignment: alignmentOption.value) {
                    backgroundView(
                        content: backgroundContent,
                        startColor: startColor,
                        endColor: endColor,
                    )
                }
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Alignment", selection: $alignmentOption)
        ShowcasePicker("Background content", selection: $backgroundContent)
        if backgroundContent == .linearGradient || backgroundContent == .radialGradient {
            ShowcaseColorControl("Start color", selection: $startColor, supportsOpacity: false)
            ShowcaseColorControl("End color", selection: $endColor, supportsOpacity: false)
        }
    }

    @ViewBuilder
    func stateView(_ state: BackgroundContentState) -> some View {
        stateCard(
            icon: state.icon,
            title: state.caption,
            description: state.description,
        )
    }

    var sheetContent: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: "paintpalette.fill")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                Text("Custom Background")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                Text("The background behind this content is set via presentationBackground(alignment:content:).")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(DesignSystem.Spacing.large)
            .navigationTitle("Sheet")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: dismissPlacement) {
                    SheetDismissButton()
                }
            }
        }
    }

    var dismissPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .automatic
        #else
        .cancellationAction
        #endif
    }

    func stateCard(icon: String, title: String, description: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(title)
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Background view builder
private extension PresentationBackgroundContentShowcase {
    @ViewBuilder
    func backgroundView(
        content: BackgroundContentOption,
        startColor: Color,
        endColor: Color,
    ) -> some View {
        switch content {
        case .linearGradient:
            LinearGradient(
                colors: [startColor, endColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing,
            )
            .ignoresSafeArea()
        case .radialGradient:
            RadialGradient(
                colors: [startColor, endColor],
                center: .center,
                startRadius: 0,
                endRadius: 300,
            )
            .ignoresSafeArea()
        case .image:
            ZStack {
                Color(white: 0.12)
                Image(systemName: "star.fill")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(.white.opacity(0.06))
            }
            .ignoresSafeArea()
        case .solidColor:
            DesignSystem.Color.accent
                .opacity(0.25)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Code generation
private extension PresentationBackgroundContentShowcase {
    var generatedCode: String {
        var lines = [
            ".sheet(isPresented: $isPresented) {",
            "    SheetContentView()",
            "        .presentationBackground(alignment: .\(alignmentOption.label)) {",
        ]
        switch backgroundContent {
        case .linearGradient:
            lines.append("            LinearGradient(")
            lines.append("                colors: [startColor, endColor],")
            lines.append("                startPoint: .topLeading,")
            lines.append("                endPoint: .bottomTrailing")
            lines.append("            )")
        case .radialGradient:
            lines.append("            RadialGradient(")
            lines.append("                colors: [startColor, endColor],")
            lines.append("                center: .center,")
            lines.append("                startRadius: 0,")
            lines.append("                endRadius: 300")
            lines.append("            )")
        case .image:
            lines.append("            Image(\"background\")")
            lines.append("                .resizable()")
            lines.append("                .scaledToFill()")
        case .solidColor:
            lines.append("            Color.accentColor.opacity(0.25)")
        }
        lines.append("        }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

// MARK: - Dismiss button
private struct SheetDismissButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button("Done") { dismiss() }
    }
}

// MARK: - Enums
extension PresentationBackgroundContentShowcase {
    enum AlignmentOption: ShowcasePickable {
        case center
        case top
        case bottom
        case leading
        case trailing
        case topLeading
        case bottomTrailing

        var label: String {
            switch self {
            case .center: "center"
            case .top: "top"
            case .bottom: "bottom"
            case .leading: "leading"
            case .trailing: "trailing"
            case .topLeading: "topLeading"
            case .bottomTrailing: "bottomTrailing"
            }
        }

        var value: Alignment {
            switch self {
            case .center: .center
            case .top: .top
            case .bottom: .bottom
            case .leading: .leading
            case .trailing: .trailing
            case .topLeading: .topLeading
            case .bottomTrailing: .bottomTrailing
            }
        }
    }

    enum BackgroundContentOption: ShowcasePickable {
        case linearGradient
        case radialGradient
        case image
        case solidColor

        var label: String {
            switch self {
            case .linearGradient: "LinearGradient"
            case .radialGradient: "RadialGradient"
            case .image: "Image"
            case .solidColor: "Color"
            }
        }
    }

    enum BackgroundContentState: ShowcaseState {
        case gradient
        case image
        case color

        var caption: String {
            switch self {
            case .gradient: "Gradient"
            case .image: "Image"
            case .color: "Solid Color"
            }
        }

        var icon: String {
            switch self {
            case .gradient: "paintpalette.fill"
            case .image: "photo.fill"
            case .color: "rectangle.fill"
            }
        }

        var description: String {
            switch self {
            case .gradient: "LinearGradient or RadialGradient as the backdrop"
            case .image: "Image (or ZStack with decorative symbols) behind content"
            case .color: "Flat color with reduced opacity behind content"
            }
        }
    }
}
