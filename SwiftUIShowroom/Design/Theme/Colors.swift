import SwiftUI

extension DesignSystem {
    /// Semantic colors. Cross-platform safe: system colors on iOS / macOS, sensible
    /// fallbacks on tvOS and watchOS. Adapts to light and dark automatically.
    enum Color {
        static let accent = SwiftUI.Color.accentColor
        static let primary = SwiftUI.Color.primary
        static let secondary = SwiftUI.Color.secondary
        /// Foreground that sits on top of an accent / tinted fill.
        static let onAccent = SwiftUI.Color.white

        static var background: SwiftUI.Color {
            #if os(iOS)
            SwiftUI.Color(uiColor: .systemGroupedBackground)
            #elseif os(macOS)
            SwiftUI.Color(nsColor: .windowBackgroundColor)
            #else
            SwiftUI.Color.gray.opacity(0.12)
            #endif
        }

        static var cardBackground: SwiftUI.Color {
            #if os(iOS)
            SwiftUI.Color(uiColor: .secondarySystemGroupedBackground)
            #elseif os(macOS)
            SwiftUI.Color(nsColor: .controlBackgroundColor)
            #else
            SwiftUI.Color.gray.opacity(0.22)
            #endif
        }

        static var separator: SwiftUI.Color {
            #if os(iOS)
            SwiftUI.Color(uiColor: .separator)
            #elseif os(macOS)
            SwiftUI.Color(nsColor: .separatorColor)
            #else
            SwiftUI.Color.gray.opacity(0.3)
            #endif
        }
    }
}
