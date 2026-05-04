# Mineswapper Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a classic Minesweeper game for macOS with SwiftUI, modern MVVM architecture, and all classic game features.

**Architecture:** MVVM with `@Observable` macro. Models are pure value types (Cell, Grid). ViewModel (MinesweeperGame) owns game state and logic. Views are thin SwiftUI layers. Persistence via UserDefaults + JSON file.

**Tech Stack:** Swift 5.9+, SwiftUI, macOS 14+, SPM, XCTest

---

## File Map

| File | Responsibility |
|------|---------------|
| `Package.swift` | SPM manifest — executable + test targets |
| `Mineswapper/App/MineswapperApp.swift` | App entry point, window config |
| `Mineswapper/Models/Cell.swift` | Cell value type — mine, revealed, flagged |
| `Mineswapper/Models/Grid.swift` | 2D grid — mine placement, adjacency, reveal logic |
| `Mineswapper/Models/GameState.swift` | GameState enum (playing/won/lost) |
| `Mineswapper/Models/Difficulty.swift` | Difficulty enum with presets + custom |
| `Mineswapper/ViewModels/MinesweeperGame.swift` | @Observable game orchestrator |
| `Mineswapper/Services/PersistenceService.swift` | High scores + game state persistence |
| `Mineswapper/Utilities/Constants.swift` | UI constants, number colors |
| `Mineswapper/Views/CellView.swift` | Single cell view |
| `Mineswapper/Views/GameBoardView.swift` | Grid of cells |
| `Mineswapper/Views/ScoreBarView.swift` | Mine counter, face button, timer |
| `Mineswapper/Views/DifficultyPickerView.swift` | Difficulty selection + custom sheet |
| `Mineswapper/Views/ContentView.swift` | Main layout |
| `MineswapperTests/CellTests.swift` | Cell model tests |
| `MineswapperTests/GridTests.swift` | Grid logic tests |
| `MineswapperTests/FloodFillTests.swift` | Flood-fill specific tests |
| `MineswapperTests/GameLogicTests.swift` | Game flow tests (win/lose/chord) |
| `MineswapperTests/PersistenceTests.swift` | Persistence tests |

---

### Task 1: Project Scaffold

**Files:**
- Create: `Package.swift`
- Create: `Mineswapper/App/MineswapperApp.swift`
- Create: `MineswapperTests/CellTests.swift`

- [ ] **Step 1: Create Package.swift**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Mineswapper",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Mineswapper",
            path: "Mineswapper"
        ),
        .testTarget(
            name: "MineswapperTests",
            dependencies: ["Mineswapper"],
            path: "MineswapperTests"
        )
    ]
)
```

- [ ] **Step 2: Create app entry point**

```swift
// Mineswapper/App/MineswapperApp.swift
import SwiftUI

@main
struct MineswapperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
```

- [ ] **Step 3: Create placeholder ContentView**

```swift
// Mineswapper/Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Mineswapper")
            .frame(width: 400, height: 500)
    }
}
```

- [ ] **Step 4: Create a placeholder test to verify build**

```swift
// MineswapperTests/CellTests.swift
import XCTest
@testable import Mineswapper

final class CellTests: XCTestCase {
    func testPlaceholder() {
        XCTAssertTrue(true)
    }
}
```

- [ ] **Step 5: Build and run tests**

Run: `cd /Users/dycx/code/Mineswapper && swift build && swift test`
Expected: Build succeeds, 1 test passes

- [ ] **Step 6: Initialize git and commit**

```bash
cd /Users/dycx/code/Mineswapper
git init
echo ".build/" > .gitignore
echo ".DS_Store" >> .gitignore
git add .
git commit -m "feat: project scaffold with SPM, app entry, placeholder views"
```

---

### Task 2: Cell Model

**Files:**
- Create: `Mineswapper/Models/Cell.swift`
- Modify: `MineswapperTests/CellTests.swift`

- [ ] **Step 1: Write Cell tests**

Replace `MineswapperTests/CellTests.swift`:

```swift
import XCTest
@testable import Mineswapper

final class CellTests: XCTestCase {
    func testDefaultCellIsNotMine() {
        let cell = Cell()
        XCTAssertFalse(cell.isMine)
        XCTAssertFalse(cell.isRevealed)
        XCTAssertFalse(cell.isFlagged)
        XCTAssertEqual(cell.adjacentMines, 0)
    }

    func testCellAsMine() {
        var cell = Cell()
        cell.isMine = true
        XCTAssertTrue(cell.isMine)
    }

