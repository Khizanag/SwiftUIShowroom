import SwiftUI

struct DatepickerShowcase: View {
    @State private var selectedDate: Date = Date()
    @State private var labelText: String = "Start Date"
    @State private var style: DatePickerStyleOption = .compact
    @State private var components: ComponentsOption = .both
    @State private var rangeMode: RangeModeOption = .unbounded
    @State private var isEnabled: Bool = true

    // MARK: - Nested config enums
    enum DatePickerStyleOption: ShowcasePickable {
        case automatic, compact, graphical, wheel, field, stepperField

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .compact: "compact"
            case .graphical: "graphical"
            case .wheel: "wheel (iOS)"
            case .field: "field (macOS)"
            case .stepperField: "stepperField (macOS)"
            }
        }

        var code: String {
            switch self {
            case .automatic: ".automatic"
            case .compact: ".compact"
            case .graphical: ".graphical"
            case .wheel: ".wheel"
            case .field: ".field"
            case .stepperField: ".stepperField"
            }
        }
    }

    enum ComponentsOption: ShowcasePickable {
        case both, dateOnly, timeOnly

        var label: String {
            switch self {
            case .both: "date & time"
            case .dateOnly: "date only"
            case .timeOnly: "time only"
            }
        }

        #if !os(tvOS)
        var pickerComponents: DatePickerComponents {
            switch self {
            case .both: [.date, .hourAndMinute]
            case .dateOnly: [.date]
            case .timeOnly: [.hourAndMinute]
            }
        }
        #endif

        var code: String {
            switch self {
            case .both: "[.date, .hourAndMinute]"
            case .dateOnly: ".date"
            case .timeOnly: ".hourAndMinute"
            }
        }
    }

    enum RangeModeOption: ShowcasePickable {
        case unbounded, closed, from, through

        var label: String {
            switch self {
            case .unbounded: "unbounded"
            case .closed: "closed (past month)"
            case .from: "from (today...)"
            case .through: "through (...today)"
            }
        }

        var code: String {
            switch self {
            case .unbounded: "/* no range */"
            case .closed: "startOfMonth ... .now"
            case .from: ".now..."
            case .through: "... .now"
            }
        }
    }

    enum DatePickerVisualState: ShowcaseState {
        case dateAndTime, dateOnly, timeOnly, disabled

        var caption: String {
            switch self {
            case .dateAndTime: "Date & Time"
            case .dateOnly: "Date Only"
            case .timeOnly: "Time Only"
            case .disabled: "Disabled"
            }
        }

        #if !os(tvOS)
        var pickerComponents: DatePickerComponents {
            switch self {
            case .dateAndTime, .disabled: [.date, .hourAndMinute]
            case .dateOnly: [.date]
            case .timeOnly: [.hourAndMinute]
            }
        }
        #endif
    }

    // MARK: - Body
    var body: some View {
        ShowcaseScreen(
            title: "DatePicker",
            summary: "A control for selecting an absolute date and/or time, bound to a Date.",
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
private extension DatepickerShowcase {
    @ViewBuilder
    var preview: some View {
        #if os(tvOS)
        unavailableLabel
        #else
        applyStyle(
            DatePicker(
                labelText,
                selection: $selectedDate,
                displayedComponents: components.pickerComponents,
            ),
            style: style,
        )
        .disabled(!isEnabled)
        .frame(maxWidth: 420)
        #endif
    }

    @ViewBuilder
    var controls: some View {
        ShowcaseTextControl("Label", text: $labelText)
        ShowcasePicker("Style", selection: $style)
        ShowcasePicker("Components", selection: $components)
        ShowcasePicker("Range", selection: $rangeMode)
        ShowcaseToggle("Enabled", isOn: $isEnabled)
    }

    @ViewBuilder
    func stateView(_ state: DatePickerVisualState) -> some View {
        #if os(tvOS)
        unavailableLabel
        #else
        applyStyle(
            DatePicker(
                state.caption,
                selection: .constant(Date()),
                displayedComponents: state.pickerComponents,
            ),
            style: .compact,
        )
        .disabled(state == .disabled)
        .frame(maxWidth: 300)
        #endif
    }

    var unavailableLabel: some View {
        Text("DatePicker is not available on tvOS.")
            .font(DesignSystem.Font.callout)
            .foregroundStyle(DesignSystem.Color.secondary)
    }

    #if !os(tvOS)
    @ViewBuilder
    func applyStyle(_ picker: some View, style: DatePickerStyleOption) -> some View {
        switch style {
        case .automatic:
            picker.datePickerStyle(.automatic)
        case .compact:
            #if os(macOS) || os(iOS)
            picker.datePickerStyle(.compact)
            #else
            picker.datePickerStyle(.automatic)
            #endif
        case .graphical:
            #if os(macOS) || os(iOS)
            picker.datePickerStyle(.graphical)
            #else
            picker.datePickerStyle(.automatic)
            #endif
        case .wheel:
            #if os(iOS)
            picker.datePickerStyle(.wheel)
            #else
            picker.datePickerStyle(.automatic)
            #endif
        case .field:
            #if os(macOS)
            picker.datePickerStyle(.field)
            #else
            picker.datePickerStyle(.automatic)
            #endif
        case .stepperField:
            #if os(macOS)
            picker.datePickerStyle(.stepperField)
            #else
            picker.datePickerStyle(.automatic)
            #endif
        }
    }
    #endif
}

// MARK: - Code generation
private extension DatepickerShowcase {
    var generatedCode: String {
        var lines: [String] = []
        let rangeArg = rangeArgument

        lines.append("DatePicker(")
        lines.append("    \"\(labelText)\",")
        lines.append("    selection: $date,")
        if !rangeArg.isEmpty {
            lines.append("    in: \(rangeArg),")
        }
        lines.append("    displayedComponents: \(components.code)")
        lines.append(")")
        lines.append(".datePickerStyle(\(style.code))")

        if !isEnabled {
            lines.append(".disabled(true)")
        }

        return lines.joined(separator: "\n")
    }

    var rangeArgument: String {
        switch rangeMode {
        case .unbounded: ""
        case .closed: "Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now ... .now"
        case .from: ".now..."
        case .through: "... .now"
        }
    }
}
