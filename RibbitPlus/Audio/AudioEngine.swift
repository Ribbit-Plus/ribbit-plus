import Foundation
import AVFoundation
import Accelerate
import Combine

@MainActor
class AudioEngine: ObservableObject {
    @Published var isTransmitting = false
    @Published var isReceiving = false
    @Published var spectrumData: [Float] = Array(repeating: 0, count: 64)
    @Published var audioLevel: Float = 0
    @Published var transmitProgress: Double = 0

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var displayLink: CADisplayLink?
    private var spectrumTimer: Timer?

    // OFDM parameters
    private let sampleRate: Double = 48000
    private let carrierFrequencies: [Double] = {
        let base = 1000.0
        let spacing = 50.0
        return (0..<64).map { base + Double($0) * spacing }
    }()

    init() {
        startSpectrumSimulation()
    }

    deinit {
        spectrumTimer?.invalidate()
    }

    func transmitMessage(_ text: String) async {
        guard !isTransmitting else { return }

        isTransmitting = true
        transmitProgress = 0

        do {
            let audioData = generateOFDMSignal(for: text)
            try await playAudio(audioData)
        } catch {
            print("Transmit error: \(error)")
        }

        isTransmitting = false
        transmitProgress = 0
    }

    func startReceiving() {
        guard !isReceiving else { return }
        isReceiving = true
        setupAudioInput()
    }

    func stopReceiving() {
        isReceiving = false
        audioEngine?.stop()
        audioEngine = nil
    }

    // MARK: - OFDM Signal Generation

    private func generateOFDMSignal(for text: String) -> [Float] {
        let bytes = Array(text.utf8)
        let bits = bytes.flatMap { byte -> [UInt8] in
            (0..<8).map { bit in (byte >> (7 - bit)) & 1 }
        }

        let symbolDuration = 0.015 // 15ms per OFDM symbol
        let samplesPerSymbol = Int(sampleRate * symbolDuration)
        let bitsPerSymbol = 64 // one bit per carrier

        // Preamble: chirp for synchronization
        var signal = generateChirp(duration: 0.05, startFreq: 800, endFreq: 4000)

        // OFDM symbols
        var bitIndex = 0
        while bitIndex < bits.count {
            var symbol = [Float](repeating: 0, count: samplesPerSymbol)

            for (carrierIdx, freq) in carrierFrequencies.enumerated() {
                let bit: UInt8 = (bitIndex + carrierIdx < bits.count) ? bits[bitIndex + carrierIdx] : 0
                let phase: Float = bit == 1 ? 0 : .pi

                for sample in 0..<samplesPerSymbol {
                    let t = Float(sample) / Float(sampleRate)
                    symbol[sample] += cos(2.0 * .pi * Float(freq) * t + phase) / Float(carrierFrequencies.count)
                }
            }

            signal.append(contentsOf: symbol)
            bitIndex += bitsPerSymbol
        }

        // Postamble
        signal.append(contentsOf: generateChirp(duration: 0.03, startFreq: 4000, endFreq: 800))

        // Apply window to avoid clicks
        let rampSamples = min(200, signal.count / 4)
        for i in 0..<rampSamples {
            let factor = Float(i) / Float(rampSamples)
            signal[i] *= factor
            signal[signal.count - 1 - i] *= factor
        }

        return signal
    }

    private func generateChirp(duration: Double, startFreq: Double, endFreq: Double) -> [Float] {
        let sampleCount = Int(sampleRate * duration)
        return (0..<sampleCount).map { i in
            let t = Double(i) / sampleRate
            let freq = startFreq + (endFreq - startFreq) * t / duration
            return Float(0.8 * sin(2.0 * .pi * freq * t))
        }
    }

    private func playAudio(_ samples: [Float]) async throws {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count))!
        buffer.frameLength = AVAudioFrameCount(samples.count)
        let channelData = buffer.floatChannelData![0]
        for (i, sample) in samples.enumerated() {
            channelData[i] = sample * 0.7
        }

        try engine.start()
        player.play()
        await player.scheduleBuffer(buffer)

        let duration = Double(samples.count) / sampleRate
        let steps = 50
        for step in 0..<steps {
            try await Task.sleep(nanoseconds: UInt64(duration / Double(steps) * 1_000_000_000))
            transmitProgress = Double(step + 1) / Double(steps)
        }

        player.stop()
        engine.stop()
    }

    // MARK: - Audio Input

    private func setupAudioInput() {
        let engine = AVAudioEngine()
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { [weak self] buffer, _ in
            Task { @MainActor [weak self] in
                self?.processAudioBuffer(buffer)
            }
        }

        do {
            try engine.start()
            audioEngine = engine
        } catch {
            print("Audio input error: \(error)")
            isReceiving = false
        }
    }

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)

        // Calculate RMS level
        var rms: Float = 0
        vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frameCount))
        audioLevel = min(rms * 10, 1.0)

        // Simple spectrum (magnitude of FFT bins)
        let fftSize = min(128, frameCount)
        var realPart = [Float](repeating: 0, count: fftSize)
        for i in 0..<fftSize {
            realPart[i] = channelData[i]
        }

        // Approximate spectrum using windowed DFT bins
        for bin in 0..<64 {
            var magnitude: Float = 0
            let freq = Float(bin * 375) // Spread across audible range
            for i in 0..<fftSize {
                let t = Float(i) / Float(sampleRate)
                magnitude += abs(realPart[i] * cos(2 * .pi * freq * t))
            }
            spectrumData[bin] = min(magnitude / Float(fftSize) * 4, 1.0)
        }
    }

    // MARK: - Spectrum Simulation (for demo)

    private func startSpectrumSimulation() {
        spectrumTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateSimulatedSpectrum()
            }
        }
    }

    private func updateSimulatedSpectrum() {
        guard !isReceiving else { return }

        for i in 0..<spectrumData.count {
            if isTransmitting {
                let centerBin = spectrumData.count / 2
                let distance = abs(i - centerBin)
                let base: Float = max(0, 0.9 - Float(distance) * 0.03)
                spectrumData[i] = base + Float.random(in: -0.1...0.1)
            } else {
                let decay: Float = 0.85
                let noise: Float = Float.random(in: 0...0.08)
                spectrumData[i] = spectrumData[i] * decay + noise
            }
            spectrumData[i] = max(0, min(1, spectrumData[i]))
        }
    }
}
