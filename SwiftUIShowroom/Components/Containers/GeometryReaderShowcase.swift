import SwiftUI

struct GeometryReaderShowcase: View {
    @State private var coordinateSpace: CoordinateSpaceOption = .local
    @State private var readsSafeArea: Bool = true

    var body: some View {
        ShowcaseScreen(
            title: "GeometryReader",
            summary: "Exposes a GeometryProxy for reading size, safe-area insets, and frames.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
private extension GeometryReaderShowcase {
    enum CoordinateSpaceOption: ShowcasePickable {
        case local
        case global
        case named

        var label: String {
            switch self {
            case .local: "local"
            case .global: "global"
            case .named: "named"
            }
        }

        var codeValue: String {
            switch self {
            case .local: ".local"
            case .global: ".global"
            case .named: ".named(\"stage\")"
            }
        }
    }

    enum GeometryState: ShowcaseState {
        case `default`
        case longContent

        var caption: String {
            switch self {
            case .default: "Default"
            case .longContent: "Long content"
            }
        }
    }
}

// MARK: - Sub-views
private extension GeometryReaderShowcase {
    var preview: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            stageReader()
        }
        .coordinateSpace(name: "stage")
        .frame(maxWidth: .infinity)
    }

    func stageReader() -> some View {
        GeometryReader { proxy in
            infoCard(proxy: proxy)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 140)
    }

    func infoCard(proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            sizeRow(proxy: proxy)
            frameRow(proxy: proxy)
            if readsSafeArea {
                insetRow(proxy: proxy)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.medium),
        )
    }

    func sizeRow(proxy: GeometryProxy) -> some View {
        infoLabel(
            icon: "arrow.left.and.right",
            title: "Size",
            value: "w \(Int(proxy.size.width))  h \(Int(proxy.size.height))",
        )
    }

    func frameRow(proxy: GeometryProxy) -> some View {
        let rect = frameRect(proxy: proxy)
        return infoLabel(
            icon: "square.dashed",
            title: "frame(\(coordinateSpace.label))",
            value: "x \(Int(rect.minX))  y \(Int(rect.minY))",
        )
    }

    func insetRow(proxy: GeometryProxy) -> some View {
        infoLabel(
            icon: "square.bottomhalf.filled",
            title: "safeAreaInsets.bottom",
            value: "\(Int(proxy.safeAreaInsets.bottom)) pt",
        )
    }

    func frameRect(proxy: GeometryProxy) -> CGRect {
        switch coordinateSpace {
        case .local:
            proxy.frame(in: .local)
        case .global:
            proxy.frame(in: .global)
        case .named:
            proxy.frame(in: .named("stage"))
        }
    }

    func infoLabel(icon: String, title: String, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: icon)
                .frame(width: DesignSystem.Size.Icon.small, height: DesignSystem.Size.Icon.small)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(title)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
            Spacer()
            Text(value)
                .font(DesignSystem.Font.code)
                .foregroundStyle(DesignSystem.Color.primary)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Coordinate space", selection: $coordinateSpace)
        ShowcaseToggle("Show safe-area insets", isOn: $readsSafeArea)
    }

    @ViewBuilder
    func stateView(_ state: GeometryState) -> some View {
        GeometryReader { proxy in
            galleryCard(proxy: proxy, state: state)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: state == .longContent ? 160 : 110)
    }

    func galleryCard(proxy: GeometryProxy, state: GeometryState) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            HStack {
                Text("GeometryReader")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Spacer()
            }
            Text("w \(Int(proxy.size.width))  h \(Int(proxy.size.height))")
                .font(DesignSystem.Font.code)
                .foregroundStyle(DesignSystem.Color.primary)
            if state == .longContent {
                Text("frame: x \(Int(proxy.frame(in: .local).minX))  y \(Int(proxy.frame(in: .local).minY))")
                    .font(DesignSystem.Font.code)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text("safeArea.bottom: \(Int(proxy.safeAreaInsets.bottom)) pt")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.small)
        .background(
            DesignSystem.Color.cardBackground,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.small),
        )
    }
}

// MARK: - Code generation
private extension GeometryReaderShowcase {
    var generatedCode: String {
        var lines: [String] = [
            "GeometryReader { proxy in",
            "    Color.accentColor",
            "        .overlay(",
            "            Text(\"w: \\(Int(proxy.size.width)) h: \\(Int(proxy.size.height))\")",
            "        )",
            "        .frame(width: proxy.size.width, height: proxy.size.height)",
        ]
        if coordinateSpace == .named {
            lines.append("        // Read frame in named ancestor space")
            lines.append("        let rect = proxy.frame(in: .named(\"stage\"))")
        } else {
            lines.append("        let frame = proxy.frame(in: \(coordinateSpace.codeValue))")
        }
        if readsSafeArea {
            lines.append("        let insets = proxy.safeAreaInsets")
        }
        lines.append("}")
        if coordinateSpace == .named {
            lines.append(".coordinateSpace(name: \"stage\")")
        }
        return lines.joined(separator: "\n")
    }
}
