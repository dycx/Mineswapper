import SwiftUI

struct ScoreBarView: View {
    let remainingMines: Int
    let formattedTime: String
    let gameState: GameState
    let onNewGame: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "burst.fill")
                    .foregroundStyle(.red)
                Text("\(remainingMines)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText())
            }
            .frame(minWidth: 60)

            Spacer()

            Button(action: onNewGame) {
                Text(faceEmoji)
                    .font(.system(size: 28))
            }
            .buttonStyle(.plain)
            .help("New Game")

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.secondary)
                Text(formattedTime)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText())
                    .monospacedDigit()
            }
            .frame(minWidth: 60)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        )
    }

    private var faceEmoji: String {
        switch gameState {
        case .idle, .playing: return "🙂"
        case .won: return "😎"
        case .lost: return "😵"
        }
    }
}
