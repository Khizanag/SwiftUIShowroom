import SwiftUI

extension ShowcaseRegistry {
    static let buttonsEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "button",
            title: "Button",
            category: .buttons,
            subtitle: "Styles, roles, control size, tint",
            keywords: ["button", "action", "bordered", "prominent", "glass", "role", "tint"],
        ) {
            ButtonShowcase()
        },
        ShowcaseEntry(
            id: "toggle",
            title: "Toggle",
            category: .buttons,
            subtitle: "Switch, button, and checkbox styles",
            keywords: ["toggle", "switch", "checkbox", "on", "off", "boolean"],
        ) {
            ToggleShowcase()
        },
        ShowcaseEntry(
            id: "button-role",
            title: "Button Role",
            category: .buttons,
            subtitle: "A semantic value describing a",
            keywords: ["button", "buttonrole", "role"],
        ) {
            ButtonRoleShowcase()
        },
        ShowcaseEntry(
            id: "menu",
            title: "Menu",
            category: .buttons,
            subtitle: "A control that presents a menu of",
            keywords: ["menu"],
        ) {
            MenuShowcase()
        },
        ShowcaseEntry(
            id: "stepper",
            title: "Stepper",
            category: .buttons,
            subtitle: "A control that increments and",
            keywords: ["stepper"],
        ) {
            StepperShowcase()
        },
        ShowcaseEntry(
            id: "edit-button",
            title: "EditButton",
            category: .buttons,
            subtitle: "A button that toggles the editMode",
            keywords: ["button", "edit", "editbutton"],
        ) {
            EditButtonShowcase()
        },
        ShowcaseEntry(
            id: "rename-button",
            title: "RenameButton",
            category: .buttons,
            subtitle: "A button that triggers a rename",
            keywords: ["button", "rename", "renamebutton"],
        ) {
            RenameButtonShowcase()
        },
        ShowcaseEntry(
            id: "paste-button",
            title: "PasteButton",
            category: .buttons,
            subtitle: "A system button that reads",
            keywords: ["button", "paste", "pastebutton"],
        ) {
            PasteButtonShowcase()
        },
        ShowcaseEntry(
            id: "control-group",
            title: "ControlGroup",
            category: .buttons,
            subtitle: "A container that lays out",
            keywords: ["control", "controlgroup", "group"],
        ) {
            ControlGroupShowcase()
        },
        ShowcaseEntry(
            id: "help-link",
            title: "HelpLink",
            category: .buttons,
            subtitle: "A button with a system-standard help",
            keywords: ["help", "helplink", "link"],
        ) {
            HelpLinkShowcase()
        },
        ShowcaseEntry(
            id: "text-field-link",
            title: "TextFieldLink",
            category: .buttons,
            subtitle: "A watchOS control that presents the",
            keywords: ["field", "link", "text", "textfieldlink"],
        ) {
            TextFieldLinkShowcase()
        },
        ShowcaseEntry(
            id: "new-document-button",
            title: "NewDocumentButton",
            category: .buttons,
            subtitle: "A button for the document launch",
            keywords: ["button", "document", "new", "newdocumentbutton"],
        ) {
            NewDocumentButtonShowcase()
        },
    ]
}
