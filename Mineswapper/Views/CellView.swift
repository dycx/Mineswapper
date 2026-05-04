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
                        .foregroundStyle(isExploded ? .white : .black)
                )
        } else if cell.adjacentMines > 0 {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(Color.gray.opacity(0.15))
                .overlay(
                    Text("\(cell.adjacentMines)")
                        .font(Constants.numberFont(size: size))
                        .foregroundStyle(Constants.numberColors[cell.adjacentMines] ?? .black)
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
                        .foregroundStyle(.red)
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
