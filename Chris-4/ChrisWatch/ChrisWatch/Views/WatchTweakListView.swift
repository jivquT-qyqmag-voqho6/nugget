import SwiftUI

struct WatchTweakListView: View {
    @EnvironmentObject var store: WatchTweakStore
    @State private var selectedCategory: String = "Hidden Features"

    let categories = ["Hidden Features", "Status Bar", "Springboard", "Daemons", "Internal"]

    var body: some View {
        List {
            // Category picker
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(categories, id: \.self) { cat in
                            Button {
                                selectedCategory = cat
                                WKInterfaceDevice.current().play(.click)
                            } label: {
                                Text(catEmoji(cat))
                                    .font(.system(size: 14))
                                    .frame(width: 30, height: 30)
                                    .background(
                                        selectedCategory == cat
                                        ? catColor(cat).opacity(0.8)
                                        : Color.white.opacity(0.08)
                                    )
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 2, leading: 0, bottom: 2, trailing: 0))

            // Category label
            Section {
                Text(selectedCategory)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(catColor(selectedCategory))
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 0, leading: 6, bottom: 0, trailing: 6))

            // Tweaks for selected category
            ForEach($store.tweaks.filter({ $0.wrappedValue.category == selectedCategory })) { $tweak in
                WatchTweakRow(tweak: $tweak)
            }
        }
        .listStyle(.plain)
    }

    func catEmoji(_ cat: String) -> String {
        switch cat {
        case "Hidden Features": return "✨"
        case "Status Bar":      return "📶"
        case "Springboard":     return "🏠"
        case "Daemons":         return "⚡"
        default:                return "⚙️"
        }
    }

    func catColor(_ cat: String) -> Color {
        switch cat {
        case "Hidden Features": return Color(hex: "9C59FF")
        case "Status Bar":      return Color(hex: "0A84FF")
        case "Springboard":     return Color(hex: "FF9F0A")
        case "Daemons":         return Color(hex: "FF453A")
        default:                return .gray
        }
    }
}

// MARK: - Single Tweak Row

struct WatchTweakRow: View {
    @Binding var tweak: WatchTweak

    var body: some View {
        switch tweak.type {
        case "toggle":
            Toggle(isOn: $tweak.isToggled) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(tweak.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        if tweak.isChrisOnly {
                            Text("C")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Color(hex: "9C59FF"))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color(hex: "9C59FF").opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                    }
                }
            }
            .tint(Color(hex: "5E5CE6"))
            .listRowBackground(
                tweak.isToggled
                ? Color(hex: "5E5CE6").opacity(0.12)
                : Color.white.opacity(0.05)
            )

        case "text":
            NavigationLink {
                WatchTextInputView(tweak: $tweak)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(tweak.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                        if tweak.isChrisOnly {
                            Text("C")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Color(hex: "9C59FF"))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color(hex: "9C59FF").opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                    }
                    if !tweak.textValue.isEmpty {
                        Text(tweak.textValue)
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "32D74B"))
                            .lineLimit(1)
                    } else {
                        Text("Tap to set")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
            }
            .listRowBackground(
                !tweak.textValue.isEmpty
                ? Color(hex: "32D74B").opacity(0.08)
                : Color.white.opacity(0.05)
            )

        default:
            EmptyView()
        }
    }
}

// MARK: - Text Input View (uses dictation + keyboard)

struct WatchTextInputView: View {
    @Binding var tweak: WatchTweak
    @State private var draft: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 8) {
            Text(tweak.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            if !draft.isEmpty {
                Text(draft)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "32D74B"))
                    .lineLimit(1)
            }

            Button {
                presentTextInput()
            } label: {
                Label("Enter Value", systemImage: "mic.fill")
                    .font(.system(size: 13))
            }
            .buttonStyle(.bordered)
            .tint(Color(hex: "5E5CE6"))

            if !draft.isEmpty {
                Button("Save") {
                    tweak.textValue = draft
                    WKInterfaceDevice.current().play(.success)
                    dismiss()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color(hex: "5E5CE6"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if !tweak.textValue.isEmpty {
                Button("Clear") {
                    tweak.textValue = ""
                    draft = ""
                    WKInterfaceDevice.current().play(.click)
                    dismiss()
                }
                .font(.system(size: 11))
                .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear { draft = tweak.textValue }
    }

    func presentTextInput() {
        // WatchKit text input with dictation + emoji + handwriting
        // In real implementation, this uses WKExtension.shared().visibleInterfaceController
        // to present a WKTextInputController
        draft = tweak.textValue  // placeholder — wire to WKTextInputController in real build
    }
}
