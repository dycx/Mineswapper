# Mineswapper Bug Report

**Generated:** 2026-05-12
**Branch:** feature/ai-integration
**Build:** Clean (0 warnings, 0 errors)
**Tests:** 45/45 passed

---

## Critical Severity

### BUG-001: Untracked delayed dispatches can restart self-play after stop

**File:** `Mineswapper/ViewModels/MinesweeperGame.swift:299`

`handleGameEnd()` schedules a delayed dispatch to call `startNewSelfPlayGame()` after 1.5 seconds. This dispatch is never tracked or cancellable. If the user calls `stopSelfPlay()` and then `startSelfPlay()` before that 1.5-second window elapses, the stale dispatch fires alongside the new game, potentially causing two concurrent game loops.

**Reproduction:**
1. Start self-play, let a game complete
2. Within 1.5s of game end, press Stop then immediately press Start
3. Two game loops run concurrently, `newGame()` gets called mid-game

**Fix:** Store `DispatchWorkItem` from `asyncAfter` and cancel it in `stopSelfPlay()`/`newGame()`, or use a generation counter.

---

### BUG-002: Data race on `AIEngine.monteCarloSamples` across threads

**File:** `Mineswapper/ViewModels/MinesweeperGame.swift:7, 186-234`

`MinesweeperGame` is `@Observable` but has no `@MainActor` annotation. `AIEngine.monteCarloSamples` is written on the main thread (`updateStrategy()` at line 310) while being read on a background thread (`analyze()` -> `monteCarloSolver.analyze()` -> `sampleCount`). This is a data race.

**Fix:** Annotate `MinesweeperGame` with `@MainActor`, make `AIEngine` an `actor`, or ensure `monteCarloSamples` is only accessed from one thread.

---

## High Severity

### BUG-003: Timer started unnecessarily during self-play

**File:** `Mineswapper/ViewModels/MinesweeperGame.swift:63-68`

`startNewSelfPlayGame()` calls `reveal()` which triggers `startTimer()` on first click. Self-play mode uses `DispatchQueue.main.asyncAfter` for pacing — the timer serves no purpose and wastes CPU.

**Fix:** Guard `startTimer()` with `!isSelfPlaying`.

---

### BUG-004: `remainingMines` goes negative on over-flagging

**File:** `Mineswapper/ViewModels/MinesweeperGame.swift:118`

`remainingMines = difficulty.mineCount - flagCount` produces negative values when the player flags more cells than mines. The UI displays "-1", "-2", etc.

**Fix:** `remainingMines = max(0, difficulty.mineCount - flagCount)`.

---

### BUG-005: `Difficulty.clamped()` allows edge-case unwinnable configurations

**File:** `Mineswapper/Models/Difficulty.swift:60-72`

`clamped()` enforces `min(rows, 5)` and `min(columns, 5)` but does not account for the safe zone after mine placement. A 5x5 grid with 16 mines passes validation but leaves zero safe cells outside the 3x3 safe zone, making the game practically unplayable.

**Fix:** Validate `mineCount <= totalCells - 9 - 8` (safe zone + its neighbors) to guarantee flood-fill is possible.

---

### BUG-006: Hardcoded 1.5s inter-game delay ignores `selfPlaySpeed`

**File:** `Mineswapper/ViewModels/MinesweeperGame.swift:299`

The inter-game delay is hardcoded to 1.5 seconds regardless of the user-configurable `selfPlaySpeed` (0.05–1.0). At fastest speed, moves fly by but then there's a jarring 1.5s pause between games.

**Fix:** Use `max(1.0, selfPlaySpeed * 5)` or add a separate `interGameDelay` property.

---

## Medium Severity

### BUG-007: Monte Carlo data discarded when confidence < 0.5

**File:** `Mineswapper/AI/AIEngine.swift:106-139`

When Monte Carlo finds a safest cell with probability >= 0.5 (confidence <= 0.5), the code falls through to Phase 3 and picks a random cell. The probability information is thrown away.

**Fix:** In Phase 3, use `probabilityMap.safestCell` if available, falling back to random only if the map is empty.

---

### BUG-008: ConstraintSolver lacks multi-step propagation

**File:** `Mineswapper/AI/ConstraintSolver.swift:39-89`

The solver only propagates constraints based on the current grid state (player-set flags), not its own deductions. Newly discovered mine cells are not treated as flagged for adjacent constraints, missing multi-step deduction chains.

**Fix:** After each iteration, treat newly discovered mine cells as flagged and newly discovered safe cells as revealed.

---

### BUG-009: MonteCarloSolver random placement has positional bias

**File:** `Mineswapper/AI/MonteCarloSolver.swift:204-215`

The "fast path" always picks the first `mineCount` cells from the shuffled array. This creates positional bias — if constrained cells cluster at the start of the shuffled order, valid configurations may be missed.

**Fix:** Use a proper random subset selection (e.g., Fisher-Yates partial shuffle).

