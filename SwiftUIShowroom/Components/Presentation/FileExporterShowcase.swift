import SwiftUI
import UniformTypeIdentifiers

struct FileExporterShowcase: View {
    @State private var isPresented = false
    @State private var contentType: ContentTypeOption = .plainText
    @State private var defaultFilename = "Export"
    @State private var filenameLabel = "File name"
    @State private var lastResult: ExportResult = .idle

    var body: some View {
        ShowcaseScreen(
            title: "File Exporter",
            summary: "Presents the system save dialog to export a FileDocument to a chosen location.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
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
private extension FileExporterShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            exportButton
            resultLabel
        }
    }

    @ViewBuilder
    var exportButton: some View {
        #if os(tvOS)
        unavailableNotice
        #else
        Button {
            isPresented = true
        } label: {
            Label("Export File", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.borderedProminent)
        .fileExporter(
            isPresented: $isPresented,
            document: PlainTextDocument(text: "SwiftUIShowroom export example."),
            contentType: contentType.utType,
            defaultFilename: defaultFilename.isEmpty ? nil : defaultFilename
        ) { result in
            switch result {
            case .success:
                lastResult = .success
            case .failure(let error):
                lastResult = .failure(error.localizedDescription)
            }
        }
        .modifier(FilenameLabelModifier(label: filenameLabel))
        #endif
    }

    var resultLabel: some View {
        Group {
            switch lastResult {
            case .idle:
                Text("No export attempted yet.")
                    .foregroundStyle(DesignSystem.Color.secondary)
            case .success:
                Label("Exported successfully.", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .failure(let message):
                Label(message, systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .font(DesignSystem.Font.footnote)
    }

    var unavailableNotice: some View {
        Text("fileExporter is not available on tvOS.")
            .font(DesignSystem.Font.callout)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Content type", selection: $contentType)
        ShowcaseTextControl("Default filename", text: $defaultFilename, prompt: "Export")
        ShowcaseTextControl("Filename label (iOS 17+ / macOS 14+)", text: $filenameLabel, prompt: "File name")
        ShowcaseToggle("Show dialog", isOn: $isPresented)
    }

    @ViewBuilder
    func stateView(_ state: ExporterState) -> some View {
        switch state {
        case .ready:
            Label("Ready to export", systemImage: "doc.badge.arrow.up")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
        case .exported:
            Label("Export successful", systemImage: "checkmark.circle.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(.green)
        case .failed:
            Label("Export failed", systemImage: "xmark.circle.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(.red)
        }
    }
}

// MARK: - Code generation
private extension FileExporterShowcase {
    var generatedCode: String {
        var lines = [
            ".fileExporter(",
            "    isPresented: $isPresented,",
            "    document: document,",
            "    contentType: \(contentType.code),",
            "    defaultFilename: \(defaultFilenameCode)",
            ") { result in",
            "    if case .failure(let error) = result { handleError(error) }",
            "}",
        ]
        if !filenameLabel.isEmpty {
            lines.append(".fileExporterFilenameLabel(\"\(filenameLabel)\")")
        }
        return lines.joined(separator: "\n")
    }

    var defaultFilenameCode: String {
        defaultFilename.isEmpty ? "nil" : "\"\(defaultFilename)\""
    }
}

// MARK: - Supporting types
private extension FileExporterShowcase {
    enum ContentTypeOption: ShowcasePickable {
        case plainText, pdf, json, png, csv

        var label: String {
            switch self {
            case .plainText: ".plainText"
            case .pdf: ".pdf"
            case .json: ".json"
            case .png: ".png"
            case .csv: ".commaSeparatedText"
            }
        }

        var code: String { label }

        var utType: UTType {
            switch self {
            case .plainText: .plainText
            case .pdf: .pdf
            case .json: .json
            case .png: .png
            case .csv: .commaSeparatedText
            }
        }
    }

    enum ExporterState: ShowcaseState {
        case ready, exported, failed

        var caption: String {
            switch self {
            case .ready: "Default"
            case .exported: "Exported"
            case .failed: "Error"
            }
        }
    }

    enum ExportResult {
        case idle
        case success
        case failure(String)
    }
}

// MARK: - FileDocument
#if !os(tvOS)
private struct PlainTextDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var text: String

    init(text: String) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard
            let data = configuration.file.regularFileContents,
            let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
#endif

// MARK: - FilenameLabelModifier
private struct FilenameLabelModifier: ViewModifier {
    let label: String

    func body(content: Content) -> some View {
        #if os(tvOS)
        content
        #else
        if #available(iOS 17.0, macOS 14.0, *) {
            content.fileExporterFilenameLabel(label)
        } else {
            content
        }
        #endif
    }
}
