import SwiftUI
#if canImport(QuickLook)
import QuickLook
#endif

struct QuickLookPreviewShowcase: View {
    @State private var selectedItem: ItemOption = .none

    var body: some View {
        ShowcaseScreen(
            title: "Quick Look Preview",
            summary: "Presents a system Quick Look preview of a file URL, dismissing when the URL becomes nil.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension QuickLookPreviewShowcase {
    enum ItemOption: ShowcasePickable {
        case none
        case samplePDF
        case sampleImage

        var label: String {
            switch self {
            case .none: "nil"
            case .samplePDF: "samplePDFURL"
            case .sampleImage: "sampleImageURL"
            }
        }

        var codeToken: String {
            switch self {
            case .none: "nil"
            case .samplePDF: "$previewURL /* PDF */"
            case .sampleImage: "$previewURL /* Image */"
            }
        }
    }

    enum PreviewDisplayState: ShowcaseState {
        case defaultState
        case empty

        var caption: String {
            switch self {
            case .defaultState: "Default (URL set)"
            case .empty: "Empty (nil URL)"
            }
        }
    }
}

// MARK: - Sub-views
private extension QuickLookPreviewShowcase {
    var preview: some View {
        #if os(tvOS)
        tvFallbackPreview
        #else
        livePreview
        #endif
    }

    #if os(tvOS)
    var tvFallbackPreview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: "eye.fill")
                .font(DesignSystem.Font.largeTitle)
                .foregroundStyle(DesignSystem.Color.secondary)
            Text("Quick Look Preview is not available on tvOS.")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.large)
    }
    #else
    var livePreview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            Button {
                selectedItem = .samplePDF
            } label: {
                Label("Preview PDF", systemImage: "doc.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedItem == .samplePDF)

            Button {
                selectedItem = .sampleImage
            } label: {
                Label("Preview Image", systemImage: "photo.fill")
            }
            .buttonStyle(.bordered)
            .disabled(selectedItem == .sampleImage)

            activeItemLabel
        }
        #if os(iOS) || os(macOS)
        .quickLookPreview(previewURLBinding)
        #endif
    }

    var activeItemLabel: some View {
        Text(selectedItem == .none ? "No item selected" : "Presenting: \(selectedItem.label)")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    var previewURLBinding: Binding<URL?> {
        Binding(
            get: { selectedItem.url },
            set: { newValue in
                if newValue == nil {
                    selectedItem = .none
                }
            },
        )
    }
    #endif

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Item", selection: $selectedItem)
        #if os(tvOS)
        Text("quickLookPreview is not available on tvOS.")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
        #endif
    }

    @ViewBuilder
    func stateView(_ state: PreviewDisplayState) -> some View {
        switch state {
        case .defaultState:
            stateCard(
                icon: "doc.richtext.fill",
                label: "URL provided",
                description: "Quick Look sheet is presented",
                color: DesignSystem.Color.accent,
            )
        case .empty:
            stateCard(
                icon: "doc.fill",
                label: "nil URL",
                description: "No presentation; Quick Look is dismissed",
                color: DesignSystem.Color.secondary,
            )
        }
    }

    func stateCard(
        icon: String,
        label: String,
        description: String,
        color: Color,
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(color)
            Text(label)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.primary)
            Text(description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension QuickLookPreviewShowcase {
    var generatedCode: String {
        let token = selectedItem.codeToken
        return [
            "SomeView()",
            "    .quickLookPreview(\(token))",
        ].joined(separator: "\n")
    }
}

// MARK: - ItemOption URL resolution
private extension QuickLookPreviewShowcase.ItemOption {
    var url: URL? {
        switch self {
        case .none:
            return nil
        case .samplePDF:
            return Self.bundledPDF ?? Self.generatedPDF
        case .sampleImage:
            return Self.bundledImage ?? Self.generatedPNG
        }
    }

    static var bundledPDF: URL? {
        Bundle.main.url(forResource: "sample", withExtension: "pdf")
    }

    static var bundledImage: URL? {
        let extensions = ["png", "jpg", "jpeg"]
        return extensions.lazy.compactMap {
            Bundle.main.url(forResource: "sample", withExtension: $0)
        }.first
    }

    static var generatedPDF: URL? {
        let destination = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("qlshowroom_sample.pdf")
        guard !FileManager.default.fileExists(atPath: destination.path) else {
            return destination
        }
        let content = pdfBytes()
        try? content.write(to: destination)
        return FileManager.default.fileExists(atPath: destination.path) ? destination : nil
    }

    static var generatedPNG: URL? {
        let destination = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("qlshowroom_sample.png")
        guard !FileManager.default.fileExists(atPath: destination.path) else {
            return destination
        }
        let pngData = minimalPNGData()
        try? pngData.write(to: destination)
        return FileManager.default.fileExists(atPath: destination.path) ? destination : nil
    }

    static func pdfBytes() -> Data {
        let header = "%PDF-1.4\n"
        let obj1 = "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n"
        let obj2 = "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n"
        let obj3 = "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] >>\nendobj\n"
        let xref = "xref\n0 4\n0000000000 65535 f \n0000000009 00000 n \n0000000068 00000 n \n0000000125 00000 n \n"
        let trailer = "trailer\n<< /Size 4 /Root 1 0 R >>\nstartxref\n200\n%%EOF"
        let raw = header + obj1 + obj2 + obj3 + xref + trailer
        return Data(raw.utf8)
    }

    static func minimalPNGData() -> Data {
        let bytes: [UInt8] = [
            0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
            0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
            0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
            0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
            0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
            0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
            0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
            0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
            0x44, 0xAE, 0x42, 0x60, 0x82,
        ]
        return Data(bytes)
    }
}
