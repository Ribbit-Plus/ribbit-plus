import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSplash = true

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(0)

                ComposeView()
                    .tabItem {
                        Label("Transmit", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .tag(1)

                SpectrumView()
                    .tabItem {
                        Label("Monitor", systemImage: "waveform")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(Theme.ribbitGreen)
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            setupTabBarAppearance()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.backgroundDark)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .environmentObject(MessageStore())
        .environmentObject(AudioEngine())
}
