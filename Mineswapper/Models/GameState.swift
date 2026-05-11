import Foundation

enum GameState: Equatable, Sendable, Codable {
    case idle
    case playing
    case won
    case lost
}
