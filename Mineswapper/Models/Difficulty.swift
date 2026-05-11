import Foundation

enum Difficulty: Equatable, Hashable, Sendable, Codable {
    case beginner
    case intermediate
    case expert
    case custom(rows: Int, columns: Int, mines: Int)

    /// Minimum number of safe (non-mine) cells required for a valid game.
    /// Needs at least 1 safe cell for the first click + its neighbors.
    static let minSafeCells = 9

    var rows: Int {
        switch self {
        case .beginner: return 9
        case .intermediate: return 16
        case .expert: return 16
        case .custom(let rows, _, _): return rows
        }
    }

    var columns: Int {
        switch self {
        case .beginner: return 9
        case .intermediate: return 16
        case .expert: return 30
        case .custom(_, let columns, _): return columns
        }
    }

    var mineCount: Int {
        switch self {
        case .beginner: return 10
        case .intermediate: return 40
        case .expert: return 99
        case .custom(_, _, let mines): return mines
        }
    }

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .expert: return "Expert"
        case .custom: return "Custom"
        }
    }

    /// Maximum mines allowed for this difficulty, ensuring at least `minSafeCells` remain safe.
    var maxMines: Int {
        max(1, rows * columns - Self.minSafeCells)
    }

    /// Whether this difficulty configuration is valid.
    var isValid: Bool {
        mineCount >= 1 && mineCount <= maxMines
    }

    /// Returns a clamped difficulty that is guaranteed valid.
    func clamped() -> Difficulty {
        switch self {
        case .beginner, .intermediate, .expert:
            return self
        case .custom(let rows, let columns, let mines):
            let clampedRows = max(5, min(rows, 30))
            let clampedCols = max(5, min(columns, 30))
            let totalCells = clampedRows * clampedCols
            let maxAllowed = max(1, totalCells - Self.minSafeCells)
            let clampedMines = max(1, min(mines, maxAllowed))
            return .custom(rows: clampedRows, columns: clampedCols, mines: clampedMines)
        }
    }
}
