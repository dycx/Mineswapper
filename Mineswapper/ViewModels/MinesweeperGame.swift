import Foundation
import SwiftUI

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

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.grid = Grid(
            rows: difficulty.rows,
            columns: difficulty.columns,
            mineCount: difficulty.mineCount
        )
        self.remainingMines = difficulty.mineCount
    }

    func reveal(row: Int, column: Int) {
        guard state == .idle || state == .playing else { return }
        guard !grid.cell(at: row, column)!.isFlagged else { return }
        guard !grid.cell(at: row, column)!.isRevealed else { return }

        if isFirstClick {
            grid.placeMines(excludingRow: row, column: column)
            grid.calculateAdjacentMines()
            isFirstClick = false
            state = .playing
            startTimer()
        }

        grid.reveal(row: row, column: column)

        if grid.cell(at: row, column)!.isMine {
            state = .lost
            explodedRow = row
            explodedColumn = column
            revealAllMines()
            stopTimer()
            return
        }

        checkWin()
    }

    func toggleFlag(row: Int, column: Int) {
        guard state == .idle || state == .playing else { return }
        guard !grid.cell(at: row, column)!.isRevealed else { return }

        var cell = grid.cell(at: row, column)!
        cell.isFlagged.toggle()
        grid.setCell(at: row, column, cell: cell)
        remainingMines = difficulty.mineCount - flagCount()
    }

    func chordReveal(row: Int, column: Int) {
        guard state == .playing else { return }
        let cell = grid.cell(at: row, column)!
        guard cell.isRevealed, cell.adjacentMines > 0 else { return }

        let neighbors = grid.neighbors(row: row, column: column)
        let flaggedCount = neighbors.filter { grid.cell(at: $0.0, $0.1)!.isFlagged }.count

        guard flaggedCount == cell.adjacentMines else { return }

        for (nr, nc) in neighbors {
            if !grid.cell(at: nr, nc)!.isFlagged && !grid.cell(at: nr, nc)!.isRevealed {
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
        explodedRow = nil
        explodedColumn = nil
    }

    func changeDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
        newGame()
    }

    // MARK: - Private

    private func flagCount() -> Int {
        var count = 0
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                if grid.cell(at: r, c)!.isFlagged { count += 1 }
            }
        }
        return count
    }

    private func revealAllMines() {
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                if grid.cell(at: r, c)!.isMine {
                    var cell = grid.cell(at: r, c)!
                    cell.isRevealed = true
                    grid.setCell(at: r, c, cell: cell)
                }
            }
        }
    }

    private func checkWin() {
        var allRevealed = true
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                let cell = grid.cell(at: r, c)!
                if !cell.isMine && !cell.isRevealed {
                    allRevealed = false
                    break
                }
            }
            if !allRevealed { break }
        }
        if allRevealed {
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

    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
