import SwiftUI

extension ShowcaseRegistry {
    static let selectionEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "picker",
            title: "Picker",
            category: .selection,
            subtitle: "Every native picker style",
            keywords: ["picker", "menu", "segmented", "wheel", "inline", "palette", "selection"],
        ) {
            PickerShowcase()
        },
        ShowcaseEntry(
            id: "datepicker",
            title: "DatePicker",
            category: .selection,
            subtitle: "Date and time selection control",
            keywords: [
                "datepicker", "date", "time", "calendar", "compact", "graphical", "wheel", "selection",
            ],
        ) {
            DatepickerShowcase()
        },
        ShowcaseEntry(
            id: "multidatepicker",
            title: "MultiDatePicker",
            category: .selection,
            subtitle: "Pick multiple dates from a calendar",
            keywords: [
                "multidatepicker", "calendar", "dates", "datecomponents",
                "multi", "selection", "picker",
            ],
        ) {
            MultidatepickerShowcase()
        },
        ShowcaseEntry(
            id: "colorpicker",
            title: "ColorPicker",
            category: .selection,
            subtitle: "System color picker with opacity",
            keywords: ["colorpicker", "color", "picker", "swatch", "opacity", "selection", "hue"],
        ) {
            ColorpickerShowcase()
        },
        ShowcaseEntry(
            id: "slider",
            title: "Slider",
            category: .selection,
            subtitle: "Continuous or stepped range value",
            keywords: ["slider", "range", "continuous", "step", "value", "volume", "brightness", "neutral"],
        ) {
            SliderShowcase()
        },
        ShowcaseEntry(
            id: "gauge",
            title: "Gauge",
            category: .selection,
            subtitle: "Value within a range with tint",
            keywords: ["gauge", "range", "progress", "bpm", "capacity", "tint", "indicator", "accessory"],
        ) {
            GaugeShowcase()
        },
        ShowcaseEntry(
            id: "progressview",
            title: "ProgressView",
            category: .selection,
            subtitle: "Determinate and indeterminate progress",
            keywords: [
                "progressview", "progress", "loading", "determinate", "indeterminate",
                "linear", "circular", "timer", "download",
            ],
        ) {
            ProgressviewShowcase()
        },
    ]
}
