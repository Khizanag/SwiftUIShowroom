import SwiftUI

struct MultidatepickerShowcase: View {
    @State private var selectedDates: Set<DateComponents> = Self.defaultDates
    @State private var titleText = "Dates Available"
    @State private var rangeMode: RangeModeOption = .unbounded
    @State private var isEnabled = true

    enum RangeModeOption: ShowcasePickable {
        case unbounded, range, from, upTo

        var label: String {
            switch self {
            case .unbounded: "Unbounded"
            case .range: "Half-open (a..<b)"
            case .from: "From (a...)"
            case .upTo: "Up to (..<b)"
            }
        }

        var codeSnippet: String {
            switch self {
            case .unbounded: ""
            case .range: "in: startDate..<endDate, "
            case .from: "in: startDate..., "
            case .upTo: "in: ..<endDate, "
            }
        }
    }

    enum MultidatePickerState: ShowcaseState {
        case empty, selected, disabled, restricted

        var caption: String {
            switch self {
            case .empty: "Empty"
            case .selected: "Selected"
            case .disabled: "Disabled"
            case .restricted: "Restricted range"
            }
        }
    }

    var body: some View {
        ShowcaseScreen(
            title: "MultiDatePicker",
            summary: "Calendar control for selecting multiple dates as a Set<DateComponents>.",
        ) {
            PreviewStage {
                preview
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
private extension MultidatepickerShowcase {
    var preview: some View {
        #if os(iOS)
        pickerView(selection: $selectedDates, isEnabled: isEnabled, rangeMode: rangeMode)
            .padding(DesignSystem.Spacing.small)
        #else
        platformUnavailableLabel
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label", text: $titleText)
        #if os(iOS)
        ShowcasePicker("Range", selection: $rangeMode)
        #endif
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: MultidatePickerState) -> some View {
        #if os(iOS)
        Group {
            switch state {
            case .empty:
                pickerView(
                    selection: .constant([]),
                    isEnabled: true,
                    rangeMode: .unbounded,
                )
            case .selected:
                pickerView(
                    selection: .constant(Self.defaultDates),
                    isEnabled: true,
                    rangeMode: .unbounded,
                )
            case .disabled:
                pickerView(
                    selection: .constant(Self.defaultDates),
                    isEnabled: false,
                    rangeMode: .unbounded,
                )
            case .restricted:
                pickerView(
                    selection: .constant(Self.defaultDates),
                    isEnabled: true,
                    rangeMode: .from,
                )
            }
        }
        .padding(DesignSystem.Spacing.xSmall)
        #else
        platformUnavailableLabel
            .frame(minHeight: 60)
        #endif
    }
}

// MARK: - Component builder
private extension MultidatepickerShowcase {
    #if os(iOS)
    @ViewBuilder
    func pickerView(
        selection: Binding<Set<DateComponents>>,
        isEnabled: Bool,
        rangeMode: RangeModeOption,
    ) -> some View {
        switch rangeMode {
        case .unbounded:
            MultiDatePicker(titleText, selection: selection)
                .disabled(!isEnabled)
        case .range:
            MultiDatePicker(
                titleText,
                selection: selection,
                in: Self.rangeStart ..< Self.rangeEnd,
            )
            .disabled(!isEnabled)
        case .from:
            MultiDatePicker(
                titleText,
                selection: selection,
                in: Self.rangeStart...,
            )
            .disabled(!isEnabled)
        case .upTo:
            MultiDatePicker(
                titleText,
                selection: selection,
                in: ..<Self.rangeEnd,
            )
            .disabled(!isEnabled)
        }
    }
    #endif

    var platformUnavailableLabel: some View {
        Label("Not available on this platform", systemImage: "xmark.circle")
            .foregroundStyle(DesignSystem.Color.secondary)
            .font(DesignSystem.Font.callout)
    }
}

// MARK: - Sample data
private extension MultidatepickerShowcase {
    static var defaultDates: Set<DateComponents> {
        let calendar = Calendar.current
        let today = Date()
        let days: [Int] = [2, 5, 9]
        return Set(days.compactMap { offset -> DateComponents? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else {
                return nil
            }
            return calendar.dateComponents([.year, .month, .day], from: date)
        })
    }

    static var rangeStart: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static var rangeEnd: Date {
        Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date()
    }
}

// MARK: - Code generation
private extension MultidatepickerShowcase {
    var generatedCode: String {
        let inArg = rangeMode.codeSnippet
        let disabledLine = isEnabled ? "" : "\n    .disabled(true)"
        if inArg.isEmpty {
            return """
            MultiDatePicker(
                "\(titleText)",
                selection: $selectedDates
            )\(disabledLine)
            """
        }
        let trimmedArg = inArg.trimmingCharacters(in: .whitespaces)
        return """
        MultiDatePicker(
            "\(titleText)",
            selection: $selectedDates,
            \(trimmedArg)
        )\(disabledLine)
        """
    }
}
