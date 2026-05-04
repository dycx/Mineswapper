import SwiftUI

enum Constants {
    static let cellSize: CGFloat = 32
    static let cellCornerRadius: CGFloat = 4
    static let boardPadding: CGFloat = 16
    static let boardCornerRadius: CGFloat = 8

    static let numberColors: [Int: Color] = [
        1: .blue,
        2: .green,
        3: .red,
        4: Color(red: 0, green: 0, blue: 0.6),
        5: Color(red: 0.5, green: 0, blue: 0),
        6: .teal,
        7: .black,
        8: .gray
    ]

    static func numberFont(size: CGFloat) -> Font {
        .system(size: size * 0.55, weight: .bold, design: .rounded)
    }
}
