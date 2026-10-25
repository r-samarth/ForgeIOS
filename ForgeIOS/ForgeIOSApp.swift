import SwiftUI

@main
struct ForgeIOSApp: App {
    @StateObject private var store = ForgeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
