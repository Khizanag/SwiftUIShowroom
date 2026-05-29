import SwiftUI

struct PickerShowcase: View {
    @State private var selection: SampleFruit = .apple
    @State private var style: PickerStyleOption = .menu
    @State private var labelText = "Fruit"

    var body: some View {
        ShowcaseScreen(
            title: "Picker",
            summary: "Selects one value from a set — switch between every native picker style.",
        ) {
            PreviewStage {
                styled(picker)
                    .frame(maxWidth: 360)
            }
            ShowcaseSection("Configuration") {
                controls
            }
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
private extension PickerShowcase {
    var picker: some View {
        Picker(labelText, selection: $selection) {
            ForEach(SampleFruit.allCases) { fruit in
                Text(fruit.label).tag(fruit)
            }
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcasePicker("Style", selection: $style)
    }

    @ViewBuilder
    func styled(_ picker: some View) -> some View {
        switch style {
        case .automatic: picker.pickerStyle(.automatic)
        case .menu: picker.pickerStyle(.menu)
        case .inline: picker.pickerStyle(.inline)
        case .segmented:
            #if os(iOS) || os(macOS) || os(tvOS)
            picker.pickerStyle(.segmented)
            #else
            picker.pickerStyle(.automatic)
            #endif
        case .wheel:
            #if os(iOS) || os(watchOS)
            picker.pickerStyle(.wheel)
            #else
            picker.pickerStyle(.automatic)
            #endif
        case .palette:
            #if !os(tvOS)
            picker.pickerStyle(.palette)
            #else
            picker.pickerStyle(.automatic)
            #endif
        case .navigationLink:
            #if !os(macOS)
            picker.pickerStyle(.navigationLink)
            #else
            picker.pickerStyle(.automatic)
            #endif
        }
    }

    @ViewBuilder
    func stateView(_ state: EnabledState) -> some View {
        styled(picker)
            .disabled(state == .disabled)
    }
}

// MARK: - Configuration options
enum PickerStyleOption: ShowcasePickable {
    case automatic, menu, inline, segmented, wheel, palette, navigationLink

    var label: String {
        switch self {
        case .automatic: "automatic"
        case .menu: "menu"
        case .inline: "inline"
        case .segmented: "segmented"
        case .wheel: "wheel"
        case .palette: "palette"
        case .navigationLink: "navigationLink"
        }
    }

    var code: String { ".\(label)" }
}

enum SampleFruit: String, CaseIterable, Identifiable {
    case apple, banana, cherry, mango

    var id: String { rawValue }

    var label: String { rawValue.capitalized }
}

// MARK: - Code generation
private extension PickerShowcase {
    var generatedCode: String {
        """
        Picker("\(labelText)", selection: $selection) {
            ForEach(SampleFruit.allCases) { fruit in
                Text(fruit.label).tag(fruit)
            }
        }
        .pickerStyle(\(style.code))
        """
    }
}
