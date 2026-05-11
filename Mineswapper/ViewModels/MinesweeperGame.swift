// MinesweeperGame.swift
// Mineswapper - Game ViewModel with self-playing AI

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
    
    // AI Integration
    let aiEngine = AIEngine()
    let analytics = AnalyticsService()
    
    private(set) var currentAnalysis: AIAnalysis?
    private(set) var probabilityMap: ProbabilityMap?
    private(set) var currentGameRecord: GameRecord?
    private(set) var showProbabilities = false
    private(set) var lastStrategy: AIStrategy?
    
    // Self-play mode
    private(set) var isSelfPlaying = false
    private(set) var selfPlaySpeed: Double = 0.3
    private(set) var gamesPlayed = 0
    private(set) var gamesWon = 0
    private(set) var currentWinRate: Double = 0.0
    private(set) var selfPlayStatus = "Ready"
    private(set) var isThinking = false
    
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
            currentGameRecord = analytics.startGame(difficulty: difficulty)
        }
        
        let revealedPositions = grid.reveal(row: row, column: column)
        
        // Record move
        let moveResult: MoveResult = grid[row: row, column: column].isMine ? .mine : .safe
        let strategy = lastStrategy ?? .human
        let move = MoveRecord(
            position: (row, column),
            moveType: .reveal,
            strategy: strategy,
            mineProbability: probabilityMap?.probability(row: row, column: column),
            result: moveResult
        )
        if currentGameRecord != nil {
            analytics.recordMove(move, in: &currentGameRecord!)
        }
        
        if grid[row: row, column: column].isMine {
            state = .lost
            explodedRow = row
            explodedColumn = column
            revealAllMines()
            stopTimer()
            if currentGameRecord != nil {
                analytics.finishGame(&currentGameRecord!, outcome: .lost)
            }
            handleGameEnd()
            return
        }
        
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
        currentAnalysis = nil
        probabilityMap = nil
        currentGameRecord = nil
        lastStrategy = nil
        isThinking = false
    }
    
    func changeDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
        newGame()
    }
    
    // MARK: - AI Integration
    
    /// Update AI analysis synchronously (for self-play)
    private func updateAnalysisSync() {
        guard state == .playing else { return }
        let analysis = aiEngine.analyze(grid: grid)
        currentAnalysis = analysis
        probabilityMap = analysis.probabilityMap
    }
    
    /// Execute one AI move
    private func executeOneAIMove() {
        guard state == .playing else { return }
        
        isThinking = true
        
        // Update analysis
        updateAnalysisSync()
        
        guard let analysis = currentAnalysis else {
            isThinking = false
            return
        }
        
        // First, flag any guaranteed mines
        for (r, c) in analysis.mineCells {
            if !grid[row: r, column: c].isFlagged {
                toggleFlag(row: r, column: c)
            }
        }
        
        // Then reveal the recommended safe cell
        if let move = analysis.recommendedMove {
            lastStrategy = analysis.strategy
            reveal(row: move.0, column: move.1)
            lastStrategy = nil
        } else {
            // No recommendation, make a random guess (safest probability)
            let unrevealed = getUnrevealedCells()
            if let guess = unrevealed.randomElement() {
                lastStrategy = .guess
                reveal(row: guess.0, column: guess.1)
                lastStrategy = nil
            }
        }
        
        isThinking = false
    }
    
    // MARK: - Self-Play Mode
    
    /// Start self-play mode
    func startSelfPlay() {
        guard !isSelfPlaying else { return }
        isSelfPlaying = true
        gamesPlayed = 0
        gamesWon = 0
        currentWinRate = 0.0
        
        // Start first game
        startNewSelfPlayGame()
    }
    
    /// Stop self-play mode
    func stopSelfPlay() {
        isSelfPlaying = false
        selfPlayStatus = "Stopped"
        stopSelfPlayTimer()
    }
    
    /// Start a new game in self-play mode
    private func startNewSelfPlayGame() {
        guard isSelfPlaying else { return }
        
        // Reset game
        newGame()
        selfPlayStatus = "Game \(gamesPlayed + 1) playing..."
        
        // Start the game with a random first click
        let row = Int.random(in: 0..<grid.rows)
        let column = Int.random(in: 0..<grid.columns)
        lastStrategy = .guess
        reveal(row: row, column: column)
        lastStrategy = nil
        
        // Start making moves with timer
        startSelfPlayTimer()
    }
    
    private var selfPlayTimer: Timer?
    
    /// Start the self-play timer
    private func startSelfPlayTimer() {
        stopSelfPlayTimer()
        
        // Create timer on main run loop
        selfPlayTimer = Timer.scheduledTimer(withTimeInterval: selfPlaySpeed, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Check if game is over
            if self.state == .won || self.state == .lost {
                self.handleGameEnd()
                return
            }
            
            // Make one move
            self.executeOneAIMove()
        }
    }
    
    /// Stop the self-play timer
    private func stopSelfPlayTimer() {
        selfPlayTimer?.invalidate()
        selfPlayTimer = nil
    }
    
    /// Handle game end in self-play mode
    private func handleGameEnd() {
        guard isSelfPlaying else { return }
        
        // Update statistics
        gamesPlayed += 1
        if state == .won {
            gamesWon += 1
        }
        currentWinRate = Double(gamesWon) / Double(gamesPlayed)
        selfPlayStatus = "Game \(gamesPlayed): \(state == .won ? "Won ✓" : "Lost ✗"). Win rate: \(Int(currentWinRate * 100))%"
        
        // Update strategy based on results
        updateStrategy()
        
        // Stop current timer
        stopSelfPlayTimer()
        
        // Start new game after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self, self.isSelfPlaying else { return }
            self.startNewSelfPlayGame()
        }
    }
    
    /// Update AI strategy based on game results
    private func updateStrategy() {
        // Adjust Monte Carlo samples based on win rate
        if currentWinRate < 0.3 && gamesPlayed >= 3 {
            // Low win rate - increase samples for better accuracy
            aiEngine.monteCarloSamples = min(1000, aiEngine.monteCarloSamples + 100)
        } else if currentWinRate > 0.7 && gamesPlayed >= 5 {
            // High win rate - can reduce samples for speed
            aiEngine.monteCarloSamples = max(100, aiEngine.monteCarloSamples - 50)
        }
    }
    
    /// Set self-play speed
    func setSelfPlaySpeed(_ speed: Double) {
        selfPlaySpeed = max(0.05, min(1.0, speed))
        if isSelfPlaying {
            startSelfPlayTimer()
        }
    }
    
    // MARK: - Helper
    
    private func getUnrevealedCells() -> [(Int, Int)] {
        var cells: [(Int, Int)] = []
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                let cell = grid[row: r, column: c]
                if !cell.isRevealed && !cell.isFlagged {
                    cells.append((r, c))
                }
            }
        }
        return cells
    }
    
    // MARK: - Probability Display
    
    func toggleProbabilities() {
        showProbabilities.toggle()
        if showProbabilities {
            updateAnalysisSync()
        }
    }
    
    /// Get hint from AI
    func getHint() -> String {
        guard state == .playing else { return "Start a game first." }
        
        updateAnalysisSync()
        
        if let analysis = currentAnalysis, let move = analysis.recommendedMove {
            return "Try cell (\(move.0 + 1), \(move.1 + 1)). \(analysis.explanation)"
        }
        
        return "No safe move found. Try a corner or edge cell."
    }
    
    func probability(row: Int, column: Int) -> Double? {
        guard showProbabilities else { return nil }
        return probabilityMap?.probability(row: row, column: column)
    }
    
    func isRecommended(row: Int, column: Int) -> Bool {
        guard let analysis = currentAnalysis,
              let move = analysis.recommendedMove else { return false }
        return move.0 == row && move.1 == column
    }
    
    func isGuaranteedMine(row: Int, column: Int) -> Bool {
        currentAnalysis?.mineCells.contains { $0.0 == row && $0.1 == column } ?? false
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
            if currentGameRecord != nil {
                analytics.finishGame(&currentGameRecord!, outcome: .won)
            }
            handleGameEnd()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
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
