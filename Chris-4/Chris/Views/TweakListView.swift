import SwiftUI

// MARK: - Tweak List

struct TweakListView: View {
    let category: TweakCategory
    @EnvironmentObject var manager: TweakManager

    var tweaks: [Tweak] { manager.tweaks(for: category) }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Section header
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(category.color)
                        .font(.system(size: 14, weight: .semibold))
                    Text(category.rawValue.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .kerning(0.8)
                    Spacer()
                    Text("\(tweaks.count) tweaks")
                        .font(.system(size: 11))
                        .foregroundColor(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

                // Chris-exclusive callout if any
                let chrisOnly = tweaks.filter { $0.isChrisOnly }
                if !chrisOnly.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "9C59FF"))
                        Text("\(chrisOnly.count) exclusive tweaks not found in Nugget")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "9C59FF"))
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: "9C59FF").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(hex: "9C59FF").opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }

                // Tweak rows grouped in a card
                VStack(spacing: 0) {
                    ForEach(Array(tweaks.enumerated()), id: \.element.id) { index, tweak in
                        TweakRow(tweak: tweak)
                        if index < tweaks.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.06))
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(Color("Background"))
    }
}

// MARK: - Tweak Row

struct TweakRow: View {
    let tweak: Tweak
    @EnvironmentObject var manager: TweakManager

    var body: some View {
        HStack(spacing: 12) {
            // Left: info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(tweak.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)

                    if tweak.isChrisOnly {
                        Text("CHRIS")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "9C59FF"))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color(hex: "9C59FF").opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }

                    if tweak.isRisky {
                        Label("Risky", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "FF9F0A"))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color(hex: "FF9F0A").opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }

                Text(tweak.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // iOS range
                let range = tweak.iOSMax != nil ? "iOS \(tweak.iOSMin) – \(tweak.iOSMax!)" : "iOS \(tweak.iOSMin)+"
                Text(range)
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.2))
            }

            Spacer()

            // Right: control
            TweakControl(tweak: tweak)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
    }
}

// MARK: - Tweak Control

struct TweakControl: View {
    let tweak: Tweak
    @EnvironmentObject var manager: TweakManager

    var body: some View {
        switch tweak.type {
        case .toggle:
            Toggle("", isOn: Binding(
                get: { manager.toggles[tweak.id] ?? false },
                set: { manager.toggles[tweak.id] = $0 }
            ))
            .toggleStyle(SwitchToggleStyle(tint: tweak.isRisky ? Color(hex: "FF453A") : Color(hex: "5E5CE6")))
            .labelsHidden()

        case .text(let placeholder):
            TextField(placeholder, text: Binding(
                get: { manager.values[tweak.id] ?? "" },
                set: { manager.values[tweak.id] = $0 }
            ))
            .font(.system(size: 13))
            .foregroundColor(.white)
            .multilineTextAlignment(.trailing)
            .frame(width: 130)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

        case .stepper(let min, let max):
            HStack(spacing: 8) {
                Text(manager.values[tweak.id] ?? "\(min)")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(minWidth: 24)

                Stepper("", value: Binding(
                    get: { Int(manager.values[tweak.id] ?? "\(min)") ?? min },
                    set: { manager.values[tweak.id] = "\($0)" }
                ), in: min...max)
                .labelsHidden()
            }

        case .picker(let options):
            Picker("", selection: Binding(
                get: { manager.values[tweak.id] ?? options.first ?? "" },
                set: { manager.values[tweak.id] = $0 }
            )) {
                ForEach(options, id: \.self) { opt in
                    Text(opt).tag(opt)
                }
            }
            .pickerStyle(.menu)
            .font(.system(size: 13))
        }
    }
}

// MARK: - Search View

struct SearchView: View {
    @EnvironmentObject var manager: TweakManager
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search tweaks…", text: $manager.searchText)
                    .focused($focused)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                if !manager.searchText.isEmpty {
                    Button { manager.searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(16)

            Divider().background(Color.white.opacity(0.08))

            // Results
            if manager.searchText.isEmpty {
                ContentUnavailableView("Search Tweaks", systemImage: "magnifyingglass",
                    description: Text("Type to search across all \(allTweaks.count) tweaks"))
            } else {
                let results = manager.filteredTweaks
                if results.isEmpty {
                    ContentUnavailableView.search(text: manager.searchText)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(results.enumerated()), id: \.element.id) { index, tweak in
                                TweakRow(tweak: tweak)
                                if index < results.count - 1 {
                                    Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(12)
                    }
                }
            }
        }
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focused = true }
    }
}
