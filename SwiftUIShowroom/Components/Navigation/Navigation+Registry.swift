import SwiftUI

extension ShowcaseRegistry {
    static let navigationEntries: [ShowcaseEntry] = [
        ShowcaseEntry(
            id: "navigation-stack",
            title: "NavigationStack",
            category: .navigation,
            subtitle: "Push-based navigation container that",
            keywords: ["navigation", "navigationstack", "stack"],
        ) {
            NavigationStackShowcase()
        },
        ShowcaseEntry(
            id: "navigation-path",
            title: "NavigationPath",
            category: .navigation,
            subtitle: "Type-erased, heterogeneous navigation",
            keywords: ["navigation", "navigationpath", "path"],
        ) {
            NavigationPathShowcase()
        },
        ShowcaseEntry(
            id: "navigation-destination",
            title: "navigationDestination",
            category: .navigation,
            subtitle: "Associates a data type or",
            keywords: ["destination", "for", "navigation", "navigationdestination", "view"],
        ) {
            NavigationDestinationShowcase()
        },
        ShowcaseEntry(
            id: "navigation-link",
            title: "NavigationLink",
            category: .navigation,
            subtitle: "A control that triggers a push by",
            keywords: ["link", "navigation", "navigationlink"],
        ) {
            NavigationLinkShowcase()
        },
        ShowcaseEntry(
            id: "navigation-split-view",
            title: "NavigationSplitView",
            category: .navigation,
            subtitle: "Two- or three-column container where",
            keywords: ["navigation", "navigationsplitview", "split", "view"],
        ) {
            NavigationSplitViewShowcase()
        },
        ShowcaseEntry(
            id: "navigation-split-view-three-column",
            title: "NavigationSplitView (three-column)",
            category: .navigation,
            subtitle: "Three-column sidebar/content/detail",
            keywords: ["column", "navigation", "navigationsplitview", "split", "three", "view"],
        ) {
            NavigationSplitViewThreeColumnShowcase()
        },
        ShowcaseEntry(
            id: "tab-view",
            title: "TabView",
            category: .navigation,
            subtitle: "Top-level container switching between",
            keywords: ["tab", "tabview", "view"],
        ) {
            TabViewShowcase()
        },
        ShowcaseEntry(
            id: "tab",
            title: "Tab",
            category: .navigation,
            subtitle: "Declarative tab content item for",
            keywords: ["tab"],
        ) {
            TabShowcase()
        },
        ShowcaseEntry(
            id: "tab-section",
            title: "TabSection",
            category: .navigation,
            subtitle: "Groups secondary tabs into a labeled",
            keywords: ["section", "tab", "tabsection"],
        ) {
            TabSectionShowcase()
        },
        ShowcaseEntry(
            id: "tab-view-bottom-accessory",
            title: "TabView bottom accessory",
            category: .navigation,
            subtitle: "Attaches a persistent accessory view",
            keywords: ["accessory", "bottom", "content", "tab", "tabview", "tabviewbottomaccessory", "view"],
        ) {
            TabViewBottomAccessoryShowcase()
        },
        ShowcaseEntry(
            id: "toolbar",
            title: "Toolbar",
            category: .navigation,
            subtitle: "Populates navigation bar, bottom bar,",
            keywords: ["content", "toolbar", "view"],
        ) {
            ToolbarShowcase()
        },
        ShowcaseEntry(
            id: "toolbar-item",
            title: "ToolbarItem",
            category: .navigation,
            subtitle: "A single placed toolbar element,",
            keywords: ["item", "toolbar", "toolbaritem"],
        ) {
            ToolbarItemShowcase()
        },
        ShowcaseEntry(
            id: "toolbar-item-group",
            title: "ToolbarItemGroup",
            category: .navigation,
            subtitle: "Groups multiple controls under a",
            keywords: ["group", "item", "toolbar", "toolbaritemgroup"],
        ) {
            ToolbarItemGroupShowcase()
        },
        ShowcaseEntry(
            id: "toolbar-spacer",
            title: "ToolbarSpacer",
            category: .navigation,
            subtitle: "Inserts a fixed or flexible space",
            keywords: ["spacer", "toolbar", "toolbarspacer"],
        ) {
            ToolbarSpacerShowcase()
        },
        ShowcaseEntry(
            id: "navigation-title",
            title: "Navigation title",
            category: .navigation,
            subtitle: "Sets the title for the enclosing",
            keywords: ["navigation", "navigationtitle", "title", "view"],
        ) {
            NavigationTitleShowcase()
        },
        ShowcaseEntry(
            id: "searchable",
            title: "searchable",
            category: .navigation,
            subtitle: "Adds a system search field to a",
            keywords: ["placement", "prompt", "searchable", "text", "view"],
        ) {
            SearchableShowcase()
        },
        ShowcaseEntry(
            id: "search-token",
            title: "Search tokens",
            category: .navigation,
            subtitle: "Renders structured, removable filter",
            keywords: ["placement", "prompt", "search", "searchable", "text", "token", "tokens", "view"],
        ) {
            SearchTokenShowcase()
        },
        ShowcaseEntry(
            id: "navigation-transition-zoom",
            title: "Zoom navigation transition",
            category: .navigation,
            subtitle: "Animates a pushed view zooming from a",
            keywords: ["navigation", "navigationtransition", "transition", "view", "zoom"],
        ) {
            NavigationTransitionZoomShowcase()
        },
        ShowcaseEntry(
            id: "navigation-bar-back-button",
            title: "Navigation back button & bar items",
            category: .navigation,
            subtitle: "Controls back-button visibility, a",
            keywords: [
                "back", "bar", "button", "items", "navigation",
                "navigationbarbackbuttonhidden", "toolbarrole", "view",
            ],
        ) {
            NavigationBarBackButtonShowcase()
        },
        ShowcaseEntry(
            id: "tab-view-page-style",
            title: "TabView (page style)",
            category: .navigation,
            subtitle: "Horizontally paging TabView with a",
            keywords: ["page", "style", "tab", "tabview", "tabviewstyle", "view"],
        ) {
            TabViewPageStyleShowcase()
        },
        ShowcaseEntry(
            id: "toolbar-title-menu",
            title: "Toolbar title menu",
            category: .navigation,
            subtitle: "Attaches a menu to the navigation",
            keywords: ["content", "menu", "title", "toolbar", "toolbartitlemenu", "view"],
        ) {
            ToolbarTitleMenuShowcase()
        },
        ShowcaseEntry(
            id: "toolbar-customizable",
            title: "Customizable toolbar",
            category: .navigation,
            subtitle: "A user-customizable toolbar whose",
            keywords: ["content", "customizable", "id", "toolbar", "view"],
        ) {
            ToolbarCustomizableShowcase()
        },
        ShowcaseEntry(
            id: "navigation-subtitle",
            title: "Navigation subtitle",
            category: .navigation,
            subtitle: "Adds a secondary subtitle line",
            keywords: ["navigation", "navigationsubtitle", "subtitle", "view"],
        ) {
            NavigationSubtitleShowcase()
        },
        ShowcaseEntry(
            id: "tab-view-sidebar-adaptable",
            title: "TabView (sidebar adaptable)",
            category: .navigation,
            subtitle: "A TabView that renders as a tab bar",
            keywords: ["adaptable", "sidebar", "sidebaradaptable", "tab", "tabview", "tabviewstyle", "view"],
        ) {
            TabViewSidebarAdaptableShowcase()
        },
    ]
}
