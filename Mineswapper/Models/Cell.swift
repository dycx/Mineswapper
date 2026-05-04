import Foundation

struct Cell: Equatable, Sendable {
    var isMine: Bool = false
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var adjacentMines: Int = 0
}