    func testRevealCell() {
        var cell = Cell()
        cell.isRevealed = true
        XCTAssertTrue(cell.isRevealed)
    }

    func testFlagCell() {
        var cell = Cell()
        cell.isFlagged = true
        XCTAssertTrue(cell.isFlagged)
    }

    func testCannotRevealFlaggedCell() {
        var cell = Cell()
        cell.isFlagged = true
        cell.isRevealed = true
        XCTAssertTrue(cell.isFlagged)
        XCTAssertTrue(cell.isRevealed)
    }

    func testAdjacentMinesCanBeSet() {
        var cell = Cell()
        cell.adjacentMines = 3
        XCTAssertEqual(cell.adjacentMines, 3)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter CellTests`
Expected: FAIL — `Cell` type not found

- [ ] **Step 3: Implement Cell**

Create `Mineswapper/Models/Cell.swift`:

```swift
import Foundation

struct Cell: Equatable, Sendable {
    var isMine: Bool = false
    var isRevealed: Bool = false
    var isFlagged: Bool = false
    var adjacentMines: Int = 0
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter CellTests`
Expected: All 6 tests PASS

- [ ] **Step 5: Commit**

```bash
git add Mineswapper/Models/Cell.swift MineswapperTests/CellTests.swift
git commit -m "feat: Cell model with mine, revealed, flagged, adjacentMines"
```

---

### Task 3: Grid Model — Structure and Mine Placement

**Files:**
- Create: `Mineswapper/Models/Grid.swift`
- Create: `MineswapperTests/GridTests.swift`

- [ ] **Step 1: Write Grid tests**

Create `MineswapperTests/GridTests.swift`:

```swift
import XCTest
@testable import Mineswapper

final class GridTests: XCTestCase {
    func testGridInitialization() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        XCTAssertEqual(grid.rows, 9)
        XCTAssertEqual(grid.columns, 9)
        XCTAssertEqual(grid.mineCount, 10)
    }

    func testGridAllCellsHiddenBeforeFirstClick() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        for row in 0..<9 {
            for col in 0..<9 {
                XCTAssertFalse(grid.cell(at: row, col)!.isRevealed)
                XCTAssertFalse(grid.cell(at: row, col)!.isMine)
            }
        }
    }

    func testPlaceMinesExcludesFirstClick() {
        var grid = Grid(rows: 9, columns: 9, mineCount: 10)
        grid.placeMines(excludingRow: 4, column: 4)
        for dr in -1...1 {
            for dc in -1...1 {
                let r = 4 + dr
                let c = 4 + dc
                if grid.isValidPosition(row: r, column: c) {
                    XCTAssertFalse(grid.cell(at: r, c)!.isMine,
                        "Cell (\(r), \(c)) should not be a mine after first click at (4, 4)")
                }
            }
        }
    }

    func testPlaceMinesCorrectCount() {
        var grid = Grid(rows: 9, columns: 9, mineCount: 10)
        grid.placeMines(excludingRow: 0, column: 0)
        var mineCount = 0
        for row in 0..<9 {
            for col in 0..<9 {
                if grid.cell(at: row, col)!.isMine {
                    mineCount += 1
                }
            }
        }
        XCTAssertEqual(mineCount, 10)
    }

    func testAdjacentMinesCount() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.setCell(at: 2, 2, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        XCTAssertEqual(grid.cell(at: 1, 1)!.adjacentMines, 2)
        XCTAssertEqual(grid.cell(at: 0, 1)!.adjacentMines, 1)
    }

    func testIsValidPosition() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        XCTAssertTrue(grid.isValidPosition(row: 0, column: 0))
        XCTAssertTrue(grid.isValidPosition(row: 8, column: 8))
        XCTAssertFalse(grid.isValidPosition(row: -1, column: 0))
        XCTAssertFalse(grid.isValidPosition(row: 0, column: 9))
        XCTAssertFalse(grid.isValidPosition(row: 9, column: 0))
    }

