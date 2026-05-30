import SwiftUI

extension ShowcaseRegistry {
    static let presentationEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "sheet",
            title: "Sheet",
            category: .presentation,
            subtitle: "Modally presents a view as a sheet",
            keywords: ["content", "ispresented", "ondismiss", "sheet", "view"],
        ) {
            SheetShowcase()
        },
        ShowcaseEntry(
            id: "sheet-item",
            title: "Sheet (Item-driven)",
            category: .presentation,
            subtitle: "Presents a sheet bound to an",
            keywords: ["content", "driven", "item", "ondismiss", "sheet", "view"],
        ) {
            SheetItemShowcase()
        },
        ShowcaseEntry(
            id: "full-screen-cover",
            title: "Full Screen Cover",
            category: .presentation,
            subtitle: "Covers the entire screen with a modal",
            keywords: ["content", "cover", "full", "fullscreencover", "ispresented", "ondismiss", "screen", "view"],
        ) {
            FullScreenCoverShowcase()
        },
        ShowcaseEntry(
            id: "popover",
            title: "Popover",
            category: .presentation,
            subtitle: "Presents content in a popover",
            keywords: ["arrowedge", "attachmentanchor", "content", "ispresented", "popover", "view"],
        ) {
            PopoverShowcase()
        },
        ShowcaseEntry(
            id: "alert",
            title: "Alert",
            category: .presentation,
            subtitle: "Presents a modal alert with a title,",
            keywords: ["actions", "alert", "ispresented", "message", "view"],
        ) {
            AlertShowcase()
        },
        ShowcaseEntry(
            id: "confirmation-dialog",
            title: "Confirmation Dialog",
            category: .presentation,
            subtitle: "Presents an action sheet of choices",
            keywords: [
                "actions",
                "confirmation",
                "confirmationdialog",
                "dialog",
                "ispresented",
                "message",
                "titlevisibility",
                "view",
            ],
        ) {
            ConfirmationDialogShowcase()
        },
        ShowcaseEntry(
            id: "inspector",
            title: "Inspector",
            category: .presentation,
            subtitle: "Presents a context-sensitive detail",
            keywords: ["content", "inspector", "ispresented", "view"],
        ) {
            InspectorShowcase()
        },
        ShowcaseEntry(
            id: "file-importer",
            title: "File Importer",
            category: .presentation,
            subtitle: "Presents the system document picker",
            keywords: [
                "allowedcontenttypes",
                "allowsmultipleselection",
                "file",
                "fileimporter",
                "importer",
                "ispresented",
                "oncompletion",
                "view",
            ],
        ) {
            FileImporterShowcase()
        },
        ShowcaseEntry(
            id: "file-exporter",
            title: "File Exporter",
            category: .presentation,
            subtitle: "Presents the system save dialog to",
            keywords: [
                "contenttype",
                "defaultfilename",
                "document",
                "exporter",
                "file",
                "fileexporter",
                "ispresented",
                "oncompletion",
            ],
        ) {
            FileExporterShowcase()
        },
        ShowcaseEntry(
            id: "file-mover",
            title: "File Mover",
            category: .presentation,
            subtitle: "Presents the document picker to move",
            keywords: ["file", "filemover", "ispresented", "mover", "oncompletion", "view"],
        ) {
            FileMoverShowcase()
        },
        ShowcaseEntry(
            id: "photos-picker",
            title: "Photos Picker",
            category: .presentation,
            subtitle: "Presents the privacy-preserving",
            keywords: ["photos", "photospicker", "picker"],
        ) {
            PhotosPickerShowcase()
        },
        ShowcaseEntry(
            id: "interactive-dismiss-disabled",
            title: "Interactive Dismiss Disabled",
            category: .presentation,
            subtitle: "Conditionally blocks swipe /",
            keywords: ["disabled", "dismiss", "interactive", "interactivedismissdisabled", "view"],
        ) {
            InteractiveDismissDisabledShowcase()
        },
        ShowcaseEntry(
            id: "dismissal-confirmation-dialog",
            title: "Dismissal Confirmation Dialog",
            category: .presentation,
            subtitle: "Shows a confirmation dialog when the",
            keywords: [
                "actions",
                "confirmation",
                "dialog",
                "dismissal",
                "dismissalconfirmationdialog",
                "message",
                "shouldpresent",
                "view",
            ],
        ) {
            DismissalConfirmationDialogShowcase()
        },
        ShowcaseEntry(
            id: "dismiss-action",
            title: "Dismiss Action (Environment)",
            category: .presentation,
            subtitle: "Environment action a presented view",
            keywords: ["action", "dismiss", "dismissaction", "environment", "environmentvalues"],
        ) {
            DismissActionShowcase()
        },
        ShowcaseEntry(
            id: "presentation-detents",
            title: "Presentation Detents",
            category: .presentation,
            subtitle: "Defines the set of resizable heights",
            keywords: ["detents", "presentation", "presentationdetents", "selection", "view"],
        ) {
            PresentationDetentsShowcase()
        },
        ShowcaseEntry(
            id: "quick-look-preview",
            title: "Quick Look Preview",
            category: .presentation,
            subtitle: "Presents a system Quick Look preview",
            keywords: ["look", "preview", "quick", "quicklookpreview", "view"],
        ) {
            QuickLookPreviewShowcase()
        },
        ShowcaseEntry(
            id: "presentation-background-content",
            title: "Custom Presentation Background",
            category: .presentation,
            subtitle: "Sets a fully custom view as the",
            keywords: [
                "alignment",
                "background",
                "content",
                "custom",
                "presentation",
                "presentationbackground",
                "view",
            ],
        ) {
            PresentationBackgroundContentShowcase()
        },
    ]
}
