// MonteCarloSolver.swift
// Mineswapper AI - Phase 2: Monte Carlo simulation
//
// When constraints can't determine a move, we simulate many possible
// board configurations and calculate mine probabilities.

import Foundation

/// Mine probability for each unrevealed cell
struct ProbabilityMap {
    /// Position → probability of being a mine (0.0 - 1.0)
    let probabilities: [String: Double]
    /// Number of simulations performed
    let sampleCount: Int
    /// Confidence level (1.0 - max_uncertainty)
    let confidence: Double
    
    /// Get probability for a specific cell
    func probability(row: Int, column: Int) -> Double {
        probabilities["\(row),\(column)"] ?? 0.5
    }
    
    /// Get the safest cell (lowest mine probability)
    var safestCell: (Int, Int)? {
        probabilities.min(by: { $0.value < $1.value }).flatMap { key, _ in
            let parts = key.split(separator: ",")
            guard parts.count == 2,
                  let r = Int(parts[0]),
                  let c = Int(parts[1]) else { return nil }
            return (r, c)
        }
    }
    
    /// Get cells sorted by safety (safest first)
    var sortedBySafety: [(Int, Int, Double)] {
        probabilities.compactMap { key, prob in
            let parts = key.split(separator: ",")
            guard parts.count == 2,
                  let r = Int(parts[0]),
                  let c = Int(parts[1]) else { return nil }
            return (r, c, prob)
        }.sorted { $0.2 < $1.2 }
    }
}

/// Monte Carlo solver for Minesweeper
///
/// Generates random board configurations that satisfy all known constraints,
/// then calculates mine probabilities based on the samples.
final class MonteCarloSolver {
    
    /// Number of Monte Carlo samples to generate
    var sampleCount: Int = 500
    
    /// Maximum time allowed for simulation (seconds)
    var maxTime: TimeInterval = 2.0
    
    // MARK: - Public API
    
    /// Calculate mine probabilities for all unrevealed cells
    /// - Parameter grid: The current game grid
    /// - Returns: ProbabilityMap with mine probabilities
    func analyze(grid: Grid) -> ProbabilityMap {
        let unrevealed = getUnrevealedCells(grid: grid)
        guard !unrevealed.isEmpty else {
            return ProbabilityMap(probabilities: [:], sampleCount: 0, confidence: 1.0)
        }
        
        // Get constraints from revealed cells
        let constraints = extractConstraints(grid: grid)
        
        // Run Monte Carlo simulation
        var mineCounts: [String: Int] = [:]
        for pos in unrevealed {
            mineCounts["\(pos.0),\(pos.1)"] = 0
        }
        
        var validSamples = 0
        let startTime = Date()
        
        for _ in 0..<sampleCount {
            // Check time limit
            if Date().timeIntervalSince(startTime) > maxTime { break }
            
            // Generate a random configuration
            if let config = generateValidConfiguration(
                unrevealed: unrevealed,
                constraints: constraints,
                remainingMines: grid.mineCount - countFlagged(grid: grid)
            ) {
                validSamples += 1
                for key in config {
                    mineCounts[key, default: 0] += 1
                }
            }
        }
        
        // Calculate probabilities
        guard validSamples > 0 else {
            // If no valid samples, return uniform 0.5
            var probs: [String: Double] = [:]
            for pos in unrevealed {
                probs["\(pos.0),\(pos.1)"] = 0.5
            }
            return ProbabilityMap(probabilities: probs, sampleCount: 0, confidence: 0.0)
        }
        
        var probabilities: [String: Double] = [:]
        for (key, count) in mineCounts {
            probabilities[key] = Double(count) / Double(validSamples)
        }
        
        // Calculate confidence (how certain we are about the safest cell)
        let minProb = probabilities.values.min() ?? 0.5
        let confidence = 1.0 - minProb
        
        return ProbabilityMap(
            probabilities: probabilities,
            sampleCount: validSamples,
            confidence: confidence
        )
    }
    
    // MARK: - Private Implementation
    
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
    
