import Foundation

struct Achievement {
    let id: String
    let title: String
    let description: String
    let icon: String
    let targetProgress: Int
    var currentProgress: Int
    let isUnlocked: Bool
}

class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published private var achievements: [Achievement] = []
    
    private init() {
        setupAchievements()
        loadProgress()
    }
    
    private func setupAchievements() {
        achievements = [
            Achievement(
                id: "first_level",
                title: "First Steps",
                description: "Complete your first level",
                icon: "star.fill",
                targetProgress: 1,
                currentProgress: 0,
                isUnlocked: false
            ),
            Achievement(
                id: "level_5",
                title: "Getting Started",
                description: "Complete 5 levels",
                icon: "5.circle.fill",
                targetProgress: 5,
                currentProgress: 0,
                isUnlocked: false
            ),
            Achievement(
                id: "level_10",
                title: "Halfway There",
                description: "Complete 10 levels",
                icon: "10.circle.fill",
                targetProgress: 10,
                currentProgress: 0,
                isUnlocked: false
            ),
            Achievement(
                id: "score_100",
                title: "Century Club",
                description: "Score 100 total points",
                icon: "trophy.fill",
                targetProgress: 100,
                currentProgress: 0,
                isUnlocked: false
            ),
            Achievement(
                id: "score_500",
                title: "High Scorer",
                description: "Score 500 total points",
                icon: "crown.fill",
                targetProgress: 500,
                currentProgress: 0,
                isUnlocked: false
            ),
            Achievement(
                id: "perfect_level",
                title: "Perfectionist",
                description: "Complete a level with perfect score",
                icon: "checkmark.seal.fill",
                targetProgress: 1,
                currentProgress: 0,
                isUnlocked: false
            ),
            Achievement(
                id: "speed_demon",
                title: "Speed Demon",
                description: "Complete 3 levels in a row",
                icon: "bolt.fill",
                targetProgress: 3,
                currentProgress: 0,
                isUnlocked: false
            ),
            Achievement(
                id: "ball_master",
                title: "Ball Master",
                description: "Catch 100 balls total",
                icon: "sportscourt.fill",
                targetProgress: 100,
                currentProgress: 0,
                isUnlocked: false
            )
        ]
    }
    
    func getAllAchievements() -> [Achievement] {
        return achievements
    }
    
    func getUnlockedAchievements() -> [Achievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    func isAchievementUnlocked(_ id: String) -> Bool {
        return achievements.first { $0.id == id }?.isUnlocked ?? false
    }
    
    func updateAchievements(completedLevels: Int, totalScore: Int) {
        for i in 0..<achievements.count {
            let achievement = achievements[i]
            var newProgress = 0
            var shouldUnlock = false
            
            switch achievement.id {
            case "first_level":
                newProgress = min(completedLevels, 1)
                shouldUnlock = completedLevels >= 1
            case "level_5":
                newProgress = min(completedLevels, 5)
                shouldUnlock = completedLevels >= 5
            case "level_10":
                newProgress = min(completedLevels, 10)
                shouldUnlock = completedLevels >= 10
            case "score_100":
                newProgress = min(totalScore, 100)
                shouldUnlock = totalScore >= 100
            case "score_500":
                newProgress = min(totalScore, 500)
                shouldUnlock = totalScore >= 500
            case "perfect_level":
                // This would need to be tracked separately
                newProgress = 0
                shouldUnlock = false
            case "speed_demon":
                // This would need to be tracked separately
                newProgress = 0
                shouldUnlock = false
            case "ball_master":
                // This would need to be tracked separately
                newProgress = 0
                shouldUnlock = false
            default:
                break
            }
            
            achievements[i] = Achievement(
                id: achievement.id,
                title: achievement.title,
                description: achievement.description,
                icon: achievement.icon,
                targetProgress: achievement.targetProgress,
                currentProgress: newProgress,
                isUnlocked: shouldUnlock || achievement.isUnlocked
            )
        }
        
        saveProgress()
    }
    
    private func saveProgress() {
        let unlockedIds = achievements.filter { $0.isUnlocked }.map { $0.id }
        UserDefaults.standard.set(unlockedIds, forKey: "UnlockedAchievements")
    }
    
    private func loadProgress() {
        guard let unlockedIds = UserDefaults.standard.array(forKey: "UnlockedAchievements") as? [String] else {
            return
        }
        
        for i in 0..<achievements.count {
            if unlockedIds.contains(achievements[i].id) {
                achievements[i] = Achievement(
                    id: achievements[i].id,
                    title: achievements[i].title,
                    description: achievements[i].description,
                    icon: achievements[i].icon,
                    targetProgress: achievements[i].targetProgress,
                    currentProgress: achievements[i].currentProgress,
                    isUnlocked: true
                )
            }
        }
    }
}