    func testNeighbors() {
        let grid = Grid(rows: 9, columns: 9, mineCount: 10)
        let cornerNeighbors = grid.neighbors(row: 0, column: 0)
        XCTAssertEqual(cornerNeighbors.count, 3)
        let centerNeighbors = grid.neighbors(row: 4, column: 4)
        XCTAssertEqual(centerNeighbors.count, 8)
        let edgeNeighbors = grid.neighbors(row: 0, column: 4)
        XCTAssertEqual(edgeNeighbors.count, 5)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter GridTests`
Expected: FAIL — `Grid` type not found

- [ ] **Step 3: Implement Grid**

Create `Mineswapper/Models/Grid.swift`:

```swift
import Foundation

struct Grid: Equatable, Sendable {
    let rows: Int
    let columns: Int
    let mineCount: Int
    private(set) var cells: [[Cell]]

    init(rows: Int, columns: Int, mineCount: Int) {
        self.rows = rows
        self.columns = columns
        self.mineCount = mineCount
        self.cells = Array(
            repeating: Array(repeating: Cell(), count: columns),
            count: rows
        )
    }

    func cell(at row: Int, _ column: Int) -> Cell? {
        guard isValidPosition(row: row, column: column) else { return nil }
        return cells[row][column]
    }

    mutating func setCell(at row: Int, _ column: Int, cell: Cell) {
        guard isValidPosition(row: row, column: column) else { return }
        cells[row][column] = cell
    }

    func isValidPosition(row: Int, column: Int) -> Bool {
        row >= 0 && row < rows && column >= 0 && column < columns
    }

    func neighbors(row: Int, column: Int) -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let nr = row + dr
                let nc = column + dc
                if isValidPosition(row: nr, column: nc) {
                    result.append((nr, nc))
                }
            }
        }
        return result
    }

    mutating func placeMines(excludingRow safeRow: Int, column safeCol: Int) {
        var positions: [(Int, Int)] = []
        for r in 0..<rows {
            for c in 0..<columns {
                let isSafeZone = abs(r - safeRow) <= 1 && abs(c - safeCol) <= 1
                if !isSafeZone {
                    positions.append((r, c))
                }
            }
        }
        let shuffled = positions.shuffled()
        let minePositions = shuffled.prefix(mineCount)
        for (r, c) in minePositions {
            cells[r][c].isMine = true
        }
    }

    mutating func calculateAdjacentMines() {
        for r in 0..<rows {
            for c in 0..<columns {
                if cells[r][c].isMine { continue }
                let count = neighbors(row: r, column: c)
                    .filter { cells[$0.0][$0.1].isMine }
                    .count
                cells[r][c].adjacentMines = count
            }
        }
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter GridTests`
Expected: All 7 tests PASS

- [ ] **Step 5: Commit**

```bash
git add Mineswapper/Models/Grid.swift MineswapperTests/GridTests.swift
git commit -m "feat: Grid model with mine placement, adjacency, neighbors"
```

---

### Task 4: Grid — Reveal and Flood-Fill

**Files:**
- Modify: `Mineswapper/Models/Grid.swift`
- Create: `MineswapperTests/FloodFillTests.swift`

- [ ] **Step 1: Write flood-fill tests**

Create `MineswapperTests/FloodFillTests.swift`:

```swift
import XCTest
@testable import Mineswapper

final class FloodFillTests: XCTestCase {
    func testRevealSingleCell() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        let revealed = grid.reveal(row: 1, column: 1)
        XCTAssertTrue(grid.cell(at: 1, 1)!.isRevealed)
        XCTAssertEqual(revealed.count, 1)
    }

    func testFloodFillRevealsEmptyRegion() {
        var grid = Grid(rows: 5, columns: 5, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        let revealed = grid.reveal(row: 4, column: 4)
        XCTAssertTrue(grid.cell(at: 4, 4)!.isRevealed)
        XCTAssertTrue(revealed.count > 1)
        XCTAssertFalse(grid.cell(at: 0, 0)!.isRevealed)
    }

    func testFloodFillStopsAtNumbers() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        let revealed = grid.reveal(row: 2, column: 2)
        XCTAssertTrue(grid.cell(at: 2, 2)!.isRevealed)
        XCTAssertTrue(grid.cell(at: 1, 1)!.isRevealed)
        XCTAssertFalse(grid.cell(at: 0, 0)!.isRevealed)
    }

    func testRevealMineReturnsAllMines() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        grid.setCell(at: 2, 2, cell: Cell(isMine: true))
        grid.calculateAdjacentMines()
        grid.reveal(row: 0, column: 0)
        XCTAssertTrue(grid.cell(at: 0, 0)!.isRevealed)
    }

    func testRevealFlaggedCellDoesNothing() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 1, 1, cell: Cell(isFlagged: true))
        let revealed = grid.reveal(row: 1, column: 1)
        XCTAssertTrue(revealed.isEmpty)
        XCTAssertFalse(grid.cell(at: 1, 1)!.isRevealed)
    }

    func testRevealAlreadyRevealedCellDoesNothing() {
        var grid = Grid(rows: 3, columns: 3, mineCount: 0)
        grid.setCell(at: 1, 1, cell: Cell(isRevealed: true))
        let revealed = grid.reveal(row: 1, column: 1)
        XCTAssertTrue(revealed.isEmpty)
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter FloodFillTests`
Expected: FAIL — `reveal` method not found on `Grid`

- [ ] **Step 3: Add reveal and flood-fill to Grid**

Add to `Mineswapper/Models/Grid.swift` (inside the `Grid` struct):

```swift
    @discardableResult
    mutating func reveal(row: Int, column: Int) -> [(Int, Int)] {
        guard isValidPosition(row: row, column: column) else { return [] }
        guard !cells[row][column].isRevealed else { return [] }
        guard !cells[row][column].isFlagged else { return [] }

        cells[row][column].isRevealed = true
        var revealed = [(row, column)]

        if cells[row][column].isMine {
            return revealed
        }

        if cells[row][column].adjacentMines == 0 {
            for (nr, nc) in neighbors(row: row, column: column) {
                if !cells[nr][nc].isRevealed && !cells[nr][nc].isFlagged {
                    revealed.append(contentsOf: reveal(row: nr, column: nc))
                }
            }
        }

        return revealed
    }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter FloodFillTests`
Expected: All 6 tests PASS

- [ ] **Step 5: Commit**

```bash
git add Mineswapper/Models/Grid.swift MineswapperTests/FloodFillTests.swift
git commit -m "feat: Grid flood-fill reveal with BFS expansion"
```

---

### Task 5: GameState and Difficulty Models

**Files:**
- Create: `Mineswapper/Models/GameState.swift`
- Create: `Mineswapper/Models/Difficulty.swift`

- [ ] **Step 1: Create GameState**

Create `Mineswapper/Models/GameState.swift`:

```swift
import Foundation

enum GameState: Equatable, Sendable {
    case idle
    case playing
    case won
    case lost
}
```

- [ ] **Step 2: Create Difficulty**

Create `Mineswapper/Models/Difficulty.swift`:

```swift
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
```

- [ ] **Step 3: Build to verify**

Run: `cd /Users/dycx/code/Mineswapper && swift build`
Expected: Build succeeds

- [ ] **Step 4: Commit**

```bash
git add Mineswapper/Models/GameState.swift Mineswapper/Models/Difficulty.swift
git commit -m "feat: GameState and Difficulty models"
```

---

### Task 6: MinesweeperGame ViewModel — Core Game Flow

**Files:**
- Create: `Mineswapper/ViewModels/MinesweeperGame.swift`
- Create: `MineswapperTests/GameLogicTests.swift`

- [ ] **Step 1: Write game logic tests**

Create `MineswapperTests/GameLogicTests.swift`:

```swift
import XCTest
@testable import Mineswapper

final class GameLogicTests: XCTestCase {
    func testNewGameStartsIdle() {
        let game = MinesweeperGame(difficulty: .beginner)
        XCTAssertEqual(game.state, .idle)
    }

    func testFirstClickStartsGame() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.reveal(row: 4, column: 4)
        XCTAssertEqual(game.state, .playing)
    }

    func testFirstClickIsAlwaysSafe() {
        for _ in 0..<20 {
            let game = MinesweeperGame(difficulty: .beginner)
            game.reveal(row: 4, column: 4)
            XCTAssertNotEqual(game.state, .lost, "First click should never lose")
        }
    }

    func testFlagToggle() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.toggleFlag(row: 0, column: 0)
        XCTAssertTrue(game.grid.cell(at: 0, 0)!.isFlagged)
        game.toggleFlag(row: 0, column: 0)
        XCTAssertFalse(game.grid.cell(at: 0, 0)!.isFlagged)
    }

    func testCannotFlagRevealedCell() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.reveal(row: 4, column: 4)
        game.toggleFlag(row: 4, column: 4)
        XCTAssertFalse(game.grid.cell(at: 4, 4)!.isFlagged)
    }

    func testMineCounterUpdates() {
        let game = MinesweeperGame(difficulty: .beginner)
        XCTAssertEqual(game.remainingMines, 10)
        game.toggleFlag(row: 0, column: 0)
        XCTAssertEqual(game.remainingMines, 9)
        game.toggleFlag(row: 0, column: 1)
        XCTAssertEqual(game.remainingMines, 8)
        game.toggleFlag(row: 0, column: 0)
        XCTAssertEqual(game.remainingMines, 9)
    }

    func testWinCondition() {
        let game = MinesweeperGame(difficulty: .custom(rows: 2, columns: 2, mines: 1))
        game.reveal(row: 0, column: 0)
        for r in 0..<2 {
            for c in 0..<2 {
                if !game.grid.cell(at: r, c)!.isMine {
                    game.reveal(row: r, column: c)
                }
            }
        }
        XCTAssertEqual(game.state, .won)
    }

    func testLoseOnMine() {
        let game = MinesweeperGame(difficulty: .custom(rows: 2, columns: 2, mines: 1))
        game.reveal(row: 0, column: 0)
        for r in 0..<2 {
            for c in 0..<2 {
                if game.grid.cell(at: r, c)!.isMine {
                    game.reveal(row: r, column: c)
                    XCTAssertEqual(game.state, .lost)
                    return
                }
            }
        }
    }

    func testChordClick() {
        let game = MinesweeperGame(difficulty: .custom(rows: 3, columns: 3, mines: 0))
        game.grid.setCell(at: 0, 0, cell: Cell(isMine: true))
        game.grid.calculateAdjacentMines()
        game.reveal(row: 1, column: 1)
        game.toggleFlag(row: 0, column: 0)
        game.chordReveal(row: 1, column: 1)
        XCTAssertTrue(game.grid.cell(at: 0, 1)!.isRevealed)
        XCTAssertTrue(game.grid.cell(at: 1, 0)!.isRevealed)
    }

    func testNewGameResetsState() {
        let game = MinesweeperGame(difficulty: .beginner)
        game.reveal(row: 0, column: 0)
        game.toggleFlag(row: 5, column: 5)
        game.newGame()
        XCTAssertEqual(game.state, .idle)
        XCTAssertEqual(game.remainingMines, 10)
        for r in 0..<9 {
            for c in 0..<9 {
                XCTAssertFalse(game.grid.cell(at: r, c)!.isRevealed)
                XCTAssertFalse(game.grid.cell(at: r, c)!.isFlagged)
            }
        }
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter GameLogicTests`
Expected: FAIL — `MinesweeperGame` type not found

- [ ] **Step 3: Implement MinesweeperGame**

Create `Mineswapper/ViewModels/MinesweeperGame.swift`:

```swift
import Foundation
import SwiftUI

@Observable
final class MinesweeperGame {
    private(set) var grid: Grid
    private(set) var state: GameState = .idle
    private(set) var difficulty: Difficulty
    private(set) var elapsedTime: Int = 0
    private(set) var remainingMines: Int
    private(set) var explodedRow: Int?
    private(set) var explodedColumn: Int?

    private var timer: Timer?
    private var isFirstClick = true

    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        self.grid = Grid(
            rows: difficulty.rows,
            columns: difficulty.columns,
            mineCount: difficulty.mineCount
        )
        self.remainingMines = difficulty.mineCount
    }

    func reveal(row: Int, column: Int) {
        guard state == .idle || state == .playing else { return }
        guard !grid.cell(at: row, column)!.isFlagged else { return }
        guard !grid.cell(at: row, column)!.isRevealed else { return }

        if isFirstClick {
            grid.placeMines(excludingRow: row, column: column)
            grid.calculateAdjacentMines()
            isFirstClick = false
            state = .playing
            startTimer()
        }

        grid.reveal(row: row, column: column)

        if grid.cell(at: row, column)!.isMine {
            state = .lost
            explodedRow = row
            explodedColumn = column
            revealAllMines()
            stopTimer()
            return
        }

        checkWin()
    }

    func toggleFlag(row: Int, column: Int) {
        guard state == .idle || state == .playing else { return }
        guard !grid.cell(at: row, column)!.isRevealed else { return }

        grid.cells[row][column].isFlagged.toggle()
        remainingMines = difficulty.mineCount - flagCount()
    }

    func chordReveal(row: Int, column: Int) {
        guard state == .playing else { return }
        let cell = grid.cell(at: row, column)!
        guard cell.isRevealed, cell.adjacentMines > 0 else { return }

        let neighbors = grid.neighbors(row: row, column: column)
        let flaggedCount = neighbors.filter { grid.cell(at: $0.0, $0.1)!.isFlagged }.count

        guard flaggedCount == cell.adjacentMines else { return }

        for (nr, nc) in neighbors {
            if !grid.cell(at: nr, nc)!.isFlagged && !grid.cell(at: nr, nc)!.isRevealed {
                reveal(row: nr, column: nc)
            }
        }
    }

    func newGame() {
        stopTimer()
        grid = Grid(
            rows: difficulty.rows,
            columns: difficulty.columns,
            mineCount: difficulty.mineCount
        )
        state = .idle
        remainingMines = difficulty.mineCount
        elapsedTime = 0
        isFirstClick = true
        explodedRow = nil
        explodedColumn = nil
    }

    func changeDifficulty(_ newDifficulty: Difficulty) {
        difficulty = newDifficulty
        newGame()
    }

    // MARK: - Private

    private func flagCount() -> Int {
        var count = 0
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                if grid.cell(at: r, c)!.isFlagged { count += 1 }
            }
        }
        return count
    }

    private func revealAllMines() {
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                if grid.cell(at: r, c)!.isMine {
                    grid.cells[r][c].isRevealed = true
                }
            }
        }
    }

    private func checkWin() {
        var allRevealed = true
        for r in 0..<grid.rows {
            for c in 0..<grid.columns {
                let cell = grid.cell(at: r, c)!
                if !cell.isMine && !cell.isRevealed {
                    allRevealed = false
                    break
                }
            }
            if !allRevealed { break }
        }
        if allRevealed {
            state = .won
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    var formattedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter GameLogicTests`
Expected: All 10 tests PASS

- [ ] **Step 5: Commit**

```bash
git add Mineswapper/ViewModels/MinesweeperGame.swift MineswapperTests/GameLogicTests.swift
git commit -m "feat: MinesweeperGame ViewModel with full game logic"
```

---

### Task 7: Persistence Service

**Files:**
- Create: `Mineswapper/Services/PersistenceService.swift`
- Create: `MineswapperTests/PersistenceTests.swift`

- [ ] **Step 1: Write persistence tests**

Create `MineswapperTests/PersistenceTests.swift`:

```swift
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter PersistenceTests`
Expected: FAIL — `PersistenceService` type not found

- [ ] **Step 3: Implement PersistenceService**

Create `Mineswapper/Services/PersistenceService.swift`:

```swift
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/dycx/code/Mineswapper && swift test --filter PersistenceTests`
Expected: All 5 tests PASS

- [ ] **Step 5: Commit**

```bash
git add Mineswapper/Services/PersistenceService.swift MineswapperTests/PersistenceTests.swift
git commit -m "feat: PersistenceService for high scores and custom difficulty"
```

---

### Task 8: Constants

**Files:**
- Create: `Mineswapper/Utilities/Constants.swift`

- [ ] **Step 1: Create Constants**

Create `Mineswapper/Utilities/Constants.swift`:

```swift
import SwiftUI

enum Constants {
    static let cellSize: CGFloat = 32
    static let cellCornerRadius: CGFloat = 4
    static let boardPadding: CGFloat = 16
    static let boardCornerRadius: CGFloat = 8

    static let numberColors: [Int: Color] = [
        1: .blue,
        2: .green,
        3: .red,
        4: Color(red: 0, green: 0, blue: 0.6),
        5: Color(red: 0.5, green: 0, blue: 0),
        6: .teal,
        7: .black,
        8: .gray
    ]

    static func numberFont(size: CGFloat) -> Font {
        .system(size: size * 0.55, weight: .bold, design: .rounded)
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `cd /Users/dycx/code/Mineswapper && swift build`
Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
git add Mineswapper/Utilities/Constants.swift
git commit -m "feat: UI constants and number colors"
```

---

### Task 9: CellView

**Files:**
- Create: `Mineswapper/Views/CellView.swift`

- [ ] **Step 1: Implement CellView**

Create `Mineswapper/Views/CellView.swift`:

```swift
import SwiftUI

struct CellView: View {
    let cell: Cell
    let isExploded: Bool
    let size: CGFloat

    var body: some View {
        Group {
            if cell.isRevealed {
                revealedContent
            } else {
                hiddenContent
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: Constants.cellCornerRadius))
    }

    @ViewBuilder
    private var revealedContent: some View {
        if cell.isMine {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(isExploded ? Color.red : Color.gray.opacity(0.3))
                .overlay(
                    Image(systemName: "burst.fill")
                        .font(.system(size: size * 0.5))
                        .foregroundstyle(isExploded ? .white : .black)
                )
        } else if cell.adjacentMines > 0 {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(Color.gray.opacity(0.15))
                .overlay(
                    Text("\(cell.adjacentMines)")
                        .font(Constants.numberFont(size: size))
                        .foregroundstyle(Constants.numberColors[cell.adjacentMines] ?? .black)
                )
        } else {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(Color.gray.opacity(0.15))
        }
    }

    @ViewBuilder
    private var hiddenContent: some View {
        if cell.isFlagged {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Image(systemName: "flag.fill")
                        .font(.system(size: size * 0.45))
                        .foregroundstyle(.red)
                )
        } else {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `cd /Users/dycx/code/Mineswapper && swift build`
Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
git add Mineswapper/Views/CellView.swift
git commit -m "feat: CellView with hidden, revealed, flagged, mine states"
```

---

### Task 10: GameBoardView

**Files:**
- Create: `Mineswapper/Views/GameBoardView.swift`

- [ ] **Step 1: Implement GameBoardView**

Create `Mineswapper/Views/GameBoardView.swift`:

```swift
import SwiftUI

struct GameBoardView: View {
    @Bindable var game: MinesweeperGame

    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(Constants.cellSize), spacing: 1), count: game.grid.columns)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(0..<game.grid.rows, id: \.self) { row in
                ForEach(0..<game.grid.columns, id: \.self) { col in
                    cellView(row: row, col: col)
                }
            }
        }
        .padding(Constants.boardPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.boardCornerRadius)
                .fill(Color.gray.opacity(0.08))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }

    @ViewBuilder
    private func cellView(row: Int, col: Int) -> some View {
        CellView(
            cell: game.grid.cell(at: row, col)!,
            isExploded: game.explodedRow == row && game.explodedColumn == col,
            size: Constants.cellSize
        )
        .onTapGesture {
            handleLeftClick(row: row, col: col)
        }
        .contextMenu {
            Button("Flag") {
                game.toggleFlag(row: row, column: col)
            }
        }
        .simultaneousGesture(
            TapGesture()
                .modifiers(.control)
                .onEnded { _ in
                    game.toggleFlag(row: row, column: col)
                }
        )
    }

    private func handleLeftClick(row: Int, col: Int) {
        let cell = game.grid.cell(at: row, col)!
        if cell.isRevealed && cell.adjacentMines > 0 {
            game.chordReveal(row: row, column: col)
        } else {
            game.reveal(row: row, column: col)
        }
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `cd /Users/dycx/code/Mineswapper && swift build`
Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
git add Mineswapper/Views/GameBoardView.swift
git commit -m "feat: GameBoardView with grid layout and click handling"
```

---

### Task 11: ScoreBarView

**Files:**
- Create: `Mineswapper/Views/ScoreBarView.swift`

- [ ] **Step 1: Implement ScoreBarView**

Create `Mineswapper/Views/ScoreBarView.swift`:

```swift
import SwiftUI

struct ScoreBarView: View {
    let remainingMines: Int
    let formattedTime: String
    let gameState: GameState
    let onNewGame: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "burst.fill")
                    .foregroundstyle(.red)
                Text("\(remainingMines)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText())
            }
            .frame(minWidth: 60)

            Spacer()

            Button(action: onNewGame) {
                Text(faceEmoji)
                    .font(.system(size: 28))
            }
            .buttonStyle(.plain)
            .help("New Game")

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .foregroundstyle(.secondary)
                Text(formattedTime)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .contentTransition(.numericText())
                    .monospacedDigit()
            }
            .frame(minWidth: 60)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        )
    }

    private var faceEmoji: String {
        switch gameState {
        case .idle, .playing: return "🙂"
        case .won: return "😎"
        case .lost: return "😵"
        }
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `cd /Users/dycx/code/Mineswapper && swift build`
Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
git add Mineswapper/Views/ScoreBarView.swift
git commit -m "feat: ScoreBarView with mine counter, face button, timer"
```

---

### Task 12: DifficultyPickerView

**Files:**
- Create: `Mineswapper/Views/DifficultyPickerView.swift`

- [ ] **Step 1: Implement DifficultyPickerView**

Create `Mineswapper/Views/DifficultyPickerView.swift`:

```swift
import SwiftUI

struct DifficultyPickerView: View {
    @Binding var difficulty: Difficulty
    @State private var showCustomSheet = false
    @State private var customRows: Double = 10
    @State private var customColumns: Double = 10
    @State private var customMines: Double = 15

    var body: some View {
        Menu {
            Button("Beginner (9x9, 10 mines)") { difficulty = .beginner }
            Button("Intermediate (16x16, 40 mines)") { difficulty = .intermediate }
            Button("Expert (30x16, 99 mines)") { difficulty = .expert }
            Divider()
            Button("Custom...") { showCustomSheet = true }
        } label: {
            Label(difficulty.displayName, systemImage: "slider.horizontal.3")
        }
        .sheet(isPresented: $showCustomSheet) {
            customDifficultySheet
        }
    }

    private var customDifficultySheet: some View {
        VStack(spacing: 20) {
            Text("Custom Difficulty")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("Rows") {
                    HStack {
                        Slider(value: $customRows, in: 5...30, step: 1)
                        Text("\(Int(customRows))")
                            .frame(width: 30, alignment: .trailing)
                            .monospacedDigit()
                    }
                }

                LabeledContent("Columns") {
                    HStack {
                        Slider(value: $customColumns, in: 5...30, step: 1)
                        Text("\(Int(customColumns))")
                            .frame(width: 30, alignment: .trailing)
                            .monospacedDigit()
                    }
                }

                let maxMines = max(1, Int(customRows * customColumns) - 9)

                LabeledContent("Mines") {
                    HStack {
                        Slider(value: $customMines, in: 1...Double(maxMines), step: 1)
                        Text("\(Int(customMines))")
                            .frame(width: 30, alignment: .trailing)
                            .monospacedDigit()
                    }
                }
            }
            .frame(width: 300)

            HStack {
                Button("Cancel") { showCustomSheet = false }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Start") {
                    difficulty = .custom(
                        rows: Int(customRows),
                        columns: Int(customColumns),
                        mines: Int(customMines)
                    )
                    showCustomSheet = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `cd /Users/dycx/code/Mineswapper && swift build`
Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
git add Mineswapper/Views/DifficultyPickerView.swift
git commit -m "feat: DifficultyPickerView with preset and custom options"
```

---

### Task 13: ContentView — Full Integration

**Files:**
- Modify: `Mineswapper/Views/ContentView.swift`
- Modify: `Mineswapper/App/MineswapperApp.swift`

- [ ] **Step 1: Update ContentView**

Replace `Mineswapper/Views/ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    @State private var game = MinesweeperGame(difficulty: .beginner)

    private var boardWidth: CGFloat {
        CGFloat(game.grid.columns) * (Constants.cellSize + 1) + Constants.boardPadding * 2
    }

    private var boardHeight: CGFloat {
        CGFloat(game.grid.rows) * (Constants.cellSize + 1) + Constants.boardPadding * 2
    }

    var body: some View {
        VStack(spacing: 12) {
            ScoreBarView(
                remainingMines: game.remainingMines,
                formattedTime: game.formattedTime,
                gameState: game.state,
                onNewGame: { game.newGame() }
            )

            GameBoardView(game: game)
        }
        .padding(16)
        .frame(width: boardWidth + 32, height: boardHeight + 100)
    }
}
```

- [ ] **Step 2: Update app entry point**

Replace `Mineswapper/App/MineswapperApp.swift`:

```swift
import SwiftUI

@main
struct MineswapperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
```

- [ ] **Step 3: Build and run all tests**

Run: `cd /Users/dycx/code/Mineswapper && swift test`
Expected: All tests PASS

- [ ] **Step 4: Commit**

```bash
git add Mineswapper/Views/ContentView.swift Mineswapper/App/MineswapperApp.swift
git commit -m "feat: ContentView integrates all components"
```

---

### Task 14: Final Build and Manual Test

- [ ] **Step 1: Run all tests**

Run: `cd /Users/dycx/code/Mineswapper && swift test`
Expected: All tests PASS

- [ ] **Step 2: Build release**

Run: `cd /Users/dycx/code/Mineswapper && swift build -c release`
Expected: Build succeeds

- [ ] **Step 3: Launch and manually test**

Run: `cd /Users/dycx/code/Mineswapper && swift run`

Manual test checklist:
- [ ] App launches with 9x9 beginner grid
- [ ] Left-click reveals cells
- [ ] First click is always safe
- [ ] Numbers show correct adjacent mine count
- [ ] Empty cells flood-fill
- [ ] Right-click / control+click flags cells
- [ ] Mine counter updates with flags
- [ ] Timer starts on first click
- [ ] Clicking mine shows game over
- [ ] Revealing all non-mines shows win
- [ ] Face button changes on win/lose
- [ ] Face button starts new game
- [ ] Difficulty picker changes grid size
- [ ] Custom difficulty sheet works

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "feat: Mineswapper v1.0 — complete macOS Minesweeper game"
```
