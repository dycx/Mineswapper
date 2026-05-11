// AIControlPanel.swift
// Mineswapper - AI control panel with self-play mode

import SwiftUI

struct AIControlPanel: View {
    @Bindable var game: MinesweeperGame
    @State private var showingStats = false
    @State private var hintMessage: String?
    
    var body: some View {
        VStack(spacing: Constants.spacingL) {
            // Header
            headerSection
            
            Divider()
            
            // Self-Play Mode (Main Feature)
            selfPlaySection
            
            Divider()
            
            // Statistics
            statsSection
            
            Divider()
            
            // Visualization
            visualizationSection
            
            Divider()
            
            // Quick Actions
            quickActionsSection
            
            // Hint Display
            if let hint = hintMessage {
                hintSection(hint: hint)
            }
            
            Spacer()
        }
        .padding(Constants.spacingL)
        .background(
            RoundedRectangle(cornerRadius: Constants.boardCornerRadius)
                .fill(Constants.backgroundSecondary)
                .shadow(color: Constants.cardShadow, radius: Constants.cardShadowRadius, y: Constants.cardShadowY)
        )
        .sheet(isPresented: $showingStats) {
            StatisticsView(analytics: game.analytics)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundStyle(Constants.accentColor)
            
            Text("AI Agent")
                .font(Constants.titleFont)
                .foregroundStyle(Constants.textPrimary)
            
            Spacer()
            
            Button {
                showingStats = true
            } label: {
                Image(systemName: "chart.bar")
                    .font(.title3)
                    .foregroundStyle(Constants.accentColor)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Self-Play Section
    
    private var selfPlaySection: some View {
        VStack(alignment: .leading, spacing: Constants.spacingM) {
            Text("Self-Play Mode")
                .font(Constants.captionFont)
                .foregroundStyle(Constants.textSecondary)
            
            Text("AI plays complete games automatically, learns from results")
                .font(Constants.captionFont)
                .foregroundStyle(Constants.textTertiary)
            
            // Start/Stop button
            Button {
                if game.isSelfPlaying {
                    game.stopSelfPlay()
                } else {
                    game.startSelfPlay()
                }
            } label: {
                HStack {
                    Image(systemName: game.isSelfPlaying ? "stop.fill" : "play.fill")
                        .font(.title3)
                    
                    Text(game.isSelfPlaying ? "Stop Self-Play" : "Start Self-Play")
                        .font(Constants.bodyFont.weight(.semibold))
                    
                    Spacer()
                    
                    if game.isSelfPlaying {
                        Text("Active")
                            .font(Constants.captionFont)
                            .foregroundStyle(.green)
                    }
                }
                .foregroundStyle(game.isSelfPlaying ? .white : Constants.accentColor)
                .padding(Constants.spacingM)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(game.isSelfPlaying ? Color.red : Constants.accentColor.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(game.isSelfPlaying ? Color.red : Constants.accentColor, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
            
            // Speed control
            if game.isSelfPlaying {
                VStack(alignment: .leading, spacing: Constants.spacingS) {
                    Text("Speed: \(String(format: "%.2f", game.selfPlaySpeed))s per move")
                        .font(Constants.captionFont)
                        .foregroundStyle(Constants.textSecondary)
                    
                    HStack {
                        Image(systemName: "tortoise")
                            .foregroundStyle(Constants.textSecondary)
                        
                        Slider(
                            value: Binding(
                                get: { game.selfPlaySpeed },
                                set: { game.setSelfPlaySpeed($0) }
                            ),
                            in: 0.05...1.0,
                            step: 0.05
                        )
                        .tint(Constants.accentColor)
                        
                        Image(systemName: "hare")
                            .foregroundStyle(Constants.textSecondary)
                    }
                }
                .padding(Constants.spacingS)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Constants.backgroundPrimary)
                )
            }
            
            // Status
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(Constants.accentColor)
                
                Text(game.selfPlayStatus)
                    .font(Constants.captionFont)
                    .foregroundStyle(Constants.textPrimary)
            }
            .padding(Constants.spacingS)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Constants.backgroundPrimary)
            )
        }
    }
    
    // MARK: - Statistics Section
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: Constants.spacingS) {
            Text("Session Statistics")
                .font(Constants.captionFont)
                .foregroundStyle(Constants.textSecondary)
            
            HStack(spacing: Constants.spacingL) {
                StatBox(label: "Games", value: "\(game.gamesPlayed)")
                StatBox(label: "Wins", value: "\(game.gamesWon)")
                StatBox(label: "Win Rate", value: "\(Int(game.currentWinRate * 100))%")
            }
        }
    }
    
    // MARK: - Visualization Section
    
    private var visualizationSection: some View {
        VStack(alignment: .leading, spacing: Constants.spacingS) {
            Text("Visualization")
                .font(Constants.captionFont)
                .foregroundStyle(Constants.textSecondary)
            
            Button {
                game.toggleProbabilities()
            } label: {
                HStack {
                    Image(systemName: game.showProbabilities ? "eye.fill" : "eye")
                        .font(.body)
                    
                    Text("Show Mine Probabilities")
                        .font(Constants.bodyFont)
                    
                    Spacer()
                    
                    Text(game.showProbabilities ? "ON" : "OFF")
                        .font(Constants.captionFont.weight(.semibold))
                        .foregroundStyle(game.showProbabilities ? .green : .secondary)
                }
                .foregroundStyle(Constants.textPrimary)
                .padding(Constants.spacingS)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(game.showProbabilities ? Color.green.opacity(0.1) : Constants.backgroundPrimary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(game.showProbabilities ? Color.green.opacity(0.5) : Color.clear, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            if game.showProbabilities {
                HStack(spacing: 12) {
                    legendItem(color: .green, label: "< 20%")
                    legendItem(color: .yellow, label: "20-40%")
                    legendItem(color: .orange, label: "40-60%")
                    legendItem(color: .red, label: "> 60%")
                }
                .font(Constants.captionFont)
            }
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color.opacity(0.5))
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(Constants.textSecondary)
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Constants.spacingS) {
            Text("Quick Actions")
                .font(Constants.captionFont)
                .foregroundStyle(Constants.textSecondary)
            
            HStack(spacing: Constants.spacingS) {
                // Hint
                Button {
                    hintMessage = game.getHint()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "lightbulb")
                            .font(.title3)
                        Text("Hint")
                            .font(Constants.captionFont)
                    }
                    .foregroundStyle(Constants.accentColor)
                    .padding(Constants.spacingS)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Constants.accentColor.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Constants.accentColor, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                
                // New Game
                Button {
                    game.newGame()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title3)
                        Text("New Game")
                            .font(Constants.captionFont)
                    }
                    .foregroundStyle(.orange)
                    .padding(Constants.spacingS)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Hint Display
    
    private func hintSection(hint: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.body)
            
            Text(hint)
                .font(Constants.captionFont)
                .foregroundStyle(Constants.textPrimary)
            
            Spacer()
            
            Button {
                hintMessage = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(Constants.spacingS)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(Constants.accentColor)
            
            Text(label)
                .font(Constants.captionFont)
                .foregroundStyle(Constants.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.spacingS)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Constants.backgroundPrimary)
        )
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    let analytics: AnalyticsService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Overall") {
                    StatRow(label: "Games Played", value: "\(analytics.totalGames)")
                    StatRow(label: "Wins", value: "\(analytics.totalWins)")
                    StatRow(label: "Win Rate", value: "\(Int(analytics.winRate * 100))%")
                    StatRow(label: "Avg Duration", value: "\(Int(analytics.averageDuration))s")
                }
                
                Section("Strategy Effectiveness") {
                    ForEach(Array(analytics.strategyEffectiveness().sorted(by: { $0.key.rawValue < $1.key.rawValue })), id: \.key) { strategy, rate in
                        HStack {
                            Image(systemName: Constants.strategyIcon(for: strategy))
                                .foregroundStyle(Constants.accentColor)
                            
                            Text(strategy.displayName)
                                .font(Constants.bodyFont)
                            
                            Spacer()
                            
                            Text("\(Int(rate * 100))%")
                                .font(Constants.bodyFont.monospacedDigit())
                                .foregroundStyle(rate > 0.7 ? .green : rate > 0.5 ? .orange : .red)
                        }
                    }
                }
                
                Section("Recent Games") {
                    ForEach(analytics.recentGames(count: 10)) { record in
                        HStack {
                            Image(systemName: record.isWin ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(record.isWin ? .green : .red)
                            
                            VStack(alignment: .leading) {
                                Text(record.difficulty.displayName)
                                    .font(Constants.bodyFont)
                                Text("\(record.duration)s • \(record.totalMoves) moves")
                                    .font(Constants.captionFont)
                                    .foregroundStyle(Constants.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text(record.startTime, style: .relative)
                                .font(Constants.captionFont)
                                .foregroundStyle(Constants.textTertiary)
                        }
                    }
                }
            }
            .navigationTitle("Statistics")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Constants.bodyFont)
                .foregroundStyle(Constants.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(Constants.bodyFont.monospacedDigit())
                .foregroundStyle(Constants.accentColor)
        }
    }
}
