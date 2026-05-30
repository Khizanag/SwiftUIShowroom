import SwiftUI

struct ControlGroupShowcase: View {
    @State private var labelText = "Format"
    @State private var groupStyle: GroupStyleOption = .automatic
    @State private var groupSize: GroupSizeOption = .regular
    @State private var tint: Color = .accentColor
    @State private var isEnabled = true

    var body: some View {
        ShowcaseScreen(
            title: "ControlGroup",
            summary: "A container that clusters related controls in a context-appropriate layout.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension ControlGroupShowcase {
    var preview: some View {
        styledGroup(label: labelText, isEnabled: isEnabled)
    }

    @ViewBuilder
    func styledGroup(label: String, isEnabled: Bool) -> some View {
        let group = baseGroup(label: label)
            .controlSize(groupSize.controlSize)
            .tint(tint)
            .disabled(!isEnabled)
        applyStyle(to: group)
    }

    @ViewBuilder
    func baseGroup(label: String) -> some View {
        ControlGroup {
            Button("Bold", systemImage: "bold") {}
            Button("Italic", systemImage: "italic") {}
            Button("Underline", systemImage: "underline") {}
        } label: {
            Label(label, systemImage: "textformat")
        }
    }

    @ViewBuilder
    func applyStyle(to group: some View) -> some View {
        switch groupStyle {
        case .automatic:
            group.controlGroupStyle(.automatic)
        case .navigation:
            group.controlGroupStyle(.navigation)
        case .palette:
            #if os(tvOS)
            group.controlGroupStyle(.automatic)
            #else
            group.controlGroupStyle(.palette)
            #endif
        case .menu:
            group.controlGroupStyle(.menu)
        case .compactMenu:
            #if os(tvOS)
            group.controlGroupStyle(.automatic)
            #else
            group.controlGroupStyle(.compactMenu)
            #endif
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcasePicker("Style", selection: $groupStyle)
        ShowcasePicker("Control size", selection: $groupSize)
        ShowcaseColorControl("Tint", selection: $tint, supportsOpacity: false)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: ControlGroupState) -> some View {
        switch state {
        case .enabled:
            baseGroup(label: "Format")
                .controlSize(.regular)
                .tint(.accentColor)
                .controlGroupStyle(.automatic)
        case .disabled:
            baseGroup(label: "Format")
                .controlSize(.regular)
                .tint(.accentColor)
                .controlGroupStyle(.automatic)
                .disabled(true)
        case .longContent:
            longContentGroup
        }
    }

    var longContentGroup: some View {
        ControlGroup {
            Button("Bold", systemImage: "bold") {}
            Button("Italic", systemImage: "italic") {}
            Button("Underline", systemImage: "underline") {}
            Button("Strikethrough", systemImage: "strikethrough") {}
            Button("Link", systemImage: "link") {}
        } label: {
            Label("Text", systemImage: "textformat")
        }
        .controlGroupStyle(.automatic)
        .controlSize(.regular)
    }
}

// MARK: - Code generation
private extension ControlGroupShowcase {
    var generatedCode: String {
        """
        ControlGroup {
            Button("Bold", systemImage: "bold") { }
            Button("Italic", systemImage: "italic") { }
            Button("Underline", systemImage: "underline") { }
        } label: {
            Label("\(labelText)", systemImage: "textformat")
        }
        .controlGroupStyle(\(groupStyle.code))
        .controlSize(\(groupSize.code))
        .tint(\(tintCode))
        .disabled(\(!isEnabled))
        """
    }

    var tintCode: String {
        tint == .accentColor ? ".accentColor" : "Color(/* custom */)"
    }
}

// MARK: - Nested types
extension ControlGroupShowcase {
    fileprivate enum GroupStyleOption: ShowcasePickable {
        case automatic, navigation, palette, menu, compactMenu

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .navigation: "navigation"
            case .palette: "palette"
            case .menu: "menu"
            case .compactMenu: "compactMenu"
            }
        }

        var code: String { ".\(label)" }
    }

    fileprivate enum GroupSizeOption: ShowcasePickable {
        case mini, small, regular, large, extraLarge

        var label: String {
            switch self {
            case .mini: "mini"
            case .small: "small"
            case .regular: "regular"
            case .large: "large"
            case .extraLarge: "extraLarge"
            }
        }

        var code: String { ".\(label)" }

        var controlSize: ControlSize {
            switch self {
            case .mini: .mini
            case .small: .small
            case .regular: .regular
            case .large: .large
            case .extraLarge: .extraLarge
            }
        }
    }

    fileprivate enum ControlGroupState: ShowcaseState {
        case enabled, disabled, longContent

        var caption: String {
            switch self {
            case .enabled: "Enabled"
            case .disabled: "Disabled"
            case .longContent: "Long content"
            }
        }
    }
}
