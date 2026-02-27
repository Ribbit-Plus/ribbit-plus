import SwiftUI

struct SplashView: View {
    @State private var logoScale = 0.3
    @State private var logoOpacity = 0.0
    @State private var textOpacity = 0.0
    @State private var ringScale = 0.5
    @State private var ringOpacity = 0.0
    @State private var waveOffset = 0.0

    var body: some View {
        ZStack {
            Theme.backgroundDark
                .ignoresSafeArea()

            // Animated radio waves
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Theme.ribbitGreen.opacity(0.2 - Double(i) * 0.05), lineWidth: 2)
                    .scaleEffect(ringScale + Double(i) * 0.3)
                    .opacity(ringOpacity)
            }

            VStack(spacing: 24) {
                // Frog logo
                Image("RibbitLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Theme.ribbitGreen, lineWidth: 3)
                    )
                    .shadow(color: Theme.ribbitGreen.opacity(0.5), radius: 20)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                VStack(spacing: 8) {
                    Text("Ribbit+")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.ribbitGradient)

                    Text("Digital Radio Messaging")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(2)
                        .textCase(.uppercase)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
                textOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                ringScale = 1.5
                ringOpacity = 0.6
            }
        }
    }
}

#Preview {
    SplashView()
}
