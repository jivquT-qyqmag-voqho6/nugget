import Foundation
import SwiftUI
import Combine

class TweakManager: ObservableObject {

    // Toggle states: tweakID → Bool
    @Published var toggles:  [String: Bool]   = [:]
    // Text/stepper values: tweakID → String
    @Published var values:   [String: String] = [:]

    @Published var isApplying: Bool = false
    @Published var progress: Double = 0
    @Published var statusMessage: String = ""
    @Published var statusOK: Bool = true

    @Published var pairingFileURL: URL? = nil
    @Published var mobileGestaltURL: URL? = nil

    // Enabled tabs (can toggle whole sections on/off like Nugget Mobile)
    @Published var enabledCategories: Set<TweakCategory> = Set(TweakCategory.allCases)

    // Search
    @Published var searchText: String = ""

    var filteredTweaks: [Tweak] {
        guard !searchText.isEmpty else { return allTweaks }
        return allTweaks.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    func tweaks(for category: TweakCategory) -> [Tweak] {
        if searchText.isEmpty {
            return allTweaks.filter { $0.category == category }
        }
        return filteredTweaks.filter { $0.category == category }
    }

    func enabledCount(for category: TweakCategory) -> Int {
        tweaks(for: category).filter { isEnabled($0) }.count
    }

    func isEnabled(_ tweak: Tweak) -> Bool {
        switch tweak.type {
        case .toggle:
            return toggles[tweak.id] ?? false
        case .text:
            return !(values[tweak.id]?.isEmpty ?? true)
        case .stepper:
            return !(values[tweak.id]?.isEmpty ?? true)
        case .picker:
            return !(values[tweak.id]?.isEmpty ?? true)
        }
    }

    func totalEnabled() -> Int {
        allTweaks.filter { isEnabled($0) }.count
    }

    func applyTweaks() {
        guard !isApplying else { return }
        guard pairingFileURL != nil else {
            statusMessage = "No pairing file selected."
            statusOK = false
            return
        }

        isApplying = true
        progress = 0
        statusMessage = "Preparing tweaks…"
        statusOK = true

        Task {
            await runRestore()
        }
    }

    @MainActor
    private func runRestore() async {
        do {
            try await ChrisRestoreEngine.apply(manager: self) { pct, msg in
                Task { @MainActor in
                    self.progress = pct
                    self.statusMessage = msg
                }
            }
            statusOK = true
        } catch {
            statusMessage = error.localizedDescription
            statusOK = false
        }
        isApplying = false
    }

    func reset() {
        toggles.removeAll()
        values.removeAll()
        statusMessage = ""
        progress = 0
    }
}
