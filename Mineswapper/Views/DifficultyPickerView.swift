import SwiftUI

struct DifficultyPickerView: View {
    @Binding var difficulty: Difficulty
    @State private var showCustomSheet = false
    @State private var customRows: Double = 10
    @State private var customColumns: Double = 10
    @State private var customMines: Double = 15

    var body: some View {
        Menu {
            Button("Beginner (9x9, 10 mines)") { difficulty = .beginner }
            Button("Intermediate (16x16, 40 mines)") { difficulty = .intermediate }
            Button("Expert (30x16, 99 mines)") { difficulty = .expert }
            Divider()
            Button("Custom...") { showCustomSheet = true }
        } label: {
            Label(difficulty.displayName, systemImage: "slider.horizontal.3")
        }
        .sheet(isPresented: $showCustomSheet) {
            customDifficultySheet
        }
    }

    private var customDifficultySheet: some View {
        VStack(spacing: 20) {
            Text("Custom Difficulty")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                LabeledContent("Rows") {
                    HStack {
                        Slider(value: $customRows, in: 5...30, step: 1)
                        Text("\(Int(customRows))")
                            .frame(width: 30, alignment: .trailing)
                            .monospacedDigit()
                    }
                }

                LabeledContent("Columns") {
                    HStack {
                        Slider(value: $customColumns, in: 5...30, step: 1)
                        Text("\(Int(customColumns))")
                            .frame(width: 30, alignment: .trailing)
                            .monospacedDigit()
                    }
                }

                let maxMines = max(1, Int(customRows * customColumns) - 9)

                LabeledContent("Mines") {
                    HStack {
                        Slider(value: $customMines, in: 1...Double(maxMines), step: 1)
                        Text("\(Int(customMines))")
                            .frame(width: 30, alignment: .trailing)
                            .monospacedDigit()
                    }
                }
            }
            .frame(width: 300)

            HStack {
                Button("Cancel") { showCustomSheet = false }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Start") {
                    difficulty = .custom(
                        rows: Int(customRows),
                        columns: Int(customColumns),
                        mines: Int(customMines)
                    )
                    showCustomSheet = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}
