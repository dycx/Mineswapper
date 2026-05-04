# Mineswapper — macOS Minesweeper Game Design

## Overview

A classic Minesweeper game for macOS built with SwiftUI, following modern macOS development practices. All classic Minesweeper rules apply: reveal cells, flag mines, use number hints, avoid exploding.

## Visual Style

Modern native macOS — clean SwiftUI-native look with system colors, rounded corners, subtle shadows. Follows Apple HIG. Polished utility-app aesthetic.

## Architecture

MVVM with `@Observable` macro (macOS 14+). Pure SPM build system with `Package.swift`.

### Project Structure

```
Mineswapper/
├── App/
│   └── MineswapperApp.swift
├── Models/
│   ├── Cell.swift
│   ├── Grid.swift
│   ├── GameState.swift
│   └── Difficulty.swift
├── ViewModels/
│   └── MinesweeperGame.swift
├── Views/
│   ├── ContentView.swift
│   ├── GameBoardView.swift
│   ├── CellView.swift
│   ├── ScoreBarView.swift
│   └── DifficultyPickerView.swift
├── Services/
│   └── PersistenceService.swift
└── Utilities/
    └── Constants.swift
MineswapperTests/
├── GridTests.swift
├── GameLogicTests.swift
└── FloodFillTests.swift
```

### Key Types

- **Cell**: struct — `isMine`, `isRevealed`, `isFlagged`, `adjacentMines` (computed from grid position)
- **Grid**: 2D array of Cell — mine placement, flood-fill reveal, adjacency calculation
- **GameState**: enum `.playing`, `.won`, `.lost`
- **Difficulty**: enum `.beginner` (9x9, 10 mines), `.intermediate` (16x16, 40 mines), `.expert` (30x16, 99 mines), `.custom(rows:cols:mines:)`

## Game Logic

### Grid Initialization

Mines placed randomly after first click. First-clicked cell and its 8 neighbors are excluded from mine placement, ensuring the first click is always safe and often reveals a region.

### Cell Reveal (Left Click)

1. If cell is flagged -> no action
2. If cell is mine -> game over, reveal all mines, highlight exploded mine
3. If adjacentMines > 0 -> reveal cell, show number
4. If adjacentMines == 0 -> BFS flood-fill: reveal cell, then recursively reveal all neighbors (stopping at cells with adjacentMines > 0)

### Flag Toggle (Right Click)

Toggle flag on hidden cells only. Update mine counter display.

### Chord Click

Left-click on a revealed number cell. If the count of adjacent flags equals the cell's number, reveal all unflagged adjacent hidden cells (applying normal reveal rules recursively).

### Win/Lose Detection

- **Win:** All non-mine cells are revealed
- **Lose:** A mine cell is revealed (via direct click or chord)

### Timer

- Starts on first cell click
- Stops on win or lose
- Display format: `MM:SS`
- Resets on new game

### Mine Counter

Display: `totalMines - flaggedCells`. Updates in real-time as flags are toggled.

## UI Design

### ContentView

- **Top bar (ScoreBarView):** Mine counter (left), face button (center), timer (right) — in a rounded-rect bar with subtle shadow
- **Game board (GameBoardView):** Centered grid with padding
- **Toolbar:** "New Game" button, difficulty picker (native `Picker` with menu style)

### GameBoardView

- `LazyVGrid` with adaptive columns sized to cell dimensions (~32pt)
- Subtle rounded-rect background with shadow
- Scales cell size slightly for larger grids to fit window

### CellView States

| State | Appearance |
|-------|-----------|
| Hidden | Rounded rect, light gray gradient (modern beveled look) |
| Revealed empty | Flat, slightly darker background |
| Revealed number | Colored number text (1=blue, 2=green, 3=red, 4=darkBlue, 5=maroon, 6=teal, 7=black, 8=gray) |
| Flagged | Flag SF Symbol in red |
| Mine (game over) | Mine SF Symbol on red background |
| Exploded mine | Red background with distinct highlight |

### Face Button

- Normal: smiley face
- Game won: sunglasses face
- Game lost: X-eyes face
- Clicking: starts new game

### Difficulty Picker

- macOS native `Picker` with menu style
- Options: Beginner, Intermediate, Expert, Custom...
- "Custom..." opens a sheet with sliders for rows (5-30), columns (5-30), mines (1 to rows*cols-9)

## Animations

- **Cell reveal:** Subtle scale + fade-in
- **Flood-fill cascade:** Slight per-cell delay for visual wave effect
- **Win:** Brief confetti-like particle burst
- **Lose:** Subtle shake + sequential mine reveal

## Persistence

### High Scores

Stored in `UserDefaults` as a dictionary keyed by difficulty name. Each entry: `{ bestTime: Int, date: Date }`. Displayed in difficulty picker or a separate high scores sheet.

### Game State

Saved to `~/Library/Application Support/Mineswapper/gamestate.json`:
- Grid state (each cell's isMine, isRevealed, isFlagged)
- Elapsed time
- Difficulty configuration
- Restored on app relaunch if game was in progress

### Custom Difficulty

Saved in `UserDefaults` under key `customDifficulty`.

## Build System

- Pure SPM: `Package.swift` with `.executableTarget` and `.testTarget`
- Platform: macOS 14+
- No external dependencies
- Swift 5.9+

## Testing

Unit tests for:
- Grid initialization and mine placement
- First-click safety guarantee
- Flood-fill reveal logic
- Adjacent mine counting
- Win/lose detection
- Chord click behavior
- Timer start/stop/reset
- Persistence save/load
