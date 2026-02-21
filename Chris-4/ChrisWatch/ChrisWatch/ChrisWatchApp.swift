import SwiftUI
import WatchKit

@main
struct ChrisWatchApp: App {
    @StateObject var store = WatchTweakStore()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(store)
        }
    }
}
