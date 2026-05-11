// ContentView.swift
// Mineswapper - Main view with self-play visualization

import SwiftUI
import AppKit

struct ContentView: View {
    @State private var game = MinesweeperGame(difficulty: .beginner)
    @State private var showAIPanel = true
    
    private var boardWidth: CGFloat {
        CGFloat(game.grid.columns) * (Constants.cellSize + 1) + Constants.boardPadding * 2
    }
    
    var body: some View {
        HSplitView {
            // Main Game Area
            VStack(spacing: Constants.spacingL) {
                // Score Bar
                ScoreBarView(
                    remainingMines: game.remainingMines,
                    formattedTime: game.formattedTime,
                    gameState: game.state,
                    onNewGame: { game.newGame() }
                )
                
                // Game Board with overlay
                ZStack {
                    GameBoardView(game: game)
                    
                    // Game over overlay (only when NOT self-playing)
                    if (game.state == .won || game.state == .lost) && !game.isSelfPlaying {
                        gameOverOverlay
                    }
                    
                    // Self-play thinking indicator
                    if game.isThinking {
                        thinkingOverlay
                    }
                }
                
                // Game status bar
                gameStatusBar
            }
            .padding(Constants.spacingXL)
            .frame(minWidth: boardWidth + 48)
            
            // AI Panel (Sidebar)
            if showAIPanel {
                ScrollView {
                    AIControlPanel(game: game)
                }
                .frame(width: 320)
                .background(Constants.backgroundPrimary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                DifficultyPickerView(difficulty: Binding(
                    get: { game.difficulty },
                    set: { game.changeDifficulty($0) }
                ))
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        showAIPanel.toggle()
                    }
                } label: {
                    Image(systemName: "sidebar.right")
                        .foregroundStyle(Constants.accentColor)
                }
                .help("Toggle AI Panel")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    game.newGame()
                } label: {
                    Label("New Game", systemImage: "arrow.counterclockwise")
                }
                .tint(Constants.accentColor)
            }
        }
        .onChange(of: game.state) { _, newValue in
            if newValue == .won && !game.isSelfPlaying {
                NSSound(named: "Hero")?.play()
            } else if newValue == .lost && !game.isSelfPlaying {
                NSSound(named: "Funk")?.play()
            }
        }
        .background(Constants.backgroundPrimary)
    }
    
    // MARK: - Thinking Overlay
    
    private var thinkingOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.boardCornerRadius)
                .fill(.ultraThinMaterial)
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("AI Thinking...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Constants.textSecondary)
            }
        }
        .allowsHitTesting(false)
    }
    
    // MARK: - Game Over Overlay
    
    private var gameOverOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.boardCornerRadius)
                .fill(.ultraThinMaterial)
            
            VStack(spacing: Constants.spacingXL) {
                // Icon
                Image(systemName: game.state == .won ? "trophy.fill" : "xmark.octagon.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(game.state == .won ? .yellow : .red)
                
                // Title
                Text(game.state == .won ? "You Won!" : "Game Over")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Constants.textPrimary)
                
                // Stats
                VStack(spacing: Constants.spacingS) {
                    Text("Time: \(game.formattedTime)")
                        .font(Constants.bodyFont)
                    
                    if let record = game.currentGameRecord {
                        Text("Moves: \(record.totalMoves)")
                            .font(Constants.bodyFont)
                        
                        HStack(spacing: 12) {
                            Label("\(record.constraintMoves)", systemImage: "brain")
                                .foregroundStyle(Constants.accentColor)
                            Label("\(record.monteCarloMoves)", systemImage: "dice")
                                .foregroundStyle(.purple)
                            Label("\(record.guessMoves)", systemImage: "questionmark.circle")
                                .foregroundStyle(.orange)
                        }
                        .font(Constants.captionFont)
                    }
                }
                .foregroundStyle(Constants.textSecondary)
                
                // New Game button
                Button {
                    game.newGame()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("New Game")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Constants.accentColor)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(40)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.3), value: game.state)
    }
    
    // MARK: - Game Status Bar
    
    private var gameStatusBar: some View {
        HStack {
            // Self-play status
            if game.isSelfPlaying {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .foregroundStyle(.green)
                    
                    Text(game.selfPlayStatus)
                        .font(Constants.captionFont)
                        .foregroundStyle(Constants.textPrimary)
                }
            } else if let analysis = game.currentAnalysis {
                // Current strategy indicator
                HStack(spacing: 8) {
                    Image(systemName: Constants.strategyIcon(for: analysis.strategy))
                        .foregroundStyle(Constants.accentColor)
                    
                    Text("AI: \(analysis.strategy.displayName)")
                        .font(Constants.captionFont)
                        .foregroundStyle(Constants.textSecondary)
                    
                    Text("•")
                        .foregroundStyle(Constants.textTertiary)
                    
                    Text("Confidence: \(Int(analysis.confidence * 100))%")
                        .font(Constants.captionFont)
                        .foregroundStyle(Constants.textSecondary)
                }
            }
            
            Spacer()
            
            // Game state
            HStack(spacing: 8) {
                Circle()
                    .fill(game.state == .playing ? .green : game.state == .won ? .yellow : game.state == .lost ? .red : .gray)
                    .frame(width: 8, height: 8)
                
                Text(game.state == .playing ? "Playing" : game.state == .won ? "Won" : game.state == .lost ? "Lost" : "Ready")
                    .font(Constants.captionFont)
                    .foregroundStyle(Constants.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Constants.backgroundSecondary)
        )
    }
}
