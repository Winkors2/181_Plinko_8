import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var levelManager = LevelManager.shared
    
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
                    
                    Text("Statistics")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Color.clear
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overall stats
                        VStack(spacing: 15) {
                            Text("Overall Progress")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                            
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "Levels Completed",
                                    value: "\(levelManager.getTotalCompletedLevels())",
                                    subtitle: "out of \(levelManager.getAllLevels().count)",
                                    color: Color(red: 0.380, green: 0.835, blue: 0.961)
                                )
                                
                                StatCard(
                                    title: "Total Score",
                                    value: "\(levelManager.getTotalScore())",
                                    subtitle: "points earned",
                                    color: Color(red: 0.561, green: 0.443, blue: 0.941)
                                )
                            }
                            
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "Completion Rate",
                                    value: "\(Int(Double(levelManager.getTotalCompletedLevels()) / Double(levelManager.getAllLevels().count) * 100))%",
                                    subtitle: "levels finished",
                                    color: Color(red: 0.051, green: 0.365, blue: 0.843)
                                )
                                
                                StatCard(
                                    title: "Average Score",
                                    value: levelManager.getTotalCompletedLevels() > 0 ? "\(levelManager.getTotalScore() / levelManager.getTotalCompletedLevels())" : "0",
                                    subtitle: "per level",
                                    color: Color(red: 0.972, green: 0.992, blue: 1.0)
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.012, green: 0.043, blue: 0.341).opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.380, green: 0.835, blue: 0.961), lineWidth: 1)
                                )
                        )
                        
                        // Level details
                        VStack(spacing: 15) {
                            Text("Level Details")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                            
                            ForEach(levelManager.getAllLevels(), id: \.number) { level in
                                LevelStatRow(
                                    level: level,
                                    isCompleted: levelManager.isLevelCompleted(level.number),
                                    bestScore: levelManager.getBestScore(for: level.number)
                                )
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.012, green: 0.043, blue: 0.341).opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(red: 0.380, green: 0.835, blue: 0.961), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.012, green: 0.027, blue: 0.169).opacity(0.6))
        )
    }
}

struct LevelStatRow: View {
    let level: Level
    let isCompleted: Bool
    let bestScore: Int
    
    var body: some View {
        HStack {
            // Level number
            ZStack {
                Circle()
                    .fill(isCompleted ? Color(red: 0.0, green: 0.8, blue: 0.0) : Color(red: 0.380, green: 0.835, blue: 0.961))
                    .frame(width: 30, height: 30)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(level.number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(level.number)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                
                Text("Target: \(level.targetScore) balls")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if isCompleted {
                    Text("Best: \(bestScore)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.0))
                } else {
                    Text("Not played")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.6))
                }
                
                Text("Speed: \(String(format: "%.1f", level.ballSpeed))x")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.8))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.012, green: 0.027, blue: 0.169).opacity(0.4))
        )
    }
}

#Preview {
    StatisticsView()
}
