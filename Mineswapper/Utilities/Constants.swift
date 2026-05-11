// Constants.swift
// Mineswapper - Apple-inspired design tokens

import SwiftUI

enum Constants {
    // MARK: - Layout
    static let cellSize: CGFloat = 36
    static let cellCornerRadius: CGFloat = 6
    static let boardPadding: CGFloat = 20
    static let boardCornerRadius: CGFloat = 12
    
    // MARK: - Colors (Apple-inspired)
    
    /// Primary accent color (Apple Blue)
    static let accentColor = Color(red: 0, green: 0.443, blue: 0.89) // #0071e3
    
    /// Background colors
    static let backgroundPrimary = Color(red: 0.961, green: 0.961, blue: 0.969) // #f5f5f7
    static let backgroundSecondary = Color.white
    static let backgroundDark = Color(red: 0.114, green: 0.114, blue: 0.122) // #1d1d1f
    
    /// Text colors
    static let textPrimary = Color(red: 0.114, green: 0.114, blue: 0.122) // #1d1d1f
    static let textSecondary = Color.black.opacity(0.8)
    static let textTertiary = Color.black.opacity(0.48)
    
    /// Cell colors
    static let cellHiddenGradientStart = Color.gray.opacity(0.35)
    static let cellHiddenGradientEnd = Color.gray.opacity(0.20)
    static let cellRevealedBackground = Color.gray.opacity(0.12)
    static let cellFlaggedGradientStart = Color.gray.opacity(0.30)
    static let cellFlaggedGradientEnd = Color.gray.opacity(0.15)
    
    /// AI visualization colors
    static let aiSafeColor = Color.green.opacity(0.3)
    static let aiDangerColor = Color.red.opacity(0.3)
    static let aiRecommendedColor = accentColor.opacity(0.3)
    static let aiMineColor = Color.orange.opacity(0.3)
    
    /// Number colors (1-8)
    static let numberColors: [Int: Color] = [
        1: Color(red: 0, green: 0.443, blue: 0.89),    // Blue (#0071e3)
        2: Color(red: 0.18, green: 0.72, blue: 0.47),   // Green
        3: Color(red: 0.90, green: 0.25, blue: 0.25),   // Red
        4: Color(red: 0.40, green: 0.20, blue: 0.70),   // Purple
        5: Color(red: 0.75, green: 0.25, blue: 0.15),   // Dark Red
        6: Color(red: 0.15, green: 0.65, blue: 0.65),   // Teal
        7: Color(red: 0.20, green: 0.20, blue: 0.20),   // Dark Gray
        8: Color(red: 0.55, green: 0.55, blue: 0.55)    // Gray
    ]
    
    // MARK: - Typography
    
    /// System font with Apple-like sizing
    static func numberFont(size: CGFloat) -> Font {
        .system(size: size * 0.50, weight: .bold, design: .rounded)
    }
    
    static func labelFont(size: CGFloat) -> Font {
        .system(size: size * 0.35, weight: .medium, design: .rounded)
    }
    
    /// Score bar font
    static let scoreFont = Font.system(size: 20, weight: .semibold, design: .monospaced)
    
    /// Title font
    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    
    /// Body font
    static let bodyFont = Font.system(size: 15, weight: .regular, design: .default)
    
    /// Caption font
    static let captionFont = Font.system(size: 12, weight: .medium, design: .default)
    
    // MARK: - Shadows
    
    /// Card shadow
    static let cardShadow = Color.black.opacity(0.10)
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowY: CGFloat = 4
    
    /// Button shadow
    static let buttonShadow = Color.black.opacity(0.08)
    static let buttonShadowRadius: CGFloat = 4
    static let buttonShadowY: CGFloat = 2
    
    // MARK: - Animation
    
    static let animationDuration: Double = 0.2
    static let springAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    // MARK: - Spacing
    
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    
    // MARK: - AI Visualization
    
    /// Probability gradient colors
    static func probabilityColor(probability: Double) -> Color {
        if probability < 0.2 {
            return .green.opacity(0.3)
        } else if probability < 0.4 {
            return .yellow.opacity(0.3)
        } else if probability < 0.6 {
            return .orange.opacity(0.3)
        } else {
            return .red.opacity(0.3)
        }
    }
    
    /// Strategy icon
    static func strategyIcon(for strategy: AIStrategy) -> String {
        switch strategy {
        case .constraint: return "brain"
        case .monteCarlo: return "dice"
        case .guess: return "questionmark.circle"
        case .human: return "hand.point.up.left"
        }
    }
}
