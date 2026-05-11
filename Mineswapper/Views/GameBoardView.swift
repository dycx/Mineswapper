// GameBoardView.swift
// Mineswapper - Apple-inspired game board

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
                .fill(Constants.backgroundSecondary)
                .shadow(
                    color: Constants.cardShadow,
                    radius: Constants.cardShadowRadius,
                    y: Constants.cardShadowY
                )
        )
    }
    
    @ViewBuilder
    private func cellView(row: Int, col: Int) -> some View {
        if let cell = game.grid.cell(at: row, col) {
            CellView(
                cell: cell,
                isExploded: game.explodedRow == row && game.explodedColumn == col,
                isRecommended: game.isRecommended(row: row, column: col),
                isGuaranteedMine: game.isGuaranteedMine(row: row, column: col),
                probability: game.probability(row: row, column: col),
                size: Constants.cellSize
            )
            .onTapGesture {
                handleLeftClick(row: row, col: col)
            }
            .contextMenu {
                Button {
                    game.toggleFlag(row: row, column: col)
                } label: {
                    Label("Flag", systemImage: "flag")
                }
                
                if cell.isRevealed && cell.adjacentMines > 0 {
                    Button {
                        game.chordReveal(row: row, column: col)
                    } label: {
                        Label("Chord Reveal", systemImage: "square.grid.3x3")
                    }
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
    }
    
    private func handleLeftClick(row: Int, col: Int) {
        guard let cell = game.grid.cell(at: row, col) else { return }
        if cell.isRevealed && cell.adjacentMines > 0 {
            game.chordReveal(row: row, column: col)
        } else {
            game.reveal(row: row, column: col)
        }
    }
}
