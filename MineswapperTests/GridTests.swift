import XCTest
@testable import Mineswapper

final class GridTests: XCTestCase {
    func testGridInitialization() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        XCTAssertEqual(grid.rows, 9)
        XCTAssertEqual(grid.columns, 9)
        XCTAssertEqual(grid.mineCount, 10)
    }

    func testGridAllCellsHiddenBeforeFirstClick() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        for row in 0..<9 {
            for col in 0..<9 {
                XCTAssertFalse(grid.cell(at: row, col)!.isRevealed)
                XCTAssertFalse(grid.cell(at: row, col)!.isMine)
            }
        }
    }

    func testPlaceMinesExcludesFirstClick() {
        var grid = Grid(rows: 9, columns: 9, mineCount: 10)
        grid.placeMines(excludingRow: 4, column: 4)
        for dr in -1...1 {
            for dc in -1...1 {
                let r = 4 + dr
                let c = 4 + dc
                if grid.isValidPosition(row: r, column: c) {
                    XCTAssertFalse(grid.cell(at: r, c)!.isMine,
                        "Cell (\(r), \(c)) should not be a mine after first click at (4, 4)")
                }
            }
        }
    }

    func testPlaceMinesCorrectCount() {
        var grid = Grid(rows: 9, columns: 9, mineCount: 10)
        grid.placeMines(excludingRow: 0, column: 0)
        var mineCount = 0
        for row in 0..<9 {
            for col in 0..<9 {
                if grid.cell(at: row, col)!.isMine {
                    mineCount += 1
                }
            }
        }
        XCTAssertEqual(mineCount, 10)
    }

    func testAdjacentMinesCount() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.setCell(at: 2, 2, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        XCTAssertEqual(grid.cell(at: 1, 1)!.adjacentMines, 2)
        XCTAssertEqual(grid.cell(at: 0, 1)!.adjacentMines, 1)
    }

    func testIsValidPosition() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        XCTAssertTrue(grid.isValidPosition(row: 0, column: 0))
        XCTAssertTrue(grid.isValidPosition(row: 8, column: 8))
        XCTAssertFalse(grid.isValidPosition(row: -1, column: 0))
        XCTAssertFalse(grid.isValidPosition(row: 0, column: 9))
        XCTAssertFalse(grid.isValidPosition(row: 9, column: 0))
    }

    func testNeighbors() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        let cornerNeighbors = grid.neighbors(row: 0, column: 0)
        XCTAssertEqual(cornerNeighbors.count, 3)
        let centerNeighbors = grid.neighbors(row: 4, column: 4)
        XCTAssertEqual(centerNeighbors.count, 8)
        let edgeNeighbors = grid.neighbors(row: 0, column: 4)
        XCTAssertEqual(edgeNeighbors.count, 5)
    }
}
