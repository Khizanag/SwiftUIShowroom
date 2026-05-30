import SwiftUI
import UniformTypeIdentifiers

struct FileImporterShowcase: View {
    @State private var isPresented = false
    @State private var allowedType: AllowedTypeOption = .item
    @State private var allowsMultipleSelection = false
    @State private var importResult: ImportResultState = .idle

    var body: some View {
        ShowcaseScreen(
            title: "File Importer",
            summary: "Opens the system document picker to import one or more files of allowed UTTypes.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
        #if !os(tvOS)
        .fileImporter(
            isPresented: $isPresented,
            allowedContentTypes: [allowedType.utType],
            allowsMultipleSelection: allowsMultipleSelection,
        ) { result in
            switch result {
            case .success(let urls):
                importResult = .success(urls)
            case .failure(let error):
                importResult = .failure(error.localizedDescription)
            }
        }
        #endif
    }
}

// MARK: - Nested types
extension FileImporterShowcase {
    enum AllowedTypeOption: ShowcasePickable {
        case item, pdf, image, plainText, json, audio, movie, folder

        var label: String {
            switch self {
            case .item: ".item"
            case .pdf: ".pdf"
            case .image: ".image"
            case .plainText: ".plainText"
            case .json: ".json"
            case .audio: ".audio"
            case .movie: ".movie"
            case .folder: ".folder"
            }
        }

        var utType: UTType {
            switch self {
            case .item: .item
            case .pdf: .pdf
            case .image: .image
            case .plainText: .plainText
            case .json: .json
            case .audio: .audio
            case .movie: .movie
            case .folder: .folder
            }
        }

        var codeToken: String { label }
    }

    enum ImportResultState {
        case idle
        case success([URL])
        case failure(String)
    }

    enum ImportState: ShowcaseState {
        case ready
        case selected
        case error

        var caption: String {
            switch self {
            case .ready: "Default"
            case .selected: "File selected"
            case .error: "Error"
            }
        }
    }
}

// MARK: - Sub-views
private extension FileImporterShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            triggerButton
            resultLabel
        }
        .frame(maxWidth: .infinity)
    }

    var triggerButton: some View {
        Button {
            #if !os(tvOS)
            importResult = .idle
            isPresented = true
            #endif
        } label: {
            Label("Import File", systemImage: "folder.badge.plus")
        }
        .buttonStyle(.borderedProminent)
        #if os(tvOS)
        .disabled(true)
        #endif
    }

    @ViewBuilder
    var resultLabel: some View {
        switch importResult {
        case .idle:
            Text("No file selected")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.secondary)
        case .success(let urls):
            let names = urls.map(\.lastPathComponent).joined(separator: ", ")
            Text("Imported: \(names)")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.primary)
                .lineLimit(2)
        case .failure(let message):
            Text("Error: \(message)")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(.red)
                .lineLimit(2)
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Allowed type", selection: $allowedType)
        ShowcaseToggle("Allow multiple selection", isOn: $allowsMultipleSelection)
        #if os(tvOS)
        Text("fileImporter is not available on tvOS.")
            .font(DesignSystem.Font.footnote)
            .foregroundStyle(DesignSystem.Color.secondary)
        #endif
    }

    @ViewBuilder
    func stateView(_ state: ImportState) -> some View {
        switch state {
        case .ready:
            stateCard(
                icon: "folder.badge.plus",
                label: "Tap to import",
                color: DesignSystem.Color.accent,
            )
        case .selected:
            stateCard(
                icon: "doc.fill",
                label: "No files selected",
                color: DesignSystem.Color.secondary,
            )
        case .error:
            stateCard(
                icon: "exclamationmark.triangle.fill",
                label: "Import failed",
                color: .red,
            )
        }
    }

    func stateCard(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(color)
            Text(label)
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
private extension FileImporterShowcase {
    var generatedCode: String {
        let multipleArg = allowsMultipleSelection ? "true" : "false"
        var lines: [String] = []
        lines.append(".fileImporter(")
        lines.append("    isPresented: $isPresented,")
        lines.append("    allowedContentTypes: [\(allowedType.codeToken)],")
        lines.append("    allowsMultipleSelection: \(multipleArg)")
        lines.append(") { result in")
        lines.append("    switch result {")
        lines.append("    case .success(let urls): handleImport(urls)")
        lines.append("    case .failure(let error): handleError(error)")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}
