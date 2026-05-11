// DifficultyPickerView.swift
// Mineswapper - Apple-inspired difficulty picker

import SwiftUI

struct DifficultyPickerView: View {
    @Binding var difficulty: Difficulty
    
    var body: some View {
        Picker("Difficulty", selection: $difficulty) {
            Label("Beginner", systemImage: "star")
                .tag(Difficulty.beginner)
            
            Label("Intermediate", systemImage: "star.leadinghalf.filled")
                .tag(Difficulty.intermediate)
            
            Label("Expert", systemImage: "star.fill")
                .tag(Difficulty.expert)
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 300)
    }
}
