import SwiftUI

// MARK: - FocusedValues entries
extension FocusedValues {
    @Entry var documentTitle: Binding<String>?
    @Entry var isEditing: Binding<Bool>?
    @Entry var zoomLevel: Binding<Double>?
}

struct FocusedBindingShowcase: View {
    @State private var keyPathOption: KeyPathOption = .documentTitle
    @State private var publishingActive = true

    var body: some View {
        ShowcaseScreen(
            title: "@FocusedBinding",
            summary: "Reads a Binding from the focused view so commands can both read and write its value.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension FocusedBindingShowcase {
    fileprivate enum KeyPathOption: ShowcasePickable {
        case documentTitle
        case isEditing
        case zoomLevel

        var label: String {
            switch self {
            case .documentTitle: "\\.documentTitle"
            case .isEditing: "\\.isEditing"
            case .zoomLevel: "\\.zoomLevel"
            }
        }

        var keyPathString: String {
            switch self {
            case .documentTitle: "\\.documentTitle"
            case .isEditing: "\\.isEditing"
            case .zoomLevel: "\\.zoomLevel"
            }
        }
    }

    fileprivate enum FocusedBindingState: ShowcaseState {
        case `default`
        case empty

        var caption: String {
            switch self {
            case .default: "Binding present"
            case .empty: "No focused publisher"
            }
        }
    }
}

// MARK: - Sub-views
private extension FocusedBindingShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            publisherSection
            readerSection(isActive: publishingActive)
        }
        .frame(maxWidth: 360)
    }

    var publisherSection: some View {
        FocusedBindingPublisher(
            keyPathOption: keyPathOption,
            isActive: publishingActive,
        )
    }

    func readerSection(isActive: Bool) -> some View {
        FocusedBindingReader(
            keyPathOption: keyPathOption,
            hasPublisher: isActive,
        )
    }

    @ViewBuilder var controls: some View {
        ShowcasePicker("Key path", selection: $keyPathOption)
        ShowcaseToggle("Publishing active", isOn: $publishingActive)
    }

    @ViewBuilder func stateView(_ state: FocusedBindingState) -> some View {
        switch state {
        case .default:
            stateCard(
                icon: "dot.radiowaves.up.forward",
                label: "Binding present",
                detail: "@FocusedBinding reads & writes the focused view's value.",
                accent: true,
            )
        case .empty:
            stateCard(
                icon: "slash.circle",
                label: "No publisher",
                detail: "@FocusedBinding is nil — no focused view has published the key.",
                accent: false,
            )
        }
    }

    func stateCard(icon: String, label: String, detail: String, accent: Bool) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
            Image(systemName: icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(accent ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                .frame(width: DesignSystem.Size.Icon.medium, height: DesignSystem.Size.Icon.medium)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text(label)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(detail)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Code generation
private extension FocusedBindingShowcase {
    var generatedCode: String {
        let keyPathRef = keyPathOption.keyPathString
        return """
        // 1. Declare the FocusedValues entry (once per app):
        extension FocusedValues {
            @Entry var documentTitle: Binding<String>?
        }

        // 2. Publisher view — publishes its binding into the focused scene:
        struct DocumentView: View {
            @State private var title = "Untitled"

            var body: some View {
                TextField("Title", text: $title)
                    .focusedSceneValue(\(keyPathRef), $title)
            }
        }

        // 3. Reader — a command view that can both read and mutate:
        struct TitleCommand: View {
            @FocusedBinding(\(keyPathRef)) private var title

            var body: some View {
                TextField("Title", text: Binding($title) ?? .constant(""))
                    .disabled(title == nil)
            }
        }
        """
    }
}

// MARK: - Publisher demo view
private struct FocusedBindingPublisher: View {
    let keyPathOption: FocusedBindingShowcase.KeyPathOption
    let isActive: Bool
    @State private var titleValue = "Untitled"
    @State private var editingValue = true
    @State private var zoomValue = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            publisherLabel
            publisherControl
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(isActive ? DesignSystem.Color.accent : DesignSystem.Color.separator, lineWidth: 1),
        )
        .focusedSceneValueModifier(
            option: keyPathOption,
            isActive: isActive,
            titleValue: $titleValue,
            editingValue: $editingValue,
            zoomValue: $zoomValue,
        )
    }
}

