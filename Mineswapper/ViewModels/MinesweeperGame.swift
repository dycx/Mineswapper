import Foundation

@Observable
final class MinesweeperGame {
    var grid: Grid
    private(set) var state: GameState = .idle
    private(set) var difficulty: Difficulty
    private(set) var elapsedTime: Int = 0
    private(set) var remainingMines: Int
    private(set) var explodedRow: Int?
    private(set) var explodedColumn: Int?

    private var timer: Timer?
    private var isFirstClick = true
    private var flagCount = 0
    private var revealedSafeCount = 0

    private var totalSafeCells: Int {
        grid.rows * grid.columns - grid.actualMineCount
    }

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.grid = Grid(
            rows: difficulty.rows,
            columns: difficulty.columns,
            mineCount: difficulty.mineCount
        )
        self.remainingMines = difficulty.mineCount
    }

    // MARK: - Game Actions

    func reveal(row: Int, column: Int) {
        guard state == .idle || state == .playing else { return }
        let cell = grid[row: row, column: column]
        guard !cell.isFlagged else { return }
        guard !cell.isRevealed else { return }

        if isFirstClick {
            grid.placeMines(excludingRow: row, column: column)
            grid.calculateAdjacentMines()
            isFirstClick = false
            state = .playing
            startTimer()
        }

        let revealedPositions = grid.reveal(row: row, column: column)

        if grid[row: row, column: column].isMine {
            state = .lost
            explodedRow = row
            explodedColumn = column
            revealAllMines()
            stopTimer()
            return
        }

        // Track revealed safe cells incrementally
        revealedSafeCount += revealedPositions.filter { (r, c) in
            !grid[row: r, column: c].isMine
        }.count
        checkWin()
    }

    func toggleFlag(row: Int, column: Int) {
        guard state == .idle || state == .playing else { return }
        let cell = grid[row: row, column: column]
        guard !cell.isRevealed else { return }

        grid[row: row, column: column].isFlagged.toggle()
        if grid[row: row, column: column].isFlagged {
            flagCount += 1
        } else {
            flagCount -= 1
        }
        remainingMines = difficulty.mineCount - flagCount
    }

    func chordReveal(row: Int, column: Int) {
        guard state == .playing else { return }
        let cell = grid[row: row, column: column]
        guard cell.isRevealed, cell.adjacentMines > 0 else { return }

        let neighborPositions = grid.neighbors(row: row, column: column)
        let flaggedCount = neighborPositions.filter { grid[row: $0.0, column: $0.1].isFlagged }.count

        guard flaggedCount == cell.adjacentMines else { return }

        for (nr, nc) in neighborPositions {
            if !grid[row: nr, column: nc].isFlagged && !grid[row: nr, column: nc].isRevealed {
                reveal(row: nr, column: nc)
            }
        }
    }

    func newGame() {
        stopTimer()
        grid = Grid(
            rows: difficulty.rows,
            columns: difficulty.columns,
            mineCount: difficulty.mineCount
        )
        state = .idle
        remainingMines = difficulty.mineCount
        elapsedTime = 0
        isFirstClick = true
        flagCount = 0
        revealedSafeCount = 0
        explodedRow = nil
        explodedColumn = nil
    }

    func changeDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
        newGame()
    }

    // MARK: - Computed

    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private

    private func revealAllMines() {
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                if grid[row: r, column: c].isMine {
                    grid[row: r, column: c].isRevealed = true
                }
            }
        }
    }

    private func checkWin() {
        if revealedSafeCount == totalSafeCells {
            state = .won
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