---

### BUG-010: `ProbabilityMap.probability()` returns 0.5 for unknown cells

**File:** `Mineswapper/AI/MonteCarloSolver.swift:21`

Cells not in the probability map (revealed, flagged, or excluded from simulation) return 0.5 (50% mine probability). This can show misleading overlays on revealed cells.

**Fix:** Return `nil` for cells not in the map (change return type to `Double?`).

---

### BUG-011: `ConfettiView` is defined but never used

**File:** `Mineswapper/Views/ConfettiView.swift` (entire file)

`ConfettiView` is a complete implementation but is never instantiated anywhere in the app. The game over overlay does not include confetti.

**Fix:** Either add `ConfettiView` to the win overlay or remove the file.

---

### BUG-012: Pre-game flagging shows incorrect mine count

**File:** `Mineswapper/ViewModels/MinesweeperGame.swift:107-119`

`toggleFlag()` allows flagging in `.idle` state (before mines are placed). This decrements `remainingMines` before the game starts, showing incorrect values (e.g., 9 instead of 10).

**Fix:** Add `guard state != .idle else { return }` to `toggleFlag()`.

---

### BUG-013: `LLMBridge.isAvailable` is not thread-safe

**File:** `Mineswapper/AI/LLMBridge.swift:35`

`isAvailable` is a `var` on a `final class` written in `checkAvailability()` (async) and read in other async methods. Potential data race under concurrent access.

**Fix:** Make `LLMBridge` an `actor` or annotate with `@MainActor`.

---

### BUG-014: `LLMBridge.queryLLM()` does not check HTTP status code

**File:** `Mineswapper/AI/LLMBridge.swift:197-213`

HTTP errors (400, 401, 500) produce a generic "Failed to parse response" error instead of reporting the actual status code.

**Fix:** Check `HTTPURLResponse.statusCode` before parsing JSON.

---

## Low Severity

### BUG-015: `Grid.init()` does not validate inputs

**File:** `Mineswapper/Models/Grid.swift:11-18`

No precondition checks for negative rows/columns or negative mine count.

**Fix:** Add `precondition(rows > 0 && columns > 0)` and `precondition(mineCount >= 0)`.

---

### BUG-016: Cell reveal animation has negligible visual effect

**File:** `Mineswapper/Views/CellView.swift:28`

`.animation()` on `isRevealed` animates the frame/overlay but the content swap (hidden to revealed) happens instantly with no transition.

**Fix:** Add `.transition(.scale.combined(with: .opacity))` or remove the animation.

---

### BUG-017: `GameRecord.duration` returns 0 for in-progress games

**File:** `Mineswapper/Services/AnalyticsService.swift:105-108`

Abandoned games without `finishGame()` always report duration as 0.

**Fix:** Return `Int(Date().timeIntervalSince(startTime))` when `endTime` is nil.

---

### BUG-018: `AnalyticsService.records` grows unbounded

**File:** `Mineswapper/Services/AnalyticsService.swift:131`

In self-play mode, records accumulate indefinitely and are persisted to `UserDefaults` on every game completion, risking size limits.

**Fix:** Cap stored records (e.g., last 1000) or use file-based persistence.

---

### BUG-019: Custom difficulty unreachable from UI

**File:** `Mineswapper/Views/DifficultyPickerView.swift:1-23`

The picker only shows Beginner, Intermediate, and Expert. `Difficulty.custom` exists in the model but has no UI path.

**Fix:** Add a "Custom" option to the picker.

---

### BUG-020: `AnalyticsService` lacks test isolation for UserDefaults

**File:** `Mineswapper/Services/AnalyticsService.swift:134`

`AnalyticsService` hardcodes `UserDefaults.standard` while `PersistenceService` supports a custom `suiteName`. Test analytics pollute standard defaults.

**Fix:** Add a `suiteName` parameter to `AnalyticsService.init()`.

---

### BUG-021: Chord reveals recorded as `.reveal` not `.chord`

**File:** `Mineswapper/ViewModels/MinesweeperGame.swift:121-136`

`chordReveal()` calls `reveal()` which records moves with `moveType: .reveal`, losing information about how the reveal was triggered.

**Fix:** Pass move type context to `reveal()` or set it based on the calling context.

---

## Summary

| Severity | Count |
|----------|-------|
| Critical | 2 |
| High | 4 |
| Medium | 8 |
| Low | 7 |
| **Total** | **21** |

### Files Affected

| File | Bug Count |
|------|-----------|
| MinesweeperGame.swift | 8 |
| AIEngine.swift | 1 |
| ConstraintSolver.swift | 1 |
| MonteCarloSolver.swift | 2 |
| LLMBridge.swift | 2 |
| Difficulty.swift | 1 |
| Grid.swift | 1 |
| CellView.swift | 1 |
| ConfettiView.swift | 1 |
| AnalyticsService.swift | 2 |
| DifficultyPickerView.swift | 1 |
