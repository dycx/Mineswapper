import Foundation

struct HighScore: Codable, Sendable {
    let bestTime: Int
    let date: Date
}

final class PersistenceService {
    private let defaults: UserDefaults

    init(suiteName: String? = nil) {
        if let suiteName {
            self.defaults = UserDefaults(suiteName: suiteName) ?? .standard
        } else {
            self.defaults = .standard
        }
    }

    // MARK: - High Scores

    func highScores() -> [String: HighScore] {
        guard let data = defaults.data(forKey: "highScores"),
              let scores = try? JSONDecoder().decode([String: HighScore].self, from: data)
        else {
            return [:]
        }
        return scores
    }

    func saveHighScore(difficulty: String, time: Int, date: Date) {
        var scores = highScores()
        if let existing = scores[difficulty], existing.bestTime <= time {
            return
        }
        scores[difficulty] = HighScore(bestTime: time, date: date)
        if let data = try? JSONEncoder().encode(scores) {
            defaults.set(data, forKey: "highScores")
        }
    }

    // MARK: - Custom Difficulty

    func saveCustomDifficulty(_ difficulty: Difficulty) {
        guard case .custom(let rows, let columns, let mines) = difficulty else { return }
        let dict: [String: Int] = ["rows": rows, "columns": columns, "mines": mines]
        if let data = try? JSONEncoder().encode(dict) {
            defaults.set(data, forKey: "customDifficulty")
        }
    }

    func loadCustomDifficulty() -> Difficulty? {
        guard let data = defaults.data(forKey: "customDifficulty"),
              let dict = try? JSONDecoder().decode([String: Int].self, from: data),
              let rows = dict["rows"],
              let columns = dict["columns"],
              let mines = dict["mines"]
        else {
            return nil
        }
        return .custom(rows: rows, columns: columns, mines: mines)
    }

    // MARK: - Cleanup

    func clearAll() {
        defaults.removeObject(forKey: "highScores")
        defaults.removeObject(forKey: "customDifficulty")
    }
}
