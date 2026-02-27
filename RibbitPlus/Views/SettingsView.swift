import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var messageStore: MessageStore
    @State private var callsignInput = ""
    @State private var selectedFrequency = "145.500 MHz"
    @State private var enableHaptics = true
    @State private var autoMonitor = false
    @State private var showClearConfirm = false
    @AppStorage("ribbit_volume") private var volume = 0.7

    private let frequencies = [
        "145.500 MHz", "146.520 MHz", "144.390 MHz",
        "433.500 MHz", "446.000 MHz", "7.030 MHz",
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundDark.ignoresSafeArea()

                List {
                    // Station section
                    Section {
                        HStack {
                            Image(systemName: "person.text.rectangle.fill")
                                .foregroundStyle(Theme.ribbitGreen)
                            TextField("Enter callsign", text: $callsignInput)
                                .textInputAutocapitalization(.characters)
                                .font(.system(.body, design: .monospaced))
                                .onSubmit {
                                    messageStore.setCallsign(callsignInput)
                                }
                                .onAppear {
                                    callsignInput = messageStore.callsign
                                }
                        }

                        Picker(selection: $selectedFrequency) {
                            ForEach(frequencies, id: \.self) { freq in
                                Text(freq)
                                    .font(.system(.body, design: .monospaced))
                                    .tag(freq)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .foregroundStyle(Theme.accentAmber)
                                Text("Frequency")
                            }
                        }
                        .onChange(of: selectedFrequency) { _, newValue in
                            messageStore.frequency = newValue
                        }
                    } header: {
                        sectionHeader("Station", icon: "radio.fill")
                    }

                    // Audio section
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundStyle(Theme.accentBlue)
                                Text("TX Volume")
                                Spacer()
                                Text("\(Int(volume * 100))%")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Slider(value: $volume, in: 0...1)
                                .tint(Theme.ribbitGreen)
                        }

                        Toggle(isOn: $autoMonitor) {
                            HStack {
                                Image(systemName: "waveform.badge.mic")
                                    .foregroundStyle(Theme.ribbitGreen)
                                Text("Auto Monitor")
                            }
                        }
                        .tint(Theme.ribbitGreen)
                    } header: {
                        sectionHeader("Audio", icon: "waveform")
                    }

                    // App section
                    Section {
                        Toggle(isOn: $enableHaptics) {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                    .foregroundStyle(.purple)
                                Text("Haptic Feedback")
                            }
                        }
                        .tint(Theme.ribbitGreen)

                        Button(role: .destructive) {
                            showClearConfirm = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(Theme.accentRed)
                                Text("Clear All Messages")
                                    .foregroundStyle(Theme.accentRed)
                            }
                        }
                    } header: {
                        sectionHeader("App", icon: "gearshape.fill")
                    }

                    // About section
                    Section {
                        aboutRow(title: "Version", detail: "1.0.0")
                        aboutRow(title: "Protocol", detail: "Ribbit OFDM v1")
                        aboutRow(title: "Max Message", detail: "170 bytes")
                        aboutRow(title: "Carriers", detail: "64 OFDM subcarriers")

                        Link(destination: URL(string: "https://www.ribbitradio.org")!) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundStyle(Theme.accentBlue)
                                Text("ribbitradio.org")
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textTertiary)
                            }
                        }

                        Link(destination: URL(string: "https://github.com/Ribbit-Plus")!) {
                            HStack {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                    .foregroundStyle(Theme.textSecondary)
                                Text("GitHub: Ribbit-Plus")
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textTertiary)
                            }
                        }
                    } header: {
                        sectionHeader("About Ribbit+", icon: "info.circle.fill")
                    } footer: {
                        VStack(spacing: 8) {
                            Image("RibbitLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                                .opacity(0.6)

                            Text("A project of the Open Research Institute")
                                .font(.caption2)
                                .foregroundStyle(Theme.textTertiary)

                            Text("🐸 Ribbit+ — Digital Radio Messaging")
                                .font(.caption2)
                                .foregroundStyle(Theme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .confirmationDialog("Clear Messages", isPresented: $showClearConfirm) {
                Button("Clear All", role: .destructive) {
                    messageStore.clearMessages()
                }
            } message: {
                Text("This will delete all saved messages. This cannot be undone.")
            }
        }
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(title)
        }
        .foregroundStyle(Theme.ribbitGreen)
        .textCase(.uppercase)
        .font(.caption)
        .tracking(1)
    }

    private func aboutRow(title: String, detail: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(detail)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MessageStore())
        .environmentObject(AudioEngine())
}
