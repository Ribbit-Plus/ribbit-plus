import SwiftUI

@main
struct RibbitPlusApp: App {
    @StateObject private var messageStore = MessageStore()
    @StateObject private var audioEngine = AudioEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(messageStore)
                .environmentObject(audioEngine)
                .preferredColorScheme(.dark)
        }
    }
}
