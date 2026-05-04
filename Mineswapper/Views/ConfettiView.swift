import SwiftUI

struct ConfettiView: View {
    let isActive: Bool
    @State private var particles: [Particle] = []
    @State private var animationTimer: Timer?

    private struct Particle: Identifiable {
        let id = UUID()
        let color: Color
        let startX: CGFloat
        let size: CGFloat
        var yOffset: CGFloat = 0
        var opacity: Double = 1
        var rotation: Double = 0
    }

    private static let colors: [Color] = [
        .red, .blue, .green, .orange, .purple, .yellow, .pink, .cyan
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(
                            x: particle.startX,
                            y: geo.size.height + particle.yOffset
                        )
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startConfetti()
            } else {
                stopConfetti()
            }
        }
    }

    private func startConfetti() {
        particles = []
        animationTimer?.invalidate()

        let startTime = Date()

        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)

            if elapsed > 2.5 {
                timer.invalidate()
                particles = []
                return
            }

            // Add new particles
            if elapsed < 1.5 {
                for _ in 0..<3 {
                    let particle = Particle(
                        color: Self.colors.randomElement()!,
                        startX: CGFloat.random(in: 20...380),
                        size: CGFloat.random(in: 4...10)
                    )
                    particles.append(particle)
                }
            }

            // Animate existing particles
            for i in particles.indices {
                withAnimation(.linear(duration: 0.03)) {
                    particles[i].yOffset -= CGFloat.random(in: 3...8)
                    particles[i].opacity -= 0.008
                    particles[i].rotation += Double.random(in: 2...8)
                }
            }

            // Remove dead particles
            particles.removeAll { $0.opacity <= 0 }
        }
    }

    private func stopConfetti() {
        animationTimer?.invalidate()
        animationTimer = nil
        particles = []
    }
}
