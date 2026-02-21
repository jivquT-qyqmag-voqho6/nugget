import SwiftUI

@main
struct ChrisApp: App {
    @StateObject var manager = TweakManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
                .preferredColorScheme(.dark)
        }
    }
}
