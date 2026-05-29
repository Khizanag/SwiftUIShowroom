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
    ]
}
