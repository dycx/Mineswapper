// AnalyticsService.swift
// Mineswapper AI - Game analytics and data collection
//
// Tracks game outcomes, move sequences, and strategy effectiveness
// to improve AI performance over time.

import Foundation

/// Record of a single move
struct MoveRecord: Codable, Identifiable {
    let id: UUID
    let position: (Int, Int)
    let moveType: MoveType
    let strategy: AIStrategy
    let mineProbability: Double?
    let timestamp: Date
    let result: MoveResult
    
    enum CodingKeys: String, CodingKey {
        case id, moveType, strategy, mineProbability, timestamp, result
        case row, column
    }
    
    init(position: (Int, Int), moveType: MoveType, strategy: AIStrategy, 
         mineProbability: Double? = nil, result: MoveResult) {
        self.id = UUID()
        self.position = position
        self.moveType = moveType
        self.strategy = strategy
        self.mineProbability = mineProbability
        self.timestamp = Date()
        self.result = result
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let row = try container.decode(Int.self, forKey: .row)
        let column = try container.decode(Int.self, forKey: .column)
        position = (row, column)
        moveType = try container.decode(MoveType.self, forKey: .moveType)
        strategy = try container.decode(AIStrategy.self, forKey: .strategy)
        mineProbability = try container.decodeIfPresent(Double.self, forKey: .mineProbability)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        result = try container.decode(MoveResult.self, forKey: .result)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position.0, forKey: .row)
        try container.encode(position.1, forKey: .column)
        try container.encode(moveType, forKey: .moveType)
        try container.encode(strategy, forKey: .strategy)
        try container.encodeIfPresent(mineProbability, forKey: .mineProbability)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(result, forKey: .result)
    }
}

/// Type of move
enum MoveType: String, Codable {
    case reveal
    case flag
    case unflag
    case chord
}

/// Result of a move
enum MoveResult: String, Codable {
    case safe      // Revealed a safe cell
    case mine      // Hit a mine
    case flagged   // Flagged a cell
    case unflagged // Unflagged a cell
}

/// Record of a complete game
struct GameRecord: Codable, Identifiable {
    let id: UUID
    let difficulty: Difficulty
    let startTime: Date
    var endTime: Date?
    var outcome: GameState
    var totalMoves: Int
    var constraintMoves: Int
    var monteCarloMoves: Int
    var guessMoves: Int
    var humanMoves: Int
    var moveHistory: [MoveRecord]
    
    init(difficulty: Difficulty) {
        self.id = UUID()
        self.difficulty = difficulty
        self.startTime = Date()
        self.outcome = .playing
        self.totalMoves = 0
        self.constraintMoves = 0
        self.monteCarloMoves = 0
        self.guessMoves = 0
        self.humanMoves = 0
        self.moveHistory = []
    }
    
    /// Duration in seconds
    var duration: Int {
        guard let end = endTime else { return 0 }
        return Int(end.timeIntervalSince(startTime))
    }
    
    /// Win rate (only meaningful for completed games)
    var isWin: Bool { outcome == .won }
    
    /// Strategy distribution
    var strategyDistribution: [AIStrategy: Int] {
        [
            .constraint: constraintMoves,
            .monteCarlo: monteCarloMoves,
            .guess: guessMoves,
            .human: humanMoves
        ]
    }
}

/// Analytics service for tracking game performance
final class AnalyticsService {
    
    /// UserDefaults key for game records
    private let recordsKey = "gameRecords"
    
    /// All game records
    private(set) var records: [GameRecord] = []
    
    /// Initialize and load existing records
    init() {
        loadRecords()
    }
    
    // MARK: - Recording
    
    /// Start recording a new game
    func startGame(difficulty: Difficulty) -> GameRecord {
        return GameRecord(difficulty: difficulty)
    }
    
    /// Record a move
    func recordMove(_ move: MoveRecord, in record: inout GameRecord) {
        record.moveHistory.append(move)
        record.totalMoves += 1
        
        switch move.strategy {
        case .constraint: record.constraintMoves += 1
        case .monteCarlo: record.monteCarloMoves += 1
        case .guess: record.guessMoves += 1
        case .human: record.humanMoves += 1
        }
    }
    
    /// Finish recording a game
    func finishGame(_ record: inout GameRecord, outcome: GameState) {
        record.outcome = outcome
        record.endTime = Date()
        records.append(record)
        saveRecords()
    }
    
    // MARK: - Statistics
    
    /// Overall win rate
    var winRate: Double {
        guard !records.isEmpty else { return 0 }
        let wins = records.filter { $0.isWin }.count
        return Double(wins) / Double(records.count)
    }
    
    /// Win rate for a specific difficulty
    func winRate(for difficulty: Difficulty) -> Double {
        let filtered = records.filter { $0.difficulty == difficulty }
        guard !filtered.isEmpty else { return 0 }
        let wins = filtered.filter { $0.isWin }.count
        return Double(wins) / Double(filtered.count)
    }
    
    /// Average game duration (in seconds)
    var averageDuration: Double {
        guard !records.isEmpty else { return 0 }
        let total = records.reduce(0) { $0 + $1.duration }
        return Double(total) / Double(records.count)
    }
    
    /// Total games played
    var totalGames: Int { records.count }
    
    /// Total wins
    var totalWins: Int { records.filter { $0.isWin }.count }
    
    /// Best time for a difficulty
    func bestTime(for difficulty: Difficulty) -> Int? {
        let filtered = records.filter { $0.isWin && $0.difficulty == difficulty }
        return filtered.min(by: { $0.duration < $1.duration })?.duration
    }
    
    /// Strategy effectiveness (win rate per strategy)
    func strategyEffectiveness() -> [AIStrategy: Double] {
        var results: [AIStrategy: (wins: Int, total: Int)] = [:]
        
        for record in records {
            let strategies = Set(record.moveHistory.map { $0.strategy })
            for strategy in strategies {
                let current = results[strategy] ?? (0, 0)
                results[strategy] = (current.wins + (record.isWin ? 1 : 0), current.total + 1)
            }
        }
        
        return results.mapValues { pair in
            pair.total > 0 ? Double(pair.wins) / Double(pair.total) : 0
        }
    }
    
    /// Recent games (last N)
    func recentGames(count: Int = 10) -> [GameRecord] {
        Array(records.suffix(count))
    }
    
    /// Improvement trend (win rate over time)
    func improvementTrend(windowSize: Int = 10) -> [Double] {
        guard records.count >= windowSize else { return [] }
        
        var trend: [Double] = []
        for i in windowSize...records.count {
            let window = Array(records[(i - windowSize)..<i])
            let wins = window.filter { $0.isWin }.count
            trend.append(Double(wins) / Double(windowSize))
        }
        return trend
    }
    
    // MARK: - Persistence
    
    /// Save records to UserDefaults
    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }
    
    /// Load records from UserDefaults
    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let loaded = try? JSONDecoder().decode([GameRecord].self, from: data) else {
            return
        }
        records = loaded
    }
    
    /// Clear all records
    func clearAll() {
        records = []
        UserDefaults.standard.removeObject(forKey: recordsKey)
    }
}
