// AISelfPlayTests.swift
// Mineswapper Tests - AI Self-Play

import XCTest
@testable import Mineswapper

final class AISelfPlayTests: XCTestCase {
    
    // MARK: - Grid Tests
    
    func testGridInitialization() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        XCTAssertEqual(grid.rows, 9)
        XCTAssertEqual(grid.columns, 9)
        XCTAssertEqual(grid.mineCount, 10)
    }
    
    func testGridPlaceMinesExcludingSafeZone() {
        var grid = Grid(rows: 9, columns: 9, mineCount: 10)
        grid.placeMines(excludingRow: 4, column: 4)
        
        // Safe zone (3x3 around 4,4) should not have mines
        for r in 3...5 {
            for c in 3...5 {
                XCTAssertFalse(grid[row: r, column: c].isMine, "Cell (\(r),\(c)) should not be a mine")
            }
        }
    }
    
    func testGridRevealFloodFill() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.calculateAdjacentMines()
        let revealed = grid.reveal(row: 1, column: 1)
        XCTAssertEqual(revealed.count, 9)
    }
    
    func testGridNeighbors() {
        let grid = Grid(rows: 3, columns: 3, mineCount: 0)
        let cornerNeighbors = grid.neighbors(row: 0, column: 0)
        let centerNeighbors = grid.neighbors(row: 1, column: 1)
        XCTAssertEqual(cornerNeighbors.count, 3)
        XCTAssertEqual(centerNeighbors.count, 8)
    }
    
    // MARK: - Game State Tests
    
    func testNewGameStartsInIdleState() {
        let game = MinesweeperGame(difficulty: .beginner)
        XCTAssertEqual(game.state, .idle)
        XCTAssertEqual(game.remainingMines, 10)
    }
    
    func testFirstClickStartsGame() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.reveal(row: 0, column: 0)
        XCTAssertEqual(game.state, .playing)
    }
    
    // MARK: - AI Engine Tests
    
    func testAIEngineAnalyzesBoard() {
        var grid = Grid(rows: 9, columns: 9, mineCount: 10)
        grid.placeMines(excludingRow: 0, column: 0)
        grid.calculateAdjacentMines()
        let _ = grid.reveal(row: 0, column: 0)
        
        let engine = AIEngine()
        let analysis = engine.analyze(grid: grid)
        
        // Should recommend a move
        XCTAssertNotNil(analysis.recommendedMove)
        XCTAssertTrue(analysis.hasRecommendation)
    }
    
    // MARK: - Analytics Tests
    
    func testAnalyticsRecordsMoves() {
        let analytics = AnalyticsService()
        var record = analytics.startGame(difficulty: .beginner)
        
        let move = MoveRecord(
            position: (0, 0),
            moveType: .reveal,
            strategy: .human,
            result: .safe
        )
        analytics.recordMove(move, in: &record)
        
        XCTAssertEqual(record.totalMoves, 1)
    }
    
    func testAnalyticsCalculatesWinRate() {
        let analytics = AnalyticsService()
        analytics.clearAll()
        
        var record1 = analytics.startGame(difficulty: .beginner)
        analytics.finishGame(&record1, outcome: .won)
        
        var record2 = analytics.startGame(difficulty: .beginner)
        analytics.finishGame(&record2, outcome: .lost)
        
        XCTAssertEqual(analytics.winRate, 0.5, accuracy: 0.01)
    }
    
    // MARK: - Self-Play Tests
    
    func testSelfPlayStartsAndStops() {
        let game = MinesweeperGame(difficulty: .beginner)
        
        game.startSelfPlay()
        XCTAssertTrue(game.isSelfPlaying)
        XCTAssertEqual(game.state, .playing)
        
        game.stopSelfPlay()
        XCTAssertFalse(game.isSelfPlaying)
    }
    
    func testSelfPlayStatusUpdates() {
        let game = MinesweeperGame(difficulty: .beginner)
        
        XCTAssertEqual(game.selfPlayStatus, "Ready")
        
        game.startSelfPlay()
        XCTAssertTrue(game.selfPlayStatus.contains("Game"))
        
        game.stopSelfPlay()
        XCTAssertEqual(game.selfPlayStatus, "Stopped")
    }
}
