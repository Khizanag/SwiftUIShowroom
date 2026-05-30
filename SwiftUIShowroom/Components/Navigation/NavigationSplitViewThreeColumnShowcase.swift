import SwiftUI

struct NavigationSplitViewThreeColumnShowcase: View {
    enum SplitStyleOption: ShowcasePickable {
        case automatic, balanced, prominentDetail

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .balanced: "balanced"
            case .prominentDetail: "prominentDetail"
            }
        }

        var codeName: String { label }
    }

    enum ColumnVisibilityOption: ShowcasePickable {
        case automatic, all, detailOnly

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .all: "all"
            case .detailOnly: "detailOnly"
            }
        }

        var codeName: String { label }

        var visibility: NavigationSplitViewVisibility {
            switch self {
            case .automatic: .automatic
            case .all: .all
            case .detailOnly: .detailOnly
            }
        }
    }

    enum ThreeColumnState: ShowcaseState {
        case empty, departmentOnly, selected

        var caption: String {
            switch self {
            case .empty: "Empty"
            case .departmentOnly: "Dept selected"
            case .selected: "Employee selected"
            }
        }

        var hasDepartment: Bool { self != .empty }

        var departmentBinding: Binding<Int?> {
            switch self {
            case .empty: .constant(nil)
            case .departmentOnly: .constant(0)
            case .selected: .constant(1)
            }
        }

        var employeeBinding: Binding<Int?> {
            switch self {
            case .empty, .departmentOnly: .constant(nil)
            case .selected: .constant(2)
            }
        }

        var employee: Int? {
            switch self {
            case .empty, .departmentOnly: nil
            case .selected: 2
            }
        }
    }

    @State private var style: SplitStyleOption = .prominentDetail
    @State private var columnVisibility: ColumnVisibilityOption = .all
    @State private var contentColumnWidthMin: Double = 200
    @State private var selectedDepartment: Int?
    @State private var selectedEmployee: Int?

    var body: some View {
        ShowcaseScreen(
            title: "NavigationSplitView (3 column)",
            summary: "Three-column sidebar/content/detail layout where each selection cascades.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Sub-views
private extension NavigationSplitViewThreeColumnShowcase {
    var preview: some View {
        splitViewWithStyle(
            visibility: columnVisibilityBinding,
            style: style,
            sidebar: { sidebarColumn },
            content: { contentColumn },
            detail: { detailColumn }
        )
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    func splitViewWithStyle<Sidebar: View, Content: View, Detail: View>(
        visibility: Binding<NavigationSplitViewVisibility>,
        style: SplitStyleOption,
        sidebar: () -> Sidebar,
        content: () -> Content,
        detail: () -> Detail
    ) -> some View {
        switch style {
        case .automatic:
            NavigationSplitView(columnVisibility: visibility) {
                sidebar()
            } content: {
                content()
            } detail: {
                detail()
            }
            .navigationSplitViewStyle(.automatic)
        case .balanced:
            NavigationSplitView(columnVisibility: visibility) {
                sidebar()
            } content: {
                content()
            } detail: {
                detail()
            }
            .navigationSplitViewStyle(.balanced)
        case .prominentDetail:
            NavigationSplitView(columnVisibility: visibility) {
                sidebar()
            } content: {
                content()
            } detail: {
                detail()
            }
            .navigationSplitViewStyle(.prominentDetail)
        }
    }

    var columnVisibilityBinding: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { columnVisibility.visibility },
            set: { newValue in
                columnVisibility = ColumnVisibilityOption.allCases.first {
                    $0.visibility == newValue
                } ?? columnVisibility
            }
        )
    }

    var sidebarColumn: some View {
        List(0..<4, id: \.self, selection: $selectedDepartment) { index in
            Label("Department \(index)", systemImage: "building.2")
        }
        .navigationTitle("Departments")
    }

    var contentColumn: some View {
        Group {
            if selectedDepartment != nil {
                List(0..<6, id: \.self, selection: $selectedEmployee) { index in
                    Label("Employee \(index)", systemImage: "person")
                }
                .navigationSplitViewColumnWidth(min: contentColumnWidthMin, ideal: 250)
                .navigationTitle("Employees")
            } else {
                ContentUnavailableView(
                    "No Department",
                    systemImage: "building.2.slash",
                    description: Text("Select a department to see employees.")
                )
            }
        }
    }

    var detailColumn: some View {
        Group {
            if let emp = selectedEmployee {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(DesignSystem.Font.largeTitle)
                        .foregroundStyle(DesignSystem.Color.accent)
                    Text("Employee \(emp)")
                        .font(DesignSystem.Font.title2)
                    Text("Department \(selectedDepartment ?? 0)")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView(
                    "No Employee",
                    systemImage: "person.slash",
                    description: Text("Select an employee to see details.")
                )
            }
        }
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Style", selection: $style)
        ShowcasePicker("Column visibility", selection: $columnVisibility)
        ShowcaseSlider(
            "Content min width",
            value: $contentColumnWidthMin,
            in: 150...320,
            step: 10
        )
    }

    @ViewBuilder
    func stateView(_ state: ThreeColumnState) -> some View {
        NavigationSplitView {
            List(0..<3, id: \.self, selection: state.departmentBinding) { index in
                Text("Dept \(index)")
            }
            .navigationTitle("Departments")
        } content: {
            if state.hasDepartment {
                List(0..<4, id: \.self, selection: state.employeeBinding) { index in
                    Text("Emp \(index)")
                }
                .navigationTitle("Employees")
            } else {
                Text("No dept").foregroundStyle(DesignSystem.Color.secondary)
            }
        } detail: {
            if let emp = state.employee {
                VStack(spacing: DesignSystem.Spacing.small) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(DesignSystem.Color.accent)
                    Text("Employee \(emp)")
                        .font(DesignSystem.Font.footnote)
                }
            } else {
                Text("No selection").foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .navigationSplitViewStyle(.automatic)
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }
}

// MARK: - Code generation
private extension NavigationSplitViewThreeColumnShowcase {
    var generatedCode: String {
        let minWidth = Int(contentColumnWidthMin)
        return """
        struct ThreeColumnSplitDemo: View {
            @State private var columnVisibility = NavigationSplitViewVisibility.\(columnVisibility.codeName)
            @State private var department: Int?
            @State private var employee: Int?

            var body: some View {
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    List(0..<4, id: \\.self, selection: $department) {
                        Text("Department \\($0)")
                    }
                    .navigationTitle("Departments")
                } content: {
                    List(0..<6, id: \\.self, selection: $employee) {
                        Text("Employee \\($0)")
                    }
                    .navigationSplitViewColumnWidth(min: \(minWidth), ideal: 250)
                    .navigationTitle("Employees")
                } detail: {
                    if let employee {
                        Text("Details for \\(employee)")
                    } else {
                        ContentUnavailableView("No Employee", systemImage: "person.slash")
                    }
                }
                .navigationSplitViewStyle(.\(style.codeName))
            }
        }
        """
    }
}
