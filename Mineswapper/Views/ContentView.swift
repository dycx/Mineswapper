import SwiftUI
import AppKit

struct ContentView: View {
    @State private var game = MinesweeperGame(difficulty: .beginner)
    @State private var showWinAlert = false
    @State private var showLoseAlert = false
    @State private var showConfetti = false

    private var boardWidth: CGFloat {
        CGFloat(game.grid.columns) * (Constants.cellSize + 1) + Constants.boardPadding * 2
    }

    private var boardHeight: CGFloat {
        CGFloat(game.grid.rows) * (Constants.cellSize + 1) + Constants.boardPadding * 2
    }

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                ScoreBarView(
                    remainingMines: game.remainingMines,
                    formattedTime: game.formattedTime,
                    gameState: game.state,
                    onNewGame: { game.newGame() }
                )

                GameBoardView(game: game)
            }
            .padding(16)
            .frame(width: boardWidth + 32, height: boardHeight + 100)

            if showConfetti {
                ConfettiView(isActive: showConfetti)
                    .transition(.opacity)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                DifficultyPickerView(difficulty: Binding(
                    get: { game.difficulty },
                    set: { game.changeDifficulty($0) }
                ))
            }
            ToolbarItem(placement: .primaryAction) {
                Button("New Game") {
                    game.newGame()
                }
            }
        }
        .alert("You Won!", isPresented: $showWinAlert) {
            Button("New Game") {
                showConfetti = false
                game.newGame()
            }
            Button("OK") {
                showConfetti = false
            }
        } message: {
            Text("Time: \(game.formattedTime)")
        }
        .alert("Game Over", isPresented: $showLoseAlert) {
            Button("New Game") {
                game.newGame()
            }
            Button("OK") { }
        } message: {
            Text("You hit a mine!")
        }
        .onChange(of: game.state) { _, newValue in
            if newValue == .won {
                NSSound(named: "Hero")?.play()
                showConfetti = true
                showWinAlert = true
            } else if newValue == .lost {
                NSSound(named: "Funk")?.play()
                showLoseAlert = true
            }
        }
    }
}
