import SwiftUI

struct LevelSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var levelManager = LevelManager.shared
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 3)
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.012, green: 0.027, blue: 0.169), // 030B57
                    Color(red: 0.337, green: 0.678, blue: 0.875), // 56ADDF
                    Color(red: 0.424, green: 0.714, blue: 0.875), // 6CB6DF
                    Color(red: 0.012, green: 0.043, blue: 0.341)  // 030B57
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    }
                    
                    Spacer()
                    
                    Text("Select Level")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Color.clear
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Progress info
                VStack(spacing: 8) {
                    Text("Progress: \(levelManager.getTotalCompletedLevels())/\(levelManager.getAllLevels().count)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                    
                    Text("Total Score: \(levelManager.getTotalScore())")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.8))
                }
                
                // Levels grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(levelManager.getAllLevels(), id: \.number) { level in
                            if levelManager.isLevelUnlocked(level.number) {
                                NavigationLink(destination: GameView(initialLevel: level.number)) {
                                    LevelCard(
                                        level: level,
                                        isUnlocked: true,
                                        isCompleted: levelManager.isLevelCompleted(level.number),
                                        bestScore: levelManager.getBestScore(for: level.number)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                LevelCard(
                                    level: level,
                                    isUnlocked: false,
                                    isCompleted: false,
                                    bestScore: 0
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct LevelCard: View {
    let level: Level
    let isUnlocked: Bool
    let isCompleted: Bool
    let bestScore: Int
    
    var body: some View {
        VStack(spacing: 8) {
            // Level number
            ZStack {
                Circle()
                    .fill(levelColor)
                    .frame(width: 50, height: 50)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(level.number)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Level info
            VStack(spacing: 2) {
                Text("Level \(level.number)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isUnlocked ? Color(red: 0.972, green: 0.992, blue: 1.0) : Color(red: 0.972, green: 0.992, blue: 1.0).opacity(0.5))
                
                if isUnlocked {
                    Text("\(level.targetScore) balls")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                    
                    if bestScore > 0 {
                        Text("Best: \(bestScore)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.8))
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
        .disabled(!isUnlocked)
    }
    
    private var levelColor: Color {
        if isCompleted {
            return Color(red: 0.0, green: 0.8, blue: 0.0) // Green for completed
        } else if isUnlocked {
            return Color(red: 0.380, green: 0.835, blue: 0.961) // Blue for unlocked
        } else {
            return Color.gray.opacity(0.5) // Gray for locked
        }
    }
    
    private var cardBackgroundColor: Color {
        if isUnlocked {
            return Color(red: 0.012, green: 0.043, blue: 0.341).opacity(0.8)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var borderColor: Color {
        if isCompleted {
            return Color(red: 0.0, green: 0.8, blue: 0.0)
        } else if isUnlocked {
            return Color(red: 0.380, green: 0.835, blue: 0.961)
        } else {
            return Color.gray.opacity(0.5)
        }
    }
}
