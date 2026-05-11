// ScoreBarView.swift
// Mineswapper - Apple-inspired score bar

import SwiftUI

struct ScoreBarView: View {
    let remainingMines: Int
    let formattedTime: String
    let gameState: GameState
    let onNewGame: () -> Void
    
    var body: some View {
        HStack(spacing: Constants.spacingXL) {
            // Mine Counter
            HStack(spacing: Constants.spacingS) {
                Image(systemName: "flag.fill")
                    .foregroundStyle(.red)
                    .font(.title3)
                
                Text("\(remainingMines)")
                    .font(Constants.scoreFont)
                    .foregroundStyle(Constants.textPrimary)
                    .monospacedDigit()
            }
            .frame(minWidth: 80)
            
            Spacer()
            
            // New Game Button (always visible and prominent)
            Button(action: onNewGame) {
                HStack(spacing: Constants.spacingS) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.body)
                    
                    Text("New Game")
                        .font(Constants.bodyFont.weight(.semibold))
                }
                .foregroundStyle(Constants.accentColor)
                .padding(.horizontal, Constants.spacingL)
                .padding(.vertical, Constants.spacingM)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Constants.accentColor.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Constants.accentColor, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Timer
            HStack(spacing: Constants.spacingS) {
                Image(systemName: "clock")
                    .foregroundStyle(Constants.accentColor)
                    .font(.title3)
                
                Text(formattedTime)
                    .font(Constants.scoreFont)
                    .foregroundStyle(Constants.textPrimary)
                    .monospacedDigit()
            }
            .frame(minWidth: 80)
        }
        .padding(.horizontal, Constants.spacingL)
        .padding(.vertical, Constants.spacingM)
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
}
