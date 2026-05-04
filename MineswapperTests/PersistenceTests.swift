import XCTest
@testable import Mineswapper

final class PersistenceTests: XCTestCase {
    var persistence: PersistenceService!

    override func setUp() {
        persistence = PersistenceService(suiteName: "test-\(UUID().uuidString)")
    }

    override func tearDown() {
        persistence.clearAll()
    }

    func testSaveAndLoadHighScore() {
        persistence.saveHighScore(difficulty: "Beginner", time: 120, date: Date())
        let scores = persistence.highScores()
        XCTAssertEqual(scores["Beginner"]?.bestTime, 120)
    }

    func testUpdateHighScoreOnlyIfBetter() {
        persistence.saveHighScore(difficulty: "Beginner", time: 120, date: Date())
        persistence.saveHighScore(difficulty: "Beginner", time: 90, date: Date())
        let scores = persistence.highScores()
        XCTAssertEqual(scores["Beginner"]?.bestTime, 90)
    }

    func testDoesNotUpdateHighScoreIfWorse() {
        persistence.saveHighScore(difficulty: "Beginner", time: 90, date: Date())
        persistence.saveHighScore(difficulty: "Beginner", time: 120, date: Date())
        let scores = persistence.highScores()
        XCTAssertEqual(scores["Beginner"]?.bestTime, 90)
    }

    func testSaveAndLoadCustomDifficulty() {
        let custom = Difficulty.custom(rows: 10, columns: 15, mines: 25)
        persistence.saveCustomDifficulty(custom)
        let loaded = persistence.loadCustomDifficulty()
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded, custom)
    }

    func testLoadNilWhenNoCustomDifficulty() {
        let loaded = persistence.loadCustomDifficulty()
        XCTAssertNil(loaded)
    }
}
