import SwiftUI

/// A labelled text field for a configuration panel.
struct ShowcaseTextControl: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var prompt: LocalizedStringKey?

    init(_ title: LocalizedStringKey, text: Binding<String>, prompt: LocalizedStringKey? = nil) {
        self.title = title
        self._text = text
        self.prompt = prompt
    }

    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Font.body)
            Spacer()
            TextField(title, text: $text, prompt: prompt.map { Text($0) })
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 200)
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
        }
    }
}
