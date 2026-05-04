import XCTest
@testable import Mineswapper

final class GameLogicTests: XCTestCase {
    func testNewGameStartsIdle() {
        let game = MinesweeperGame(difficulty: .beginner)
        XCTAssertEqual(game.state, .idle)
    }

    func testFirstClickStartsGame() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.reveal(row: 4, column: 4)
        XCTAssertEqual(game.state, .playing)
    }

    func testFirstClickIsAlwaysSafe() {
        for _ in 0..<20 {
            let game = MinesweeperGame(difficulty: .beginner)
            game.reveal(row: 4, column: 4)
            XCTAssertNotEqual(game.state, .lost, "First click should never lose")
        }
    }

    func testFlagToggle() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.toggleFlag(row: 0, column: 0)
        XCTAssertTrue(game.grid.cell(at: 0, 0)!.isFlagged)
        game.toggleFlag(row: 0, column: 0)
        XCTAssertFalse(game.grid.cell(at: 0, 0)!.isFlagged)
    }

    func testCannotFlagRevealedCell() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.reveal(row: 4, column: 4)
        game.toggleFlag(row: 4, column: 4)
        XCTAssertFalse(game.grid.cell(at: 4, 4)!.isFlagged)
    }

    func testMineCounterUpdates() {
        let game = MinesweeperGame(difficulty: .beginner)
        XCTAssertEqual(game.remainingMines, 10)
        game.toggleFlag(row: 0, column: 0)
        XCTAssertEqual(game.remainingMines, 9)
        game.toggleFlag(row: 0, column: 1)
        XCTAssertEqual(game.remainingMines, 8)
        game.toggleFlag(row: 0, column: 0)
        XCTAssertEqual(game.remainingMines, 9)
    }

    func testWinCondition() {
        let game = MinesweeperGame(difficulty: .custom(rows: 2, columns: 2, mines: 1))
        game.reveal(row: 0, column: 0)
        for r in 0..<2 {
            for c in 0..<2 {
                if !game.grid.cell(at: r, c)!.isMine {
                    game.reveal(row: r, column: c)
                }
            }
        }
        XCTAssertEqual(game.state, .won)
    }

    func testLoseOnMine() {
        let game = MinesweeperGame(difficulty: .custom(rows: 2, columns: 2, mines: 1))
        game.reveal(row: 0, column: 0)
        for r in 0..<2 {
            for c in 0..<2 {
                if game.grid.cell(at: r, c)!.isMine {
                    game.reveal(row: r, column: c)
                    XCTAssertEqual(game.state, .lost)
                    return
                }
            }
        }
    }

    func testChordClick() {
        let game = MinesweeperGame(difficulty: .custom(rows: 3, columns: 3, mines: 0))
        game.grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        game.grid.calculateAdjacentMines()
        game.reveal(row: 1, column: 1)
        game.toggleFlag(row: 0, column: 0)
        game.chordReveal(row: 1, column: 1)
        XCTAssertTrue(game.grid.cell(at: 0, 1)!.isRevealed)
        XCTAssertTrue(game.grid.cell(at: 1, 0)!.isRevealed)
    }

    func testNewGameResetsState() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.reveal(row: 0, column: 0)
        game.toggleFlag(row: 5, column: 5)
        game.newGame()
        XCTAssertEqual(game.state, .idle)
        XCTAssertEqual(game.remainingMines, 10)
        for r in 0..<9 {
            for c in 0..<9 {
                XCTAssertFalse(game.grid.cell(at: r, c)!.isRevealed)
                XCTAssertFalse(game.grid.cell(at: r, c)!.isFlagged)
            }
        }
    }
}
