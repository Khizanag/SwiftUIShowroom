import SwiftUI
#if !os(tvOS)
import PhotosUI

struct PhotosPickerShowcase: View {
    // MARK: - Nested types
    enum MatchingOption: ShowcasePickable {
        case images
        case videos
        case livePhotos
        case screenshots
        case imagesOrVideos
        case any

        var label: String {
            switch self {
            case .images: ".images"
            case .videos: ".videos"
            case .livePhotos: ".livePhotos"
            case .screenshots: ".screenshots"
            case .imagesOrVideos: ".any(of: [.images, .videos])"
            case .any: "nil (all)"
            }
        }

        var filter: PHPickerFilter? {
            switch self {
            case .images: .images
            case .videos: .videos
            case .livePhotos: .livePhotos
            case .screenshots: .screenshots
            case .imagesOrVideos: .any(of: [.images, .videos])
            case .any: nil
            }
        }

        var codeExpression: String {
            switch self {
            case .images: "matching: .images"
            case .videos: "matching: .videos"
            case .livePhotos: "matching: .livePhotos"
            case .screenshots: "matching: .screenshots"
            case .imagesOrVideos: "matching: .any(of: [.images, .videos])"
            case .any: ""
            }
        }
    }

    enum EncodingOption: ShowcasePickable {
        case automatic
        case current
        case compatible

        var label: String {
            switch self {
            case .automatic: "automatic"
            case .current: "current"
            case .compatible: "compatible"
            }
        }

        var value: PhotosPickerItem.EncodingDisambiguationPolicy {
            switch self {
            case .automatic: .automatic
            case .current: .current
            case .compatible: .compatible
            }
        }
    }

    #if os(iOS)
    enum StyleOption: ShowcasePickable {
        case presentation
        case inline
        case compact

        var label: String {
            switch self {
            case .presentation: ".presentation"
            case .inline: ".inline"
            case .compact: ".compact"
            }
        }
    }
    #endif

    enum PickerState: ShowcaseState {
        case `default`
        case selected
        case loading
        case empty

        var caption: String {
            switch self {
            case .default: "Default"
            case .selected: "Selected"
            case .loading: "Loading"
            case .empty: "Empty (no filter match)"
            }
        }
    }

    // MARK: - State
    @State private var selectedItem: PhotosPickerItem?
    @State private var matching: MatchingOption = .images
    @State private var encoding: EncodingOption = .automatic
    @State private var usePhotoLibrary = true
    @State private var loadedImage: Image?
    @State private var isLoading = false
    #if os(iOS)
    @State private var pickerStyle: StyleOption = .presentation
    #endif

    var body: some View {
        ShowcaseScreen(
            title: "Photos Picker",
            summary: "Privacy-preserving system photo picker; returns PhotosPickerItem loaded as Transferable.",
        ) {
            PreviewStage { preview }
            ShowcaseSection("Configuration") { controls }
            ShowcaseSection("States") { StateGallery(content: stateView) }
            ShowcaseSection("Generated code") { CodeBlock(code: generatedCode) }
        }
        .onChange(of: selectedItem) { _, newItem in
            loadImage(from: newItem)
        }
    }
}

// MARK: - Sub-views
private extension PhotosPickerShowcase {
    var preview: some View {
        VStack(spacing: DesignSystem.Spacing.medium) {
            thumbnailArea
            pickerButton
        }
    }

    @ViewBuilder
    var thumbnailArea: some View {
        if isLoading {
            loadingPlaceholder
        } else if let loadedImage {
            loadedImage
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        } else {
            emptyThumbnail
        }
    }