    /// Count flagged cells
    private func countFlagged(grid: Grid) -> Int {
        var count = 0
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                if grid[row: r, column: c].isFlagged {
                    count += 1
                }
            }
        }
        return count
    }
    
    /// Extract constraints from revealed cells
    private func extractConstraints(grid: Grid) -> [CellConstraint] {
        var constraints: [CellConstraint] = []
        
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                let cell = grid[row: r, column: c]
                guard cell.isRevealed, cell.adjacentMines > 0 else { continue }
                
                let neighbors = grid.neighbors(row: r, column: c)
                var unrevealed: [(Int, Int)] = []
                var flaggedCount = 0
                
                for (nr, nc) in neighbors {
                    let neighbor = grid[row: nr, column: nc]
                    if neighbor.isFlagged {
                        flaggedCount += 1
                    } else if !neighbor.isRevealed {
                        unrevealed.append((nr, nc))
                    }
                }
                
                if !unrevealed.isEmpty {
                    constraints.append(CellConstraint(
                        centerRow: r,
                        centerCol: c,
                        totalMines: cell.adjacentMines,
                        flaggedCount: flaggedCount,
                        unrevealedCells: unrevealed
                    ))
                }
            }
        }
        
        return constraints
    }
    
    /// Generate a random valid configuration using backtracking
    private func generateValidConfiguration(
        unrevealed: [(Int, Int)],
        constraints: [CellConstraint],
        remainingMines: Int
    ) -> Set<String>? {
        guard remainingMines >= 0 else { return nil }
        
        // Shuffle unrevealed cells for randomness
        let shuffled = unrevealed.shuffled()
        
        // Try random placement
        var attempts = 0
        let maxAttempts = 100
        
        while attempts < maxAttempts {
            attempts += 1
            
            // Randomly select cells to be mines
            let mineCount = min(remainingMines, shuffled.count)
            let selectedMines = Set(shuffled.prefix(mineCount).map { "\($0.0),\($0.1)" })
            
            // Validate against constraints
            if validateConfiguration(mineSet: selectedMines, constraints: constraints) {
                return selectedMines
            }
        }
        
        // If random attempts fail, try systematic approach
        return backtrackingSearch(
            cells: shuffled,
            constraints: constraints,
            remainingMines: remainingMines,
            index: 0,
            currentMines: []
        )
    }
    
    /// Backtracking search for valid configuration
    private func backtrackingSearch(
        cells: [(Int, Int)],
        constraints: [CellConstraint],
        remainingMines: Int,
        index: Int,
        currentMines: Set<String>
    ) -> Set<String>? {
        // Base case: all cells assigned
        if index >= cells.count {
            if remainingMines == 0 && validateConfiguration(mineSet: currentMines, constraints: constraints) {
                return currentMines
            }
            return nil
        }
        
        let cell = cells[index]
        let key = "\(cell.0),\(cell.1)"
        
        // Try placing a mine here
        if remainingMines > 0 {
            var newMines = currentMines
            newMines.insert(key)
            if let result = backtrackingSearch(
                cells: cells,
                constraints: constraints,
                remainingMines: remainingMines - 1,
                index: index + 1,
                currentMines: newMines
            ) {
                return result
            }
        }
        
        // Try NOT placing a mine here
        if let result = backtrackingSearch(
            cells: cells,
            constraints: constraints,
            remainingMines: remainingMines,
            index: index + 1,
            currentMines: currentMines
        ) {
            return result
        }
        
        return nil
    }
    
    /// Validate a mine configuration against all constraints
    private func validateConfiguration(mineSet: Set<String>, constraints: [CellConstraint]) -> Bool {
        for constraint in constraints {
            let mineCount = constraint.unrevealedCells.filter { mineSet.contains("\($0.0),\($0.1)") }.count
            let totalMines = mineCount + constraint.flaggedCount
            
            if totalMines != constraint.totalMines {
                return false
            }
        }
        return true
    }
}

/// Constraint from a revealed cell
private struct CellConstraint {
    let centerRow: Int
    let centerCol: Int
    let totalMines: Int
    let flaggedCount: Int
    let unrevealedCells: [(Int, Int)]
}
