# Mineswapper

A classic Minesweeper game built with SwiftUI for macOS.

## Features

- Classic Minesweeper gameplay with tap-to-reveal and flag-to-mark mechanics
- Multiple difficulty presets (Beginner, Intermediate, Expert) and custom grid options
- Win/lose alerts with sound effects and confetti animation on victory
- Persistent game state across sessions
- Clean MVVM architecture

## Requirements

- macOS 14.0+
- Xcode 15+
- Swift 5.9+

## Getting Started

Clone the repository and run with Swift Package Manager:

```bash
git clone https://github.com/dycx/Mineswapper.git
cd Mineswapper
swift run
```

Or open the project in Xcode and run directly.

## Project Structure

```
Mineswapper/
├── App/            # App entry point
├── Models/         # Data models (Cell, Grid, GameState, Difficulty)
├── ViewModels/     # Game logic (MinesweeperGame)
├── Views/          # SwiftUI views (ContentView, GameBoardView, CellView, etc.)
├── Services/       # Persistence layer
└── Utilities/      # Constants and helpers
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
