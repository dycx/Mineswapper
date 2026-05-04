import XCTest
@testable import Mineswapper

final class FloodFillTests: XCTestCase {
    func testRevealSingleCell() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        let revealed = grid.reveal(row: 1, column: 1)
        XCTAssertTrue(grid.cell(at: 1, 1)!.isRevealed)
        XCTAssertEqual(revealed.count, 1)
    }

    func testFloodFillRevealsEmptyRegion() {
        var grid = Grid(rows: 5, columns: 5, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        let revealed = grid.reveal(row: 4, column: 4)
        XCTAssertTrue(grid.cell(at: 4, 4)!.isRevealed)
        XCTAssertTrue(revealed.count > 1)
        XCTAssertFalse(grid.cell(at: 0, 0)!.isRevealed)
    }

    func testFloodFillStopsAtNumbers() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        let _ = grid.reveal(row: 2, column: 2)
        XCTAssertTrue(grid.cell(at: 2, 2)!.isRevealed)
        XCTAssertTrue(grid.cell(at: 1, 1)!.isRevealed)
        XCTAssertFalse(grid.cell(at: 0, 0)!.isRevealed)
    }

    func testRevealMineReturnsAllMines() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.setCell(at: 2, 2, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        grid.reveal(row: 0, column: 0)
        XCTAssertTrue(grid.cell(at: 0, 0)!.isRevealed)
    }

    func testRevealFlaggedCellDoesNothing() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 1, 1, cell: Cell(isFlagged: true))
        let revealed = grid.reveal(row: 1, column: 1)
        XCTAssertTrue(revealed.isEmpty)
        XCTAssertFalse(grid.cell(at: 1, 1)!.isRevealed)
    }

    func testRevealAlreadyRevealedCellDoesNothing() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 1, 1, cell: Cell(isRevealed: true))
        let revealed = grid.reveal(row: 1, column: 1)
        XCTAssertTrue(revealed.isEmpty)
    }
}
