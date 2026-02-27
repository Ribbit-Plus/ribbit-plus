import SwiftUI

struct SpectrumBar: View {
    let data: [Float]

    var body: some View {
        HStack(alignment: .bottom, spacing: 1) {
            ForEach(0..<data.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(barColor(for: data[i]))
                    .frame(height: max(1, CGFloat(data[i]) * 50))
                    .animation(.easeOut(duration: 0.08), value: data[i])
            }
        }
        .padding(.vertical, 4)
    }

    private func barColor(for value: Float) -> Color {
        let v = Double(value)
        if v > 0.7 {
            return Theme.ribbitGreenLight
        } else if v > 0.3 {
            return Theme.ribbitGreen
        } else {
            return Theme.ribbitGreenDark.opacity(0.6)
        }
    }
}

struct WaveformView: View {
    let isActive: Bool
    @State private var phase = 0.0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let midY = size.height / 2
                let width = size.width

                var path = Path()
                path.move(to: CGPoint(x: 0, y: midY))

                let time: Double = timeline.date.timeIntervalSinceReferenceDate

                for x in stride(from: CGFloat(0), through: width, by: 2) {
                    let relX: Double = Double(x / width)
                    let amplitude: Double = isActive ? Double(size.height) * 0.35 : Double(size.height) * 0.05
                    let wave1: Double = sin(relX * .pi * 4 + time * 3)
                    let wave2: Double = cos(relX * .pi * 2 + time * 1.5)
                    let wave3: Double = sin(relX * .pi + time * 2)
                    let y: CGFloat = midY + CGFloat(amplitude * wave1 * wave2 * wave3)
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [
                            Theme.ribbitGreen.opacity(0.3),
                            Theme.ribbitGreen,
                            Theme.ribbitGreenLight,
                            Theme.ribbitGreen,
                            Theme.ribbitGreen.opacity(0.3),
                        ]),
                        startPoint: .zero,
                        endPoint: CGPoint(x: width, y: 0)
                    ),
                    lineWidth: 2
                )

                // Glow effect
                context.stroke(
                    path,
                    with: .color(Theme.ribbitGreen.opacity(0.2)),
                    lineWidth: 6
                )
            }
        }
    }
}

struct PulsingDot: View {
    let color: Color
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color, radius: isPulsing ? 8 : 2)
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

#Preview {
    VStack(spacing: 20) {
        SpectrumBar(data: (0..<64).map { _ in Float.random(in: 0...1) })
            .frame(height: 60)

        WaveformView(isActive: true)
            .frame(height: 100)
    }
    .padding()
    .background(Theme.backgroundDark)
}
