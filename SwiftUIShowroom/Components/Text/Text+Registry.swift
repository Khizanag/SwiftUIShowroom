import SwiftUI

extension ShowcaseRegistry {
    static let textEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "text",
            title: "Text",
            category: .text,
            subtitle: "Displays one or more lines of",
            keywords: ["text"],
        ) {
            TextShowcase()
        },
        ShowcaseEntry(
            id: "label",
            title: "Label",
            category: .text,
            subtitle: "A standard title + icon pairing for",
            keywords: ["label"],
        ) {
            LabelShowcase()
        },
        ShowcaseEntry(
            id: "textfield",
            title: "TextField",
            category: .text,
            subtitle: "An editable single- or multi-line",
            keywords: ["textfield"],
        ) {
            TextfieldShowcase()
        },
        ShowcaseEntry(
            id: "securefield",
            title: "SecureField",
            category: .text,
            subtitle: "A masked text input for passwords and",
            keywords: ["securefield"],
        ) {
            SecurefieldShowcase()
        },
        ShowcaseEntry(
            id: "texteditor",
            title: "TextEditor",
            category: .text,
            subtitle: "A scrollable, multi-line editor for",
            keywords: ["texteditor"],
        ) {
            TexteditorShowcase()
        },
        ShowcaseEntry(
            id: "link",
            title: "Link",
            category: .text,
            subtitle: "A control that opens a URL — a",
            keywords: ["link"],
        ) {
            LinkShowcase()
        },
        ShowcaseEntry(
            id: "sharelink",
            title: "ShareLink",
            category: .text,
            subtitle: "Presents the system share sheet for",
            keywords: ["sharelink"],
        ) {
            SharelinkShowcase()
        },
        ShowcaseEntry(
            id: "attributed-string",
            title: "AttributedString (in Text)",
            category: .text,
            subtitle: "A Unicode string with typed,",
            keywords: ["attributed", "attributedstring", "in", "string", "text"],
        ) {
            AttributedStringShowcase()
        },
    ]
}
