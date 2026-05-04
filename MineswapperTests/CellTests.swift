import XCTest
@testable import Mineswapper

final class CellTests: XCTestCase {
    func testDefaultCellIsNotMine() {
        let cell = Cell()
        XCTAssertFalse(cell.isMine)
        XCTAssertFalse(cell.isRevealed)
        XCTAssertFalse(cell.isFlagged)
        XCTAssertEqual(cell.adjacentMines, 0)
    }

    func testCellAsMine() {
        var cell = Cell()
        cell.isMine = true
        XCTAssertTrue(cell.isMine)
    }

    func testRevealCell() {
        var cell = Cell()
        cell.isRevealed = true
        XCTAssertTrue(cell.isRevealed)
    }

    func testFlagCell() {
        var cell = Cell()
        cell.isFlagged = true
        XCTAssertTrue(cell.isFlagged)
    }

    func testCannotRevealFlaggedCell() {
        var cell = Cell()
        cell.isFlagged = true
        cell.isRevealed = true
        XCTAssertTrue(cell.isFlagged)
        XCTAssertTrue(cell.isRevealed)
    }

    func testAdjacentMinesCanBeSet() {
        var cell = Cell()
        cell.adjacentMines = 3
        XCTAssertEqual(cell.adjacentMines, 3)
    }
}
