// CellView.swift
// Mineswapper - Apple-inspired cell visualization

import SwiftUI

struct CellView: View {
    let cell: Cell
    let isExploded: Bool
    var isRecommended: Bool = false
    var isGuaranteedMine: Bool = false
    var probability: Double? = nil
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
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .animation(.easeInOut(duration: Constants.animationDuration), value: cell.isRevealed)
    }
    
    // MARK: - Border Styling
    
    private var borderColor: Color {
        if isRecommended {
            return Constants.accentColor
        } else if isGuaranteedMine {
            return .orange
        } else if let prob = probability, prob > 0.7 {
            return .red.opacity(0.5)
        }
        return .clear
    }
    
    private var borderWidth: CGFloat {
        isRecommended || isGuaranteedMine ? 2 : 0
    }
    
    // MARK: - Revealed Content
    
    @ViewBuilder
    private var revealedContent: some View {
        if cell.isMine {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(isExploded ? Color.red : Constants.cellRevealedBackground)
                .overlay(
                    Image(systemName: "burst.fill")
                        .font(.system(size: size * 0.45))
                        .foregroundStyle(isExploded ? .white : .black)
                )
        } else if cell.adjacentMines > 0 {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(Constants.cellRevealedBackground)
                .overlay(
                    Text("\(cell.adjacentMines)")
                        .font(Constants.numberFont(size: size))
                        .foregroundStyle(Constants.numberColors[cell.adjacentMines] ?? .black)
                )
        } else {
            RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                .fill(Constants.cellRevealedBackground)
        }
    }
    
    // MARK: - Hidden Content
    
    @ViewBuilder
    private var hiddenContent: some View {
        ZStack {
            if cell.isFlagged {
                RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [Constants.cellFlaggedGradientStart, Constants.cellFlaggedGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "flag.fill")
                            .font(.system(size: size * 0.40))
                            .foregroundStyle(.red)
                    )
            } else {
                RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [Constants.cellHiddenGradientStart, Constants.cellHiddenGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Probability overlay
            if let prob = probability {
                RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                    .fill(Constants.probabilityColor(probability: prob))
                    .overlay(
                        Text("\(Int(prob * 100))%")
                            .font(.system(size: size * 0.25, weight: .medium, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.6))
                    )
            }
            
            // AI recommendation indicator
            if isRecommended {
                RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                    .fill(Constants.accentColor.opacity(0.15))
                    .overlay(
                        Image(systemName: "star.fill")
                            .font(.system(size: size * 0.30))
                            .foregroundStyle(Constants.accentColor)
                    )
            }
            
            // Guaranteed mine indicator
            if isGuaranteedMine {
                RoundedRectangle(cornerRadius: Constants.cellCornerRadius)
                    .fill(Color.orange.opacity(0.15))
                    .overlay(
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: size * 0.30))
                            .foregroundStyle(.orange)
                    )
            }
        }
    }
}
