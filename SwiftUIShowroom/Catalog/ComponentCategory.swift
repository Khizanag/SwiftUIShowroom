import Foundation

/// The top-level taxonomy of the showroom. Order is the browse order.
enum ComponentCategory: String, CaseIterable, Identifiable, Hashable {
    case text
    case buttons
    case selection
    case containers
    case navigation
    case presentation
    case media
    case indicators
    case modifiers
    case effects
    case accessibility
    case charts
    case gestures
    case dataFlow

    var id: String { rawValue }

    var title: String {
        switch self {
        case .text: "Text & Labels"
        case .buttons: "Buttons & Actions"
        case .selection: "Selection & Input"
        case .containers: "Containers & Layout"
        case .navigation: "Navigation"
        case .presentation: "Presentation"
        case .media: "Media & Shapes"
        case .indicators: "Indicators & Feedback"
        case .modifiers: "Modifiers"
        case .effects: "Effects & Styling"
        case .accessibility: "Accessibility"
        case .charts: "Charts"
        case .gestures: "Gestures"
        case .dataFlow: "Environment & Data Flow"
        }
    }

    var systemImage: String {
        switch self {
        case .text: "textformat"
        case .buttons: "hand.tap"
        case .selection: "slider.horizontal.3"
        case .containers: "rectangle.3.group"
        case .navigation: "arrow.triangle.turn.up.right.diamond"
        case .presentation: "rectangle.portrait.on.rectangle.portrait"
        case .media: "photo"
        case .indicators: "gauge.with.dots.needle.bottom.50percent"
        case .modifiers: "wand.and.stars"
        case .effects: "sparkles"
        case .accessibility: "accessibility"
        case .charts: "chart.bar"
        case .gestures: "hand.draw"
        case .dataFlow: "arrow.triangle.branch"
        }
    }

    var summary: String {
        switch self {
        case .text: "Render and style text, labels, and editable fields."
        case .buttons: "Trigger actions: buttons, menus, toggles, steppers."
        case .selection: "Pick and input values: pickers, dates, sliders, gauges."
        case .containers: "Lay out and group content: stacks, grids, lists, forms."
        case .navigation: "Move between screens: stacks, split views, tabs, toolbars."
        case .presentation: "Present over content: sheets, alerts, popovers, dialogs."
        case .media: "Images, symbols, shapes, gradients, and materials."
        case .indicators: "Show status and progress, and give feedback."
        case .modifiers: "The modifier reference: layout, appearance, transforms, effects."
        case .effects: "Liquid Glass, animations, transitions, and symbol effects."
        case .accessibility: "Make every component usable by everyone."
        case .charts: "Visualize data with Swift Charts."
        case .gestures: "Recognize taps, drags, magnify, rotate, and compositions."
        case .dataFlow: "State, bindings, observation, and the environment."
        }
    }
}
