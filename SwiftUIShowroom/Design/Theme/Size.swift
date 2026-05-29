import CoreGraphics

extension DesignSystem {
    /// Component sizes grouped by logical category. Never hardcode frame dimensions.
    enum Size {
        enum Icon {
            static let small: CGFloat = 16
            static let medium: CGFloat = 24
            static let large: CGFloat = 32
            static let xLarge: CGFloat = 44
        }

        enum Button {
            static let minHeight: CGFloat = 44
            static let minWidth: CGFloat = 44
        }

        enum Card {
            static let minHeight: CGFloat = 80
        }

        enum Avatar {
            static let small: CGFloat = 32
            static let medium: CGFloat = 48
            static let large: CGFloat = 72
        }

        enum Dot {
            static let small: CGFloat = 6
            static let medium: CGFloat = 10
        }

        enum Preview {
            /// Minimum height of a showcase live-preview stage so layouts do not jump.
            static let minStageHeight: CGFloat = 160
            /// Maximum width a preview stretches to on wide screens.
            static let maxStageWidth: CGFloat = 520
        }
    }
}
