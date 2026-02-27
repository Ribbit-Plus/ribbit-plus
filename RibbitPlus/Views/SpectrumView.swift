import SwiftUI

struct SpectrumView: View {
    @EnvironmentObject var audioEngine: AudioEngine
    @State private var isMonitoring = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundDark.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Waterfall spectrum display
                    waterfallDisplay

                    // Audio level meter
                    audioLevelMeter

                    // Monitor controls
                    monitorControls

                    // Info panel
                    infoPanel

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Monitor")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var waterfallDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SPECTRUM")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(2)

                Spacer()

                Circle()
                    .fill(isMonitoring ? Theme.ribbitGreen : Theme.accentRed)
                    .frame(width: 8, height: 8)
                    .shadow(color: isMonitoring ? Theme.ribbitGreen : Theme.accentRed, radius: 4)

                Text(isMonitoring ? "LIVE" : "IDLE")
                    .font(.system(.caption2, design: .monospaced, weight: .bold))
                    .foregroundStyle(isMonitoring ? Theme.ribbitGreen : Theme.accentRed)
            }

            // Main spectrum display
            ZStack(alignment: .bottom) {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Divider()
                            .overlay(Theme.textTertiary.opacity(0.2))
                        Spacer()
                    }
                }

                // Spectrum bars
                HStack(alignment: .bottom, spacing: 1.5) {
                    ForEach(0..<audioEngine.spectrumData.count, id: \.self) { i in
                        SpectrumBarItem(
                            value: CGFloat(audioEngine.spectrumData[i]),
                            index: i,
                            total: audioEngine.spectrumData.count
                        )
                    }
                }
            }
            .frame(height: 200)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.backgroundElevated, lineWidth: 1)
                    )
            )

            // Frequency labels
            HStack {
                Text("1 kHz")
                Spacer()
                Text("2 kHz")
                Spacer()
                Text("3 kHz")
                Spacer()
                Text("4 kHz")
            }
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(Theme.textTertiary)
        }
    }

    private var audioLevelMeter: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("AUDIO LEVEL")
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.textTertiary)
                    .tracking(2)

                Spacer()

                Text(String(format: "%.0f%%", audioEngine.audioLevel * 100))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.backgroundCard)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Theme.ribbitGreen, Theme.accentAmber, Theme.accentRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(audioEngine.audioLevel))
                        .animation(.easeOut(duration: 0.1), value: audioEngine.audioLevel)
                }
            }
            .frame(height: 12)
        }
    }

    private var monitorControls: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring) {
                    isMonitoring.toggle()
                    if isMonitoring {
                        audioEngine.startReceiving()
                    } else {
                        audioEngine.stopReceiving()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isMonitoring ? "stop.fill" : "mic.fill")
                        .font(.body)
                    Text(isMonitoring ? "Stop Monitor" : "Start Monitor")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isMonitoring ? Theme.accentRed : Theme.ribbitGreen)
                )
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: isMonitoring)
        }
    }

    private var infoPanel: some View {
        VStack(spacing: 12) {
            InfoRow(label: "Mode", value: "Ribbit OFDM", icon: "waveform.path")
            InfoRow(label: "Bandwidth", value: "3.2 kHz", icon: "arrow.left.and.right")
            InfoRow(label: "Carriers", value: "64 subcarriers", icon: "chart.bar.fill")
            InfoRow(label: "Symbol Rate", value: "~67 sym/s", icon: "speedometer")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.backgroundCard)
        )
    }
}

struct SpectrumBarItem: View {
    let value: CGFloat
    let index: Int
    let total: Int

    private var barColor: Color {
        let hue = 0.33 - Double(value) * 0.33 // Green to red
        return Color(hue: max(0, hue), saturation: 0.8, brightness: 0.6 + Double(value) * 0.4)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(barColor)
            .frame(height: max(2, value * 180))
            .animation(.easeOut(duration: 0.08), value: value)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Theme.ribbitGreen)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(.subheadline, design: .monospaced, weight: .medium))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

#Preview {
    SpectrumView()
        .environmentObject(AudioEngine())
}
