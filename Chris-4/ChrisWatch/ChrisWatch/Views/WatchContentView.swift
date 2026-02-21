import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject var store: WatchTweakStore
    @State private var tab: Int = 0

    var body: some View {
        TabView(selection: $tab) {
            WatchDashboardView()
                .tag(0)
                .environmentObject(store)

            WatchTweakListView()
                .tag(1)
                .environmentObject(store)

            WatchApplyView()
                .tag(2)
                .environmentObject(store)
        }
        .tabViewStyle(.page)
    }
}
