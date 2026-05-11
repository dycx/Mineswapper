# AI Minesweeper Technical Plan

## Technical Direction

**Hybrid AI Approach**: Constraint-based solver + Monte Carlo simulation + Game analytics

### Why This Approach?

Minesweeper is fundamentally a **constraint satisfaction problem** with probabilistic elements:
- ~80% of moves can be determined deterministically via constraint propagation
- ~20% require probabilistic reasoning (Monte Carlo)
- LLM is NOT suitable for core gameplay (deterministic game, not natural language)
- LLM IS useful for: natural language explanations, hints, strategy analysis

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    MinesweeperGame                       │
│                    (ViewModel layer)                     │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  Constraint  │  │   Monte     │  │    Game      │    │
│  │   Solver     │  │   Carlo     │  │  Analytics   │    │
│  │  (Phase 1)   │  │  (Phase 2)  │  │  (Phase 3)   │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                 │                 │            │
│         └─────────────────┼─────────────────┘            │
│                           │                              │
│                    ┌──────┴───────┐                      │
│                    │  AI Engine   │                      │
│                    │  (Unified)   │                      │
│                    └──────┬───────┘                      │
│                           │                              │
│                    ┌──────┴───────┐                      │
│                    │  LLM Bridge  │                      │
│                    │  (Optional)  │                      │
│                    └──────────────┘                      │
└─────────────────────────────────────────────────────────┘
```

## Phase 1: Constraint-Based Solver

### Algorithm
1. For each revealed cell with `adjacentMines > 0`:
   - Count unrevealed neighbors
   - Count flagged neighbors
   - If `adjacentMines == flaggedCount` → all unrevealed neighbors are SAFE
   - If `adjacentMines == unrevealedCount` → all unrevealed neighbors are MINES

2. Propagate constraints iteratively until no new deductions

3. Return: `(safeCells: [(Int,Int)], mineCells: [(Int,Int)])`

### Complexity
- O(n) per constraint pass, where n = number of revealed cells
- Typically converges in 2-3 passes
- Handles ~80% of game situations

## Phase 2: Monte Carlo Simulation

### Algorithm
1. When constraints can't determine a move:
   - Generate N random board configurations (default: 1000)
   - Each configuration must satisfy all known constraints
   - For each unrevealed cell, count how often it's a mine
   - Return mine probability map

2. Choose: cell with lowest mine probability

### Optimization
- Use backtracking with constraint checking (not pure random)
- Early termination when enough samples collected
- Cache constraint states for efficiency

### Key Parameters
- `sampleCount`: Number of simulations (100-1000)
- `confidenceThreshold`: Minimum confidence for a move (0.6)

## Phase 3: Game Analytics

### Data Collection
```swift
struct GameRecord: Codable {
    let id: UUID
    let difficulty: Difficulty
    let startTime: Date
    let endTime: Date?
    let outcome: GameState  // won/lost
    let totalMoves: Int
    let solverMoves: Int    // moves by constraint solver
    let monteCarloMoves: Int // moves by Monte Carlo
    let guessMoves: Int     // pure guesses
    let moveHistory: [MoveRecord]
}

struct MoveRecord: Codable {
    let position: (Int, Int)
    let moveType: MoveType  // reveal/flag/chord
    let aiStrategy: AIStrategy // constraint/montecarlo/guess
    let mineProbability: Double?
    let timestamp: Date
}

enum AIStrategy: String, Codable {
    case constraint
    case monteCarlo
    case guess
    case human
}
```

### Analytics Dashboard
- Win rate by difficulty
- Average game duration
- Strategy distribution (constraint vs Monte Carlo vs guess)
- Improvement trend over time
- Best/worst game records

## Phase 4: LLM Integration (Optional)

### Use Cases
1. **Move Explanation**: "Why did the AI reveal cell (3,5)?"
   - Input: board state, chosen move, solver reasoning
   - Output: Natural language explanation

2. **Hint System**: Player asks for hint
   - Input: current board state
   - Output: Suggested move with explanation

3. **Strategy Summary**: After game ends
   - Input: game record
   - Output: Analysis of what went well/poorly

### Implementation
- Connect to LM Studio at `http://127.0.0.1:1234/v1`
- Use OpenAI-compatible API
- Prompt engineering for concise, helpful responses
- Fallback gracefully if LM Studio unavailable

## UI Design (Apple-Inspired)

### Design Principles
1. **Minimalist**: Clean surfaces, generous whitespace
2. **System fonts**: SF Pro (native macOS)
3. **Single accent**: Blue (#0071e3) for interactive elements
4. **Subtle depth**: Soft shadows, translucent surfaces
5. **Smooth animations**: 0.2-0.3s transitions

### New UI Components
1. **AI Control Panel**: Auto-play toggle, speed control, strategy selector
2. **Statistics Dashboard**: Win rates, charts, game history
3. **LLM Chat Panel**: Ask questions, get explanations
4. **Enhanced Cell View**: Probability overlay, solver indicators

## Implementation Order

1. ✅ Technical plan (this document)
2. Constraint-based solver
3. Monte Carlo simulation
4. AI Engine (unified interface)
5. Game analytics system
6. UI redesign (Apple-inspired)
7. AI control panel
8. LLM integration
9. Testing and polish

## File Structure

```
Mineswapper/
├── App/
│   └── MineswapperApp.swift
├── Models/
│   ├── Cell.swift
│   ├── Grid.swift
│   ├── GameState.swift
│   ├── Difficulty.swift
│   └── GameRecord.swift        # NEW: Analytics data model
├── AI/
│   ├── ConstraintSolver.swift  # NEW: Phase 1
│   ├── MonteCarloSolver.swift  # NEW: Phase 2
│   ├── AIEngine.swift          # NEW: Unified AI interface
│   └── LLMBridge.swift         # NEW: LM Studio integration
├── Services/
│   ├── PersistenceService.swift
│   └── AnalyticsService.swift  # NEW: Game analytics
├── ViewModels/
│   ├── MinesweeperGame.swift   # MODIFIED: AI integration
│   └── StatisticsViewModel.swift # NEW: Stats dashboard
├── Views/
│   ├── ContentView.swift       # MODIFIED: Apple design
│   ├── GameBoardView.swift     # MODIFIED: Probability overlay
│   ├── CellView.swift          # MODIFIED: AI indicators
│   ├── ScoreBarView.swift      # MODIFIED: Apple design
│   ├── AIControlPanel.swift    # NEW: AI controls
│   ├── StatisticsView.swift    # NEW: Analytics dashboard
│   └── LLMChatView.swift       # NEW: LLM interaction
└── Utilities/
    └── Constants.swift         # MODIFIED: New design tokens
```
