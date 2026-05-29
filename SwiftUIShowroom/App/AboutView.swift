import SwiftUI

/// The About sheet — describes the project and links the catalog.
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    Text("SwiftUIShowroom")
                        .font(DesignSystem.Font.largeTitle)
                    Text(tagline)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.secondary)
                    summary
                }
                .padding(DesignSystem.Spacing.large)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Sub-views
private extension AboutView {
    var tagline: String {
        "An interactive reference for every native SwiftUI component — "
            + "live-configurable, shown across all states, with copy-paste code."
    }

    var summary: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Label("\(ShowcaseRegistry.all.count) showcases shipped", systemImage: "square.grid.2x2")
            Label(categoriesLine, systemImage: "folder")
        }
        .font(DesignSystem.Font.callout)
    }

    var categoriesLine: String {
        let done = ShowcaseRegistry.populatedCategories.count
        let total = ComponentCategory.allCases.count
        return "\(done) of \(total) categories"
    }
}
