// ConstraintSolver.swift
// Mineswapper AI - Phase 1: Constraint-based solving
//
// Uses logical deduction to find guaranteed safe/mine cells.
// Handles ~80% of game situations deterministically.

import Foundation

/// Result of constraint analysis
struct ConstraintResult {
    /// Cells that are guaranteed to be safe (can be revealed)
    let safeCells: [(Int, Int)]
    /// Cells that are guaranteed to be mines (can be flagged)
    let mineCells: [(Int, Int)]
    /// Whether any new deductions were made
    let hasNewDeductions: Bool
}

/// Constraint-based solver for Minesweeper
///
/// For each revealed cell with a number, we can derive constraints:
/// - If adjacentMines == flaggedNeighbors → all unrevealed neighbors are SAFE
/// - If adjacentMines == unrevealedNeighbors → all unrevealed neighbors are MINES
///
/// This solver iteratively propagates these constraints until no more deductions can be made.
final class ConstraintSolver {
    
    // MARK: - Public API
    
    /// Analyze the grid and return guaranteed safe/mine cells
    /// - Parameter grid: The current game grid
    /// - Returns: ConstraintResult with safe and mine cells
    func analyze(grid: Grid) -> ConstraintResult {
        var safeCells: Set<String> = []
        var mineCells: Set<String> = []
        var changed = true
        
        // Iteratively propagate constraints until stable
        while changed {
            changed = false
            
            for row in 0..<grid.rows {
                for col in 0..<grid.columns {
                    let cell = grid[row: row, column: col]
                    
                    // Only analyze revealed cells with numbers
                    guard cell.isRevealed, cell.adjacentMines > 0 else { continue }
                    
                    let neighbors = grid.neighbors(row: row, column: col)
                    
                    // Count flagged and unrevealed neighbors
                    var flaggedCount = 0
                    var unrevealedNeighbors: [(Int, Int)] = []
                    
                    for (nr, nc) in neighbors {
                        let neighbor = grid[row: nr, column: nc]
                        if neighbor.isFlagged {
                            flaggedCount += 1
                        } else if !neighbor.isRevealed {
                            unrevealedNeighbors.append((nr, nc))
                        }
                    }
                    
                    let remainingMines = cell.adjacentMines - flaggedCount
                    
                    // Rule 1: All remaining mines are flagged → unrevealed are safe
                    if remainingMines == 0 && !unrevealedNeighbors.isEmpty {
                        for (nr, nc) in unrevealedNeighbors {
                            let key = "\(nr),\(nc)"
                            if !safeCells.contains(key) {
                                safeCells.insert(key)
                                changed = true
                            }
                        }
                    }
                    
                    // Rule 2: All unrevealed neighbors must be mines
                    if remainingMines == unrevealedNeighbors.count && !unrevealedNeighbors.isEmpty {
                        for (nr, nc) in unrevealedNeighbors {
                            let key = "\(nr),\(nc)"
                            if !mineCells.contains(key) {
                                mineCells.insert(key)
                                changed = true
                            }
                        }
                    }
                }
            }
        }
        
        // Convert sets back to tuples
        let safe = safeCells.compactMap { key -> (Int, Int)? in
            let parts = key.split(separator: ",")
            guard parts.count == 2,
                  let r = Int(parts[0]),
                  let c = Int(parts[1]) else { return nil }
            return (r, c)
        }
        
        let mines = mineCells.compactMap { key -> (Int, Int)? in
            let parts = key.split(separator: ",")
            guard parts.count == 2,
                  let r = Int(parts[0]),
                  let c = Int(parts[1]) else { return nil }
            return (r, c)
        }
        
        return ConstraintResult(
            safeCells: safe,
            mineCells: mines,
            hasNewDeductions: !safe.isEmpty || !mines.isEmpty
        )
    }
    
    /// Get explanation for why a cell is safe or a mine
    /// - Parameters:
    ///   - row: Cell row
    ///   - col: Cell column
    ///   - grid: The current game grid
    /// - Returns: Human-readable explanation, or nil if no constraint applies
    func explainCell(row: Int, col: Int, grid: Grid) -> String? {
        let cell = grid[row: row, column: col]
        guard !cell.isRevealed else { return nil }
        
        // Find the revealed neighbor that constrains this cell
        for (nr, nc) in grid.neighbors(row: row, column: col) {
            let neighbor = grid[row: nr, column: nc]
            guard neighbor.isRevealed, neighbor.adjacentMines > 0 else { continue }
            
            let siblings = grid.neighbors(row: nr, column: nc)
            var flaggedCount = 0
            var unrevealedCount = 0
            
            for (sr, sc) in siblings {
                let sib = grid[row: sr, column: sc]
                if sib.isFlagged { flaggedCount += 1 }
                else if !sib.isRevealed { unrevealedCount += 1 }
            }
            
            let remaining = neighbor.adjacentMines - flaggedCount
            
            if remaining == 0 {
                return "Cell (\(nr+1),\(nc+1)) has \(neighbor.adjacentMines) adjacent mines, all flagged. This cell is safe."
            }
            
            if remaining == unrevealedCount {
                return "Cell (\(nr+1),\(nc+1)) needs \(remaining) more mines, and has \(unrevealedCount) unrevealed neighbors. This cell must be a mine."
            }
        }
        
        return nil
    }
}
