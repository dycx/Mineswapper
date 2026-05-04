import Foundation

struct Grid: Equatable, Sendable {
    let rows: Int
    let columns: Int
    let mineCount: Int
    private(set) var cells: [[Cell]]

    init(rows: Int, columns: Int, mineCount: Int) {
        self.rows = rows
        self.columns = columns
        self.mineCount = mineCount
        self.cells = Array(
            repeating: Array(repeating: Cell(), count: columns),
            count: rows
        )
    }

    func cell(at row: Int, _ column: Int) -> Cell? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return cells[row][column]
    }

    mutating func setCell(at row: Int, _ column: Int, cell: Cell) {
        guard isValidPosition(row: row, column: column) else { return }
        cells[row][column] = cell
    }

    func isValidPosition(row: Int, column: Int) -> Bool {
        row >= 0 && row < rows && column >= 0 && column < columns
    }

    func neighbors(row: Int, column: Int) -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = row + dr
                let nc = column + dc
                if isValidPosition(row: nr, column: nc) {
                    result.append((nr, nc))
                }
            }
        }
        return result
    }

    mutating func placeMines(excludingRow safeRow: Int, column safeCol: Int) {
        var positions: [(Int, Int)] = []
        for r in 0..<rows {
            for c in 0..<columns {
                let isSafeZone = abs(r - safeRow) <= 1 && abs(c - safeCol) <= 1
                if !isSafeZone {
                    positions.append((r, c))
                }
            }
        }
        let shuffled = positions.shuffled()
        let minePositions = shuffled.prefix(mineCount)
        for (r, c) in minePositions {
            cells[r][c].isMine = true
        }
    }

    mutating func calculateAdjacentMines() {
        for r in 0..<rows {
            for c in 0..<columns {
                if cells[r][c].isMine { continue }
                let count = neighbors(row: r, column: c)
                    .filter { cells[$0.0][$0.1].isMine }
                    .count
                cells[r][c].adjacentMines = count
            }
        }
    }
}
