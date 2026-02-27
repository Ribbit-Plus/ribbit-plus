import SwiftUI

struct ComposeView: View {
    @EnvironmentObject var messageStore: MessageStore
    @EnvironmentObject var audioEngine: AudioEngine
    @State private var messageText = ""
    @State private var showSentAnimation = false
    @FocusState private var isTextFieldFocused: Bool

    private var byteCount: Int { messageText.utf8.count }
    private var bytesRemaining: Int { Message.maxBytes - byteCount }
    private var isOverLimit: Bool { byteCount > Message.maxBytes }
    private var canSend: Bool { !messageText.isEmpty && !isOverLimit && !audioEngine.isTransmitting }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundDark.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Spectrum visualizer header
                    SpectrumBar(data: audioEngine.spectrumData)
                        .frame(height: 60)
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 24) {
                            // Callsign & Frequency info
                            statusCard

                            // Compose area
                            composeCard

                            // Quick messages
                            quickMessages

                            // Transmit button
                            transmitButton
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Transmit")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .overlay {
            if showSentAnimation {
                sentOverlay
            }
        }
    }

    private var statusCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Callsign", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
                Text(messageStore.callsign.isEmpty ? "N0CALL" : messageStore.callsign)
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.ribbitGreen)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Label("Frequency", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
                Text(messageStore.frequency)
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.accentAmber)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.backgroundCard)
        )
    }

    private var composeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Message")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(byteCount)/\(Message.maxBytes) bytes")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(isOverLimit ? Theme.accentRed : Theme.textSecondary)
                    .animation(.easeInOut, value: isOverLimit)
            }

            TextEditor(text: $messageText)
                .focused($isTextFieldFocused)
                .frame(minHeight: 100, maxHeight: 200)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(Theme.backgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isTextFieldFocused ? Theme.ribbitGreen : Color.clear, lineWidth: 1.5)
                )
                .foregroundStyle(Theme.textPrimary)
                .font(.body.monospaced())

            // Byte progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.backgroundElevated)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(isOverLimit ? Theme.accentRed : Theme.ribbitGreen)
                        .frame(width: geo.size.width * min(CGFloat(byteCount) / CGFloat(Message.maxBytes), 1.0))
                        .animation(.spring(response: 0.3), value: byteCount)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.backgroundCard)
        )
    }

    private var quickMessages: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Messages")
                .font(.caption)
                .foregroundStyle(Theme.textTertiary)
                .textCase(.uppercase)
                .tracking(1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickMessageOptions, id: \.self) { msg in
                        Button {
                            messageText = msg
                            isTextFieldFocused = false
                        } label: {
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(Theme.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Theme.backgroundCard)
                                        .overlay(Capsule().stroke(Theme.backgroundElevated))
                                )
                        }
                    }
                }
            }
        }
    }

    private var transmitButton: some View {
        Button {
            sendMessage()
        } label: {
            ZStack {
                if audioEngine.isTransmitting {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                        Text("Transmitting...")
                            .font(.headline)
                    }
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "wave.3.right")
                            .font(.title3)
                            .symbolEffect(.variableColor.iterative, options: .repeating, isActive: canSend)
                        Text("Transmit")
                            .font(.headline)
                    }
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(canSend ? Theme.ribbitGreen : Theme.textTertiary.opacity(0.3))
            )
            .overlay {
                if audioEngine.isTransmitting {
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Theme.ribbitGreenLight.opacity(0.3))
                            .frame(width: geo.size.width * audioEngine.transmitProgress)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .disabled(!canSend)
        .sensoryFeedback(.impact, trigger: audioEngine.isTransmitting)
    }

    private var sentOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.ribbitGreen)
                .symbolEffect(.bounce, value: showSentAnimation)

            Text("Message Transmitted! 🐸")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .transition(.scale.combined(with: .opacity))
    }

    private func sendMessage() {
        guard canSend else { return }
        let text = messageText
        messageText = ""
        isTextFieldFocused = false

        let _ = messageStore.sendMessage(text: text)

        Task {
            await audioEngine.transmitMessage(text)
            withAnimation(.spring) {
                showSentAnimation = true
            }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            withAnimation {
                showSentAnimation = false
            }
        }
    }

    private var quickMessageOptions: [String] {
        let call = messageStore.callsign.isEmpty ? "N0CALL" : messageStore.callsign
        return [
            "CQ CQ CQ de \(call)",
            "\(call) QRV",
            "73 de \(call)",
            "QSL 599 TU",
            "Emergency: Need assistance",
        ]
    }
}

#Preview {
    ComposeView()
        .environmentObject(MessageStore())
        .environmentObject(AudioEngine())
}
