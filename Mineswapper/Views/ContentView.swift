import SwiftUI

struct ContentView: View {
    @State private var game = MinesweeperGame(difficulty: .beginner)

    private var boardWidth: CGFloat {
        CGFloat(game.grid.columns) * (Constants.cellSize + 1) + Constants.boardPadding * 2
    }

    private var boardHeight: CGFloat {
        CGFloat(game.grid.rows) * (Constants.cellSize + 1) + Constants.boardPadding * 2
    }

    var body: some View {
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
    }
}
