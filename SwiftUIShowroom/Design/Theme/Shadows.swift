import SwiftUI

extension DesignSystem {
    enum Shadow {
        struct Style {
            let color: SwiftUI.Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
        }

        static let subtle = Style(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        static let card = Style(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Shadow modifier
extension View {
    func designShadow(_ style: DesignSystem.Shadow.Style) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
