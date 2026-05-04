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
