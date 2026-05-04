import SwiftUI

struct ConfettiView: View {
    let isActive: Bool
    @State private var particles: [Particle] = []
    @State private var spawnTask: Task<Void, Never>?

    private struct Particle: Identifiable {
        let id = UUID()
        let color: Color
        let startX: Double
        let size: Double
        var endY: Double = 0
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
                        .position(x: particle.startX, y: particle.endY)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
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
        spawnTask?.cancel()

        spawnTask = Task { @MainActor in
            // Spawn particles in batches
            for _ in 0..<12 {
                guard !Task.isCancelled else { return }
                spawnBatch()
                try? await Task.sleep(for: .milliseconds(120))
            }
        }

        // Auto-cleanup after animation completes
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(2800))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                particles = []
            }
        }
    }

    private func spawnBatch() {
        let newParticles = (0..<5).map { _ in
            Particle(
                color: Self.colors.randomElement()!,
                startX: Double.random(in: 20...380),
                size: Double.random(in: 4...10),
                endY: Double.random(in: -50...20),
                rotation: Double.random(in: 0...360)
            )
        }
        particles.append(contentsOf: newParticles)

        // Animate each batch falling and fading
        withAnimation(.easeIn(duration: 2.0)) {
            for i in particles.indices {
                particles[i].endY += Double.random(in: 400...600)
                particles[i].opacity = 0
                particles[i].rotation += Double.random(in: 180...720)
            }
        }
    }

    private func stopConfetti() {
        spawnTask?.cancel()
        spawnTask = nil
        withAnimation(.easeOut(duration: 0.2)) {
            particles = []
        }
    }
}