    var loadingPlaceholder: some View {
        ZStack {
            DesignSystem.Color.cardBackground
            ProgressView()
        }
        .frame(width: 160, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
    }

    var emptyThumbnail: some View {
        ZStack {
            DesignSystem.Color.cardBackground
            VStack(spacing: DesignSystem.Spacing.xSmall) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundStyle(DesignSystem.Color.secondary)
                Text("No selection")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
        .frame(width: 160, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
    }

    @ViewBuilder
    var pickerButton: some View {
        #if os(iOS)
        styledPicker
        #else
        basePicker
        #endif
    }

    #if os(iOS)
    @ViewBuilder
    var styledPicker: some View {
        switch pickerStyle {
        case .presentation:
            basePicker.photosPickerStyle(.presentation)
        case .inline:
            basePicker.photosPickerStyle(.inline).frame(height: 200)
        case .compact:
            basePicker.photosPickerStyle(.compact)
        }
    }
    #endif

    var basePicker: some View {
        buildPicker()
    }

    func buildPicker() -> some View {
        Group {
            if usePhotoLibrary {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: matching.filter,
                    preferredItemEncoding: encoding.value,
                    photoLibrary: .shared(),
                ) {
                    Label("Select Photo", systemImage: "photo")
                }
            } else {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: matching.filter,
                    preferredItemEncoding: encoding.value,
                ) {
                    Label("Select Photo", systemImage: "photo")
                }
            }
        }
        .buttonStyle(.bordered)
    }

    @ViewBuilder
    var controls: some View {
        ShowcasePicker("Matching", selection: $matching)
        ShowcasePicker("Preferred encoding", selection: $encoding)
        ShowcaseToggle("Use .shared() photo library", isOn: $usePhotoLibrary)
        #if os(iOS)
        ShowcasePicker("Style", selection: $pickerStyle)
        #endif
    }

    @ViewBuilder
    func stateView(_ state: PickerState) -> some View {
        switch state {
        case .default:
            pickerStateCell(
                symbol: "photo",
                label: "Select Photo",
                subtitle: "No item chosen",
            )
        case .selected:
            pickerStateCell(
                symbol: "checkmark.circle.fill",
                label: "Photo chosen",
                subtitle: "item ready to load",
                accent: true,
            )
        case .loading:
            pickerStateCell(
                symbol: "arrow.triangle.2.circlepath",
                label: "Loading…",
                subtitle: "loadTransferable in progress",
            )
        case .empty:
            pickerStateCell(
                symbol: "photo.slash",
                label: "No matches",
                subtitle: "filter yields no assets",
            )
        }
    }

    func pickerStateCell(
        symbol: String,
        label: String,
        subtitle: String,
        accent: Bool = false,
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.small) {
            Image(systemName: symbol)
                .font(DesignSystem.Font.title3)
                .foregroundStyle(accent ? DesignSystem.Color.accent : DesignSystem.Color.secondary)
                .frame(width: DesignSystem.Size.Icon.medium, height: DesignSystem.Size.Icon.medium)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.hairline) {
                Text(label)
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.primary)
                Text(subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.small)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Image loading
private extension PhotosPickerShowcase {
    func loadImage(from item: PhotosPickerItem?) {
        guard let item else {
            loadedImage = nil
            return
        }
        isLoading = true
        Task {
            do {
                let data = try await item.loadTransferable(type: Data.self)
                if let data, let uiImage = platformImage(from: data) {
                    loadedImage = uiImage
                } else {
                    loadedImage = nil
                }
            } catch {
                loadedImage = nil
            }
            isLoading = false
        }
    }

    func platformImage(from data: Data) -> Image? {
        #if os(macOS)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #else
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #endif
    }
}

// MARK: - Code generation
private extension PhotosPickerShowcase {
    var generatedCode: String {
        var lines: [String] = []
        lines.append("@State private var selectedItem: PhotosPickerItem?")
        lines.append("")
        lines.append("PhotosPicker(")
        lines.append("    selection: $selectedItem,")
        if !matching.codeExpression.isEmpty {
            lines.append("    \(matching.codeExpression),")
        }
        if encoding != .automatic {
            lines.append("    preferredItemEncoding: .\(encoding.label),")
        }
        if usePhotoLibrary {
            lines.append("    photoLibrary: .shared(),")
        }
        lines.append(") {")
        lines.append("    Label(\"Select Photo\", systemImage: \"photo\")")
        lines.append("}")
        #if os(iOS)
        if pickerStyle != .presentation {
            lines.append(".photosPickerStyle(\(pickerStyle.label))")
        }
        #endif
        lines.append("")
        lines.append(".onChange(of: selectedItem) { _, item in")
        lines.append("    Task {")
        lines.append("        let data = try? await item?.loadTransferable(type: Data.self)")
        lines.append("        // convert data to Image / store as needed")
        lines.append("    }")
        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

#else

// tvOS does not have PhotosUI; provide a stub so the file compiles on all targets.
struct PhotosPickerShowcase: View {
    var body: some View {
        ShowcaseScreen(
            title: "Photos Picker",
            summary: "Privacy-preserving system photo picker; returns PhotosPickerItem loaded as Transferable.",
        ) {
            ShowcaseSection("Not available") {
                Text("PhotosPicker is not available on tvOS.")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.secondary)
            }
        }
    }
}

#endif