// MARK: - Publisher sub-views
private extension FocusedBindingPublisher {
    var publisherLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: isActive ? "dot.radiowaves.up.forward" : "dot.radiowaves.up.forward")
                .foregroundStyle(isActive ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                .font(DesignSystem.Font.caption)
            Text(isActive ? "Publisher (active)" : "Publisher (inactive)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder var publisherControl: some View {
        switch keyPathOption {
        case .documentTitle:
#if os(tvOS)
            Text("Title: \(titleValue)")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
#else
            TextField("Document title", text: $titleValue)
                .textFieldStyle(.roundedBorder)
                .font(DesignSystem.Font.body)
#endif
        case .isEditing:
            Toggle("Is editing", isOn: $editingValue)
                .font(DesignSystem.Font.body)
        case .zoomLevel:
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                Text("Zoom: \(zoomValue, specifier: "%.1f")x")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
#if os(tvOS)
                Text("\(zoomValue, specifier: "%.1f")x")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.primary)
#else
                Slider(value: $zoomValue, in: 0.5...3.0, step: 0.1)
#endif
            }
        }
    }
}

// MARK: - focusedSceneValue helper
private extension View {
    @ViewBuilder func focusedSceneValueModifier(
        option: FocusedBindingShowcase.KeyPathOption,
        isActive: Bool,
        titleValue: Binding<String>,
        editingValue: Binding<Bool>,
        zoomValue: Binding<Double>
    ) -> some View {
        if isActive {
            switch option {
            case .documentTitle:
                self.focusedSceneValue(\.documentTitle, titleValue)
            case .isEditing:
                self.focusedSceneValue(\.isEditing, editingValue)
            case .zoomLevel:
                self.focusedSceneValue(\.zoomLevel, zoomValue)
            }
        } else {
            self
        }
    }
}

// MARK: - Reader demo view
private struct FocusedBindingReader: View {
    let keyPathOption: FocusedBindingShowcase.KeyPathOption
    let hasPublisher: Bool

    @FocusedBinding(\.documentTitle) private var titleBinding
    @FocusedBinding(\.isEditing) private var editingBinding
    @FocusedBinding(\.zoomLevel) private var zoomBinding

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            readerLabel
            readerContent
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Reader sub-views
private extension FocusedBindingReader {
    var readerLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xSmall) {
            Image(systemName: "arrow.down.circle")
                .foregroundStyle(DesignSystem.Color.secondary)
                .font(DesignSystem.Font.caption)
            Text("@FocusedBinding reader")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.secondary)
        }
    }

    @ViewBuilder var readerContent: some View {
        switch keyPathOption {
        case .documentTitle:
            titleReaderControl
        case .isEditing:
            editingReaderControl
        case .zoomLevel:
            zoomReaderControl
        }
    }

    var titleReaderControl: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
#if os(tvOS)
            Text(titleBinding ?? "")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
#else
            TextField("Title", text: Binding($titleBinding) ?? .constant(""))
                .textFieldStyle(.roundedBorder)
                .font(DesignSystem.Font.body)
                .disabled(titleBinding == nil)
#endif
            nilBadge(isNil: titleBinding == nil)
        }
    }

    var editingReaderControl: some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Toggle(
                "Is editing",
                isOn: Binding($editingBinding) ?? .constant(false),
            )
            .font(DesignSystem.Font.body)
            .disabled(editingBinding == nil)
            nilBadge(isNil: editingBinding == nil)
        }
    }

    var zoomReaderControl: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
            HStack {
                Text(zoomBinding.map { String(format: "%.1fx", $0) } ?? "nil")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
                nilBadge(isNil: zoomBinding == nil)
            }
#if os(tvOS)
            Text(zoomBinding.map { String(format: "%.1fx", $0) } ?? "—")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.primary)
#else
            Slider(
                value: Binding($zoomBinding) ?? .constant(1.0),
                in: 0.5...3.0,
                step: 0.1,
            )
            .disabled(zoomBinding == nil)
#endif
        }
    }

    func nilBadge(isNil: Bool) -> some View {
        Text(isNil ? "nil" : "bound")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(isNil ? DesignSystem.Color.secondary : DesignSystem.Color.accent)
            .padding(.horizontal, DesignSystem.Spacing.xSmall)
            .padding(.vertical, DesignSystem.Spacing.hairline)
            .background(
                Capsule().fill(
                    isNil
                        ? DesignSystem.Color.separator
                        : DesignSystem.Color.accent.opacity(0.15)
                ),
            )
    }
}
