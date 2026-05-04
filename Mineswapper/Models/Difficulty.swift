import Foundation

enum Difficulty: Equatable, Hashable, Sendable {
    case beginner
    case intermediate
    case expert
    case custom(rows: Int, columns: Int, mines: Int)

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
}
