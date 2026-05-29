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
    ]
}
