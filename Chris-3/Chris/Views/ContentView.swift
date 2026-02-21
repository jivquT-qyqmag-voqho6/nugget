import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: TweakManager
    @State private var selectedCategory: TweakCategory = .gestalt
    @State private var showFileImporter = false
    @State private var showMGImporter = false
    @State private var fileImportTarget: FileTarget = .pairing

    enum FileTarget { case pairing, mobilegestalt }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── Header ──────────────────────────────────────────────
                HeaderView()

                // ── Category Tab Bar ────────────────────────────────────
                CategoryTabBar(selected: $selectedCategory)

                Divider().background(Color.white.opacity(0.08))

                // ── Tweak List ──────────────────────────────────────────
                TweakListView(category: selectedCategory)

                Divider().background(Color.white.opacity(0.08))

                // ── Bottom Bar ──────────────────────────────────────────
                BottomBar(
                    onSelectPairing: {
                        fileImportTarget = .pairing
                        showFileImporter = true
                    },
                    onSelectMG: {
                        fileImportTarget = .mobilegestalt
                        showMGImporter = true
                    }
                )
            }
            .background(Color("Background"))
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            if let url = try? result.get().first {
                manager.pairingFileURL = url
            }
        }
        .fileImporter(
            isPresented: $showMGImporter,
            allowedContentTypes: [.propertyList, .data],
            allowsMultipleSelection: false
        ) { result in
            if let url = try? result.get().first {
                manager.mobileGestaltURL = url
            }
        }
    }
}

// MARK: - Header

struct HeaderView: View {
    @EnvironmentObject var manager: TweakManager

    var body: some View {
        HStack(spacing: 12) {
            // App icon + name
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color(hex: "5E5CE6"), Color(hex: "9C59FF")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 38, height: 38)
                    Text("C")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Chris")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("iOS Customization")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Enabled count badge
            if manager.totalEnabled() > 0 {
                Text("\(manager.totalEnabled()) enabled")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "5E5CE6"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "5E5CE6").opacity(0.15))
                    .clipShape(Capsule())
            }

            // Search
            NavigationLink {
                SearchView()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.07))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(Color("Background"))
    }
}

// MARK: - Category Tab Bar

struct CategoryTabBar: View {
    @Binding var selected: TweakCategory
    @EnvironmentObject var manager: TweakManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(TweakCategory.allCases) { cat in
                    CategoryTab(
                        category: cat,
                        isSelected: selected == cat,
                        count: manager.enabledCount(for: cat)
                    ) {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            selected = cat
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(Color("Background"))
    }
}

struct CategoryTab: View {
    let category: TweakCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12, weight: .medium))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? .white : category.color)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.25) : category.color.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected
                ? category.color.opacity(0.85)
                : Color.white.opacity(0.06)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bottom Bar

struct BottomBar: View {
    @EnvironmentObject var manager: TweakManager
    let onSelectPairing: () -> Void
    let onSelectMG: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            // Files row
            HStack(spacing: 10) {
                FileChip(
                    label: manager.pairingFileURL != nil ? "Pairing: ✓" : "Pairing File",
                    icon: "link",
                    filled: manager.pairingFileURL != nil,
                    action: onSelectPairing
                )
                FileChip(
                    label: manager.mobileGestaltURL != nil ? "MobileGestalt: ✓" : "MobileGestalt",
                    icon: "doc",
                    filled: manager.mobileGestaltURL != nil,
                    action: onSelectMG
                )
                Spacer()
            }

            // Progress
            if manager.isApplying {
                VStack(spacing: 4) {
                    ProgressView(value: manager.progress)
                        .progressViewStyle(.linear)
                        .tint(Color(hex: "5E5CE6"))
                    Text(manager.statusMessage)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if !manager.statusMessage.isEmpty {
                Text(manager.statusMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(manager.statusOK ? Color(hex: "32D74B") : Color(hex: "FF453A"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Buttons
            HStack(spacing: 10) {
                // Reset
                Button {
                    manager.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.white.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                // Apply
                Button {
                    manager.applyTweaks()
                } label: {
                    HStack(spacing: 8) {
                        if manager.isApplying {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(0.7)
                                .tint(.white)
                        }
                        Text(manager.isApplying ? "Applying…" : "Apply Tweaks")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        manager.isApplying
                        ? Color(hex: "5E5CE6").opacity(0.5)
                        : LinearGradient(colors: [Color(hex: "5E5CE6"), Color(hex: "9C59FF")],
                                         startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(manager.isApplying)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("Background"))
    }
}

struct FileChip: View {
    let label: String
    let icon: String
    let filled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(filled ? Color(hex: "32D74B") : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(filled ? Color(hex: "32D74B").opacity(0.12) : Color.white.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(filled ? Color(hex: "32D74B").opacity(0.3) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
