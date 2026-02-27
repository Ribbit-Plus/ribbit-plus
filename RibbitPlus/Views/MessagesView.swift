import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var messageStore: MessageStore
    @State private var selectedMessage: Message?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundDark.ignoresSafeArea()

                if messageStore.messages.isEmpty {
                    emptyState
                } else {
                    messageList
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(messageStore.messages) { message in
                    MessageBubble(message: message)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 60))
                .foregroundStyle(Theme.ribbitGreen.opacity(0.4))
                .symbolEffect(.pulse, options: .repeating)

            Text("No Messages Yet")
                .font(.title2.bold())
                .foregroundStyle(Theme.textPrimary)

            Text("Start monitoring or transmit a message\nto begin your QSO.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct MessageBubble: View {
    let message: Message
    @State private var appeared = false

    private var isOutgoing: Bool { message.direction == .outgoing }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if isOutgoing { Spacer(minLength: 40) }

            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 6) {
                // Header
                HStack(spacing: 6) {
                    if !isOutgoing {
                        SignalIndicator(strength: message.signalStrength)
                    }

                    Text(message.callsign)
                        .font(.caption.bold())
                        .foregroundStyle(isOutgoing ? Theme.ribbitGreenLight : Theme.accentAmber)

                    Text("•")
                        .foregroundStyle(Theme.textTertiary)

                    Text(message.formattedTime)
                        .font(.caption2)
                        .foregroundStyle(Theme.textTertiary)

                    if isOutgoing {
                        SignalIndicator(strength: message.signalStrength)
                    }
                }

                // Message body
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(Theme.textPrimary)

                // Footer
                HStack(spacing: 4) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 9))
                    Text(message.frequency)
                        .font(.system(size: 10, design: .monospaced))
                    Text("• \(message.byteCount)/\(Message.maxBytes) bytes")
                        .font(.system(size: 10, design: .monospaced))
                }
                .foregroundStyle(Theme.textTertiary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isOutgoing ? Theme.ribbitGreen.opacity(0.15) : Theme.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isOutgoing ? Theme.ribbitGreen.opacity(0.3) : Theme.backgroundElevated, lineWidth: 1)
                    )
            )

            if !isOutgoing { Spacer(minLength: 40) }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

struct SignalIndicator: View {
    let strength: Double

    var body: some View {
        HStack(spacing: 1.5) {
            ForEach(0..<4, id: \.self) { bar in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Double(bar) / 4.0 < strength
                          ? Theme.signalColor(for: strength)
                          : Theme.textTertiary.opacity(0.3))
                    .frame(width: 3, height: CGFloat(4 + bar * 2))
            }
        }
    }
}

#Preview {
    MessagesView()
        .environmentObject(MessageStore())
        .environmentObject(AudioEngine())
}
