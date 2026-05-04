import Foundation

struct Grid: Equatable, Sendable {
    let rows: Int
    let columns: Int
    let mineCount: Int
    private(set) var cells: [[Cell]]
    /// Actual number of mines placed (may be less than mineCount on small grids).
    private(set) var actualMineCount: Int = 0

    init(rows: Int, columns: Int, mineCount: Int) {
        self.rows = rows
        self.columns = columns
        self.mineCount = mineCount
        self.cells = Array(
            repeating: Array(repeating: Cell(), count: columns),
            count: rows
        )
    }

    // MARK: - Safe Access

    /// Optional access — returns nil for out-of-bounds positions.
    func cell(at row: Int, _ column: Int) -> Cell? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return cells[row][column]
    }

    /// Non-optional subscript for known-valid positions. Traps in debug if out-of-bounds.
    subscript(row row: Int, column column: Int) -> Cell {
        get {
            precondition(isValidPosition(row: row, column: column),
                         "Grid subscript out of bounds: (\(row), \(column)) in \(rows)x\(columns) grid")
            return cells[row][column]
        }
        set {
            precondition(isValidPosition(row: row, column: column),
                         "Grid subscript out of bounds: (\(row), \(column)) in \(rows)x\(columns) grid")
            cells[row][column] = newValue
        }
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

    // MARK: - Mine Placement

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
        actualMineCount = minePositions.count
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

    // MARK: - Reveal (iterative flood-fill)

    @discardableResult
    mutating func reveal(row: Int, column: Int) -> [(Int, Int)] {
        guard isValidPosition(row: row, column: column) else { return [] }
        guard !cells[row][column].isRevealed else { return [] }
        guard !cells[row][column].isFlagged else { return [] }

        cells[row][column].isRevealed = true
        var revealed = [(row, column)]

        if cells[row][column].isMine {
            return revealed
        }

        // Iterative flood-fill using a queue (avoids stack overflow on large grids)
        if cells[row][column].adjacentMines == 0 {
            var queue = neighbors(row: row, column: column)
            while let (nr, nc) = queue.popLast() {
                guard !cells[nr][nc].isRevealed, !cells[nr][nc].isFlagged else { continue }
                cells[nr][nc].isRevealed = true
                revealed.append((nr, nc))
                if cells[nr][nc].adjacentMines == 0 {
                    queue.append(contentsOf: neighbors(row: nr, column: nc))
                }
            }
        }

        return revealed
    }
}
