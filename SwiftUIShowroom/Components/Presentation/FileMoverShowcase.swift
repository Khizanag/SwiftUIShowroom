import SwiftUI

struct FileMoverShowcase: View {
    @State private var isPresented = false
    @State private var fileOption: FileOption = .sample
    @State private var lastResult: MoveResult = .none

    var body: some View {
        ShowcaseScreen(
            title: "File Mover",
            summary: "Presents the document picker to move an existing file URL to a new location.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension FileMoverShowcase {
    var preview: some View {
        FileMoverPreview(
            isPresented: $isPresented,
            fileURL: fileOption.url,
            lastResult: $lastResult,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseToggle("isPresented", isOn: $isPresented)
        ShowcasePicker("file", selection: $fileOption)
    }

    @ViewBuilder
    func stateView(_ state: FileMoverState) -> some View {
        switch state {
        case .ready:
            Label("Move File…", systemImage: "folder.badge.plus")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.accent)
        case .error:
            Label("Move failed", systemImage: "xmark.circle.fill")
                .font(DesignSystem.Font.body)
                .foregroundStyle(.red)
        }
    }
}

// MARK: - Code generation
private extension FileMoverShowcase {
    var generatedCode: String {
        """
        .fileMover(isPresented: $isPresented, file: \(fileOption.label)) { result in
            switch result {
            case .success(let url): handleMoved(url)
            case .failure(let error): handleError(error)
            }
        }
        """
    }
}

// MARK: - Nested types
extension FileMoverShowcase {
    enum FileOption: ShowcasePickable {
        case sample
        case noFile

        var label: String {
            switch self {
            case .sample: "sampleFileURL"
            case .noFile: "nil"
            }
        }

        var url: URL? {
            switch self {
            case .sample:
                FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            case .noFile:
                nil
            }
        }
    }

    enum FileMoverState: ShowcaseState {
        case ready
        case error

        var caption: String {
            switch self {
            case .ready: "Ready"
            case .error: "Error"
            }
        }
    }

    enum MoveResult {
        case none, success, failure
    }
}

// MARK: - Platform view
private struct FileMoverPreview: View {
    @Binding var isPresented: Bool
    let fileURL: URL?
    @Binding var lastResult: FileMoverShowcase.MoveResult

    var body: some View {
#if os(tvOS)
        content
#else
        content
            .fileMover(isPresented: $isPresented, file: fileURL) { result in
                switch result {
                case .success:
                    lastResult = .success
                case .failure:
                    lastResult = .failure
                }
            }
#endif
    }

    private var content: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            resultBadge
            Button {
                lastResult = .none
                isPresented = true
            } label: {
                Label("Move File…", systemImage: "folder.badge.plus")
            }
            .buttonStyle(.borderedProminent)
            .disabled(fileURL == nil)
        }
    }

    @ViewBuilder
    private var resultBadge: some View {
        switch lastResult {
        case .none:
            EmptyView()
        case .success:
            Label("Moved successfully", systemImage: "checkmark.circle.fill")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(.green)
        case .failure:
            Label("Move failed", systemImage: "xmark.circle.fill")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(.red)
        }
    }
}
