import SwiftUI

extension DesignSystem {
    /// Fonts map onto the system text styles so Dynamic Type scaling works for free.
    /// Never use `.font(.system(size:))` in feature code — reach for a token here.
    enum Font {
        static let largeTitle = SwiftUI.Font.largeTitle
        static let title = SwiftUI.Font.title
        static let title2 = SwiftUI.Font.title2
        static let title3 = SwiftUI.Font.title3
        static let headline = SwiftUI.Font.headline
        static let subheadline = SwiftUI.Font.subheadline
        static let body = SwiftUI.Font.body
        static let callout = SwiftUI.Font.callout
        static let footnote = SwiftUI.Font.footnote
        static let caption = SwiftUI.Font.caption
        static let caption2 = SwiftUI.Font.caption2
        /// Monospaced body — used to render generated source code.
        static let code = SwiftUI.Font.system(.footnote, design: .monospaced)
        /// Monospaced caption — used for inline code fragments and value labels.
        static let codeInline = SwiftUI.Font.system(.caption, design: .monospaced)
    }
}
