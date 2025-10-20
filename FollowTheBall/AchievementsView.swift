import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var levelManager = LevelManager.shared
    @StateObject private var achievementManager = AchievementManager.shared
    
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
                    
                    Text("Achievements")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Color.clear
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Progress summary
                VStack(spacing: 10) {
                    Text("Achievement Progress")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    
                    Text("\(achievementManager.getUnlockedAchievements().count) of \(achievementManager.getAllAchievements().count) unlocked")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                    
                    // Progress bar
                    ProgressView(value: Double(achievementManager.getUnlockedAchievements().count), total: Double(achievementManager.getAllAchievements().count))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.380, green: 0.835, blue: 0.961)))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
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
                .padding(.horizontal, 20)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(achievementManager.getAllAchievements(), id: \.id) { achievement in
                            AchievementCard(
                                achievement: achievement,
                                isUnlocked: achievementManager.isAchievementUnlocked(achievement.id)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            achievementManager.updateAchievements(
                completedLevels: levelManager.getTotalCompletedLevels(),
                totalScore: levelManager.getTotalScore()
            )
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // Achievement icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color(red: 1.0, green: 0.843, blue: 0.0) : Color.gray.opacity(0.5))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isUnlocked ? Color(red: 0.972, green: 0.992, blue: 1.0) : Color(red: 0.972, green: 0.992, blue: 1.0).opacity(0.6))
                
                Text(achievement.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isUnlocked ? Color(red: 0.380, green: 0.835, blue: 0.961) : Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.6))
                    .multilineTextAlignment(.leading)
                
                if !isUnlocked {
                    Text("Progress: \(achievement.currentProgress)/\(achievement.targetProgress)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.8))
                }
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.0))
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? Color(red: 0.012, green: 0.043, blue: 0.341).opacity(0.8) : Color.gray.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isUnlocked ? Color(red: 0.380, green: 0.835, blue: 0.961) : Color.gray.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

#Preview {
    AchievementsView()
}
