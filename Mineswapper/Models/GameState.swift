import Foundation

enum GameState: Equatable, Sendable {
    case idle
    case playing
    case won
    case lost
}
