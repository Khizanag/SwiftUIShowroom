import SwiftUI

struct NavigationStackShowcase: View {
    @State private var navigationTitle = "Root"
    @State private var titleDisplayMode: TitleDisplayModeOption = .automatic
    @State private var depth = 1
    @State private var barHidden = false
    @State private var barBackgroundVisibility: VisibilityOption = .automatic
    @State private var backButtonHidden = false
    @State private var pathMode: PathModeOption = .typedArray

    var body: some View {
        ShowcaseScreen(
            title: "NavigationStack",
            summary: "Push-based navigation container with value-driven destinations and a back stack.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
    }
}

// MARK: - Nested types
extension NavigationStackShowcase {
    enum PathModeOption: ShowcasePickable {
        case none
        case typedArray
        case navigationPath

        var label: String {
            switch self {
            case .none: "none"
            case .typedArray: "typedArray"
            case .navigationPath: "navigationPath"
            }
        }
    }

    enum TitleDisplayModeOption: ShowcasePickable {
        case automatic
        case inline
        case large

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .inline: "inline"
            case .large: "large"
            }
        }
    }

    enum VisibilityOption: ShowcasePickable {
        case automatic
        case visible
        case hidden

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .visible: "visible"
            case .hidden: "hidden"
            }
        }

        var visibility: Visibility {
            switch self {
            case .automatic: .automatic
            case .visible: .visible
            case .hidden: .hidden
            }
        }
    }

    enum StackState: ShowcaseState {
        case defaultState
        case empty
        case longContent
        case selected

        var caption: String {
            switch self {
            case .defaultState: "Default"
            case .empty: "Empty (depth 0)"
            case .longContent: "Long content"
            case .selected: "Deep (depth 3)"
            }
        }
    }
}

// MARK: - Sub-views
private extension NavigationStackShowcase {
    var preview: some View {
        stackDemo(
            title: navigationTitle,
            depth: depth,
            barHidden: barHidden,
            barBgVisibility: barBackgroundVisibility.visibility,
            backBtnHidden: backButtonHidden,
        )
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Path mode", selection: $pathMode)
        ShowcaseStepper("Stack depth", value: $depth, in: 0...6)
        ShowcaseTextControl("Navigation title", text: $navigationTitle, prompt: "Root")
        ShowcasePicker("Title display mode", selection: $titleDisplayMode)
        ShowcasePicker("Bar background", selection: $barBackgroundVisibility)
        ShowcaseToggle("Hide nav bar", isOn: $barHidden)
        ShowcaseToggle("Hide back button", isOn: $backButtonHidden)
    }

    @ViewBuilder
    func stateView(_ state: StackState) -> some View {
        switch state {
        case .defaultState:
            stackDemo(
                title: "Root",
                depth: 1,
                barHidden: false,
                barBgVisibility: .automatic,
                backBtnHidden: false,
            )
        case .empty:
            stackDemo(
                title: "Empty",
                depth: 0,
                barHidden: false,
                barBgVisibility: .automatic,
                backBtnHidden: false,
            )
        case .longContent:
            stackDemo(
                title: "Long Content",
                depth: 1,
                barHidden: false,
                barBgVisibility: .automatic,
                backBtnHidden: false,
            )
        case .selected:
            stackDemo(
                title: "Root",
                depth: 3,
                barHidden: false,
                barBgVisibility: .automatic,
                backBtnHidden: false,
            )
        }
    }

    func stackDemo(
        title: String,
        depth: Int,
        barHidden: Bool,
        barBgVisibility: Visibility,
        backBtnHidden: Bool,
    ) -> some View {
        NavigationStack(path: .constant(Array(0..<depth))) {
            stackRootContent(title: title, isLong: depth == 1)
                #if os(iOS)
                .navigationBarTitleDisplayMode(titleDisplayMode.barMode)
                .toolbar(barHidden ? .hidden : .automatic, for: .navigationBar)
                .toolbarBackgroundVisibility(barBgVisibility, for: .navigationBar)
                #endif
                .navigationDestination(for: Int.self) { value in
                    Text("Detail \(value)")
                        .navigationTitle("Detail \(value)")
                        #if os(iOS)
                        .navigationBarBackButtonHidden(backBtnHidden)
                        #endif
                }
        }
        .frame(maxWidth: 320, minHeight: 220)
        .clipShape(.rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    @ViewBuilder
    func stackRootContent(title: String, isLong: Bool) -> some View {
        if isLong {
            List(0..<12, id: \.self) { value in
                NavigationLink("Row \(value)", value: value)
            }
            .navigationTitle(title)
        } else {
            List(0..<5, id: \.self) { value in
                NavigationLink("Row \(value)", value: value)
            }
            .navigationTitle(title)
        }
    }
}

// MARK: - Code generation
private extension NavigationStackShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("struct NavigationStackDemo: View {")
        lines.append("    \(pathDeclaration)")
        lines.append("")
        lines.append("    var body: some View {")
        lines.append("        \(stackInit) {")
        lines.append("            List(0..<10, id: \\.self) { value in")
        lines.append("                NavigationLink(\"Row \\(value)\", value: value)")
        lines.append("            }")
        lines.append("            .navigationTitle(\"\(navigationTitle)\")")
        if barHidden {
            lines.append("            .toolbar(.hidden, for: .navigationBar)")
        }
        if barBackgroundVisibility != .automatic {
            lines.append(
                "            .toolbarBackgroundVisibility(.\(barBackgroundVisibility.label), for: .navigationBar)"
            )
        }
        #if os(iOS)
        lines.append("            .navigationBarTitleDisplayMode(.\(titleDisplayMode.label))")
        #endif
        lines.append("            .navigationDestination(for: Int.self) { value in")
        lines.append("                Text(\"Detail \\(value)\")")
        if backButtonHidden {
            lines.append("                    .navigationBarBackButtonHidden(true)")
        }
        lines.append("            }")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }

    var pathDeclaration: String {
        switch pathMode {
        case .none:
            return ""
        case .typedArray:
            return "@State private var path: [Int] = []"
        case .navigationPath:
            return "@State private var path = NavigationPath()"
        }
    }

    var stackInit: String {
        switch pathMode {
        case .none:
            return "NavigationStack"
        case .typedArray:
            return "NavigationStack(path: $path)"
        case .navigationPath:
            return "NavigationStack(path: $path)"
        }
    }
}

// MARK: - TitleDisplayModeOption convenience
private extension NavigationStackShowcase.TitleDisplayModeOption {
    #if os(iOS)
    var barMode: NavigationBarItem.TitleDisplayMode {
        switch self {
        case .automatic: .automatic
        case .inline: .inline
        case .large: .large
        }
    }
    #endif
}
