// AIEngine.swift
// Mineswapper AI - Unified AI interface
//
// Combines constraint-based solving and Monte Carlo simulation
// into a single, easy-to-use interface.

import Foundation

/// AI strategy used for a move
enum AIStrategy: String, Codable, CaseIterable {
    case constraint    // Deterministic deduction
    case monteCarlo    // Probabilistic simulation
    case guess         // Pure guess (no information)
    case human         // Human player move
    
    var displayName: String {
        switch self {
        case .constraint: return "Logical Deduction"
        case .monteCarlo: return "Monte Carlo Simulation"
        case .guess: return "Educated Guess"
        case .human: return "Human Move"
        }
    }
    
    var icon: String {
        switch self {
        case .constraint: return "brain"
        case .monteCarlo: return "dice"
        case .guess: return "questionmark.circle"
        case .human: return "hand.point.up.left"
        }
    }
}

/// Result of AI analysis
struct AIAnalysis {
    /// Recommended cell to reveal
    let recommendedMove: (Int, Int)?
    /// Strategy that determined this move
    let strategy: AIStrategy
    /// Confidence level (0.0 - 1.0)
    let confidence: Double
    /// All safe cells found by constraint solver
    let safeCells: [(Int, Int)]
    /// All mine cells found by constraint solver
    let mineCells: [(Int, Int)]
    /// Probability map from Monte Carlo (if used)
    let probabilityMap: ProbabilityMap?
    /// Human-readable explanation
    let explanation: String
    
    /// Whether the AI has a recommendation
    var hasRecommendation: Bool {
        recommendedMove != nil || !safeCells.isEmpty || !mineCells.isEmpty
    }
}

/// Unified AI engine for Minesweeper
///
/// Coordinates between constraint solver and Monte Carlo simulation
/// to provide the best possible move recommendations.
final class AIEngine {
    
    /// Constraint-based solver
    private let constraintSolver = ConstraintSolver()
    
    /// Monte Carlo solver
    private let monteCarloSolver = MonteCarloSolver()
    
    /// Number of Monte Carlo samples
    var monteCarloSamples: Int {
        get { monteCarloSolver.sampleCount }
        set { monteCarloSolver.sampleCount = newValue }
    }
    
    // MARK: - Public API
    
    /// Analyze the current game state and recommend a move
    /// - Parameter grid: The current game grid
    /// - Returns: AIAnalysis with recommendations
    func analyze(grid: Grid) -> AIAnalysis {
        // Phase 1: Try constraint-based solving
        let constraintResult = constraintSolver.analyze(grid: grid)
        
        // If constraints found safe cells, use them
        if !constraintResult.safeCells.isEmpty {
            let safeCell = constraintResult.safeCells[0]
            let explanation = constraintSolver.explainCell(
                row: safeCell.0, col: safeCell.1, grid: grid
            ) ?? "Logical deduction found a safe cell."
            
            return AIAnalysis(
                recommendedMove: safeCell,
                strategy: .constraint,
                confidence: 1.0,
                safeCells: constraintResult.safeCells,
                mineCells: constraintResult.mineCells,
                probabilityMap: nil,
                explanation: explanation
            )
        }
        
        // Phase 2: Use Monte Carlo for ambiguous positions
        let probabilityMap = monteCarloSolver.analyze(grid: grid)
        
        if let safest = probabilityMap.safestCell {
            let prob = probabilityMap.probability(row: safest.0, column: safest.1)
            let confidence = 1.0 - prob
            
            // If confidence is high enough, recommend the move
            if confidence > 0.5 {
                let explanation = "Monte Carlo simulation (\(probabilityMap.sampleCount) samples) " +
                    "suggests cell (\(safest.0+1),\(safest.1+1)) with \(Int(prob * 100))% mine probability."
                
                return AIAnalysis(
                    recommendedMove: safest,
                    strategy: .monteCarlo,
                    confidence: confidence,
                    safeCells: [],
                    mineCells: [],
                    probabilityMap: probabilityMap,
                    explanation: explanation
                )
            }
        }
        
        // Phase 3: No good move found - pure guess
        let unrevealed = getUnrevealedCells(grid: grid)
        let guess = unrevealed.randomElement()
        
        return AIAnalysis(
            recommendedMove: guess,
            strategy: .guess,
            confidence: 0.5,
            safeCells: [],
            mineCells: [],
            probabilityMap: probabilityMap,
            explanation: "No safe move found. Making an educated guess."
        )
    }
    
    /// Get all cell probabilities (for visualization)
    /// - Parameter grid: The current game grid
    /// - Returns: ProbabilityMap with mine probabilities for all unrevealed cells
    func getProbabilities(grid: Grid) -> ProbabilityMap {
        return monteCarloSolver.analyze(grid: grid)
    }
    
    /// Explain why a specific cell is safe or dangerous
    /// - Parameters:
    ///   - row: Cell row
    ///   - col: Cell column
    ///   - grid: The current game grid
    /// - Returns: Explanation string
    func explainCell(row: Int, col: Int, grid: Grid) -> String {
        // Try constraint explanation first
        if let explanation = constraintSolver.explainCell(row: row, col: col, grid: grid) {
            return explanation
        }
        
        // Fall back to probability explanation
        let probabilityMap = monteCarloSolver.analyze(grid: grid)
        let prob = probabilityMap.probability(row: row, column: col)
        
        if prob < 0.3 {
            return "Monte Carlo analysis suggests this cell is likely safe (mine probability: \(Int(prob * 100))%)."
        } else if prob > 0.7 {
            return "Monte Carlo analysis suggests this cell is likely a mine (mine probability: \(Int(prob * 100))%)."
        } else {
            return "This cell is uncertain (mine probability: \(Int(prob * 100))%). Proceed with caution."
        }
    }
    
    // MARK: - Private
    
    /// Get all unrevealed, unflagged cells
    private func getUnrevealedCells(grid: Grid) -> [(Int, Int)] {
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
}
