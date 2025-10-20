import Foundation

struct Level {
    let number: Int
    let targetScore: Int
    let ballSpeed: CGFloat
    let ballSize: CGFloat
    let description: String
}

class LevelManager: ObservableObject {
    static let shared = LevelManager()
    
    private let levels: [Level] = [
        Level(number: 1, targetScore: 5, ballSpeed: 3.0, ballSize: 40, description: "Catch 5 balls to complete this level"),
        Level(number: 2, targetScore: 10, ballSpeed: 3.5, ballSize: 38, description: "Catch 10 balls to complete this level"),
        Level(number: 3, targetScore: 15, ballSpeed: 4.0, ballSize: 36, description: "Catch 15 balls to complete this level"),
        Level(number: 4, targetScore: 20, ballSpeed: 4.5, ballSize: 34, description: "Catch 20 balls to complete this level"),
        Level(number: 5, targetScore: 25, ballSpeed: 5.0, ballSize: 32, description: "Catch 25 balls to complete this level"),
        Level(number: 6, targetScore: 30, ballSpeed: 5.5, ballSize: 30, description: "Catch 30 balls to complete this level"),
        Level(number: 7, targetScore: 35, ballSpeed: 6.0, ballSize: 28, description: "Catch 35 balls to complete this level"),
        Level(number: 8, targetScore: 40, ballSpeed: 6.5, ballSize: 26, description: "Catch 40 balls to complete this level"),
        Level(number: 9, targetScore: 45, ballSpeed: 7.0, ballSize: 24, description: "Catch 45 balls to complete this level"),
        Level(number: 10, targetScore: 50, ballSpeed: 7.5, ballSize: 22, description: "Catch 50 balls to complete this level")
    ]
    
    @Published var unlockedLevels: Set<Int> = [1]
    @Published var completedLevels: Set<Int> = []
    @Published var bestScores: [Int: Int] = [:]
    
    private init() {
        loadProgress()
    }
    
    func getLevel(_ number: Int) -> Level? {
        return levels.first { $0.number == number }
    }
    
    func getTargetScore(for level: Int) -> Int {
        return getLevel(level)?.targetScore ?? 10
    }
    
    func getAllLevels() -> [Level] {
        return levels
    }
    
    func isLevelUnlocked(_ level: Int) -> Bool {
        return unlockedLevels.contains(level)
    }
    
    func isLevelCompleted(_ level: Int) -> Bool {
        return completedLevels.contains(level)
    }
    
    func completeLevel(_ level: Int, score: Int) {
        completedLevels.insert(level)
        
        // Unlock next level
        if level < levels.count {
            unlockedLevels.insert(level + 1)
        }
        
        // Update best score
        if let currentBest = bestScores[level] {
            bestScores[level] = max(currentBest, score)
        } else {
            bestScores[level] = score
        }
        
        saveProgress()
    }
    
    func getBestScore(for level: Int) -> Int {
        return bestScores[level] ?? 0
    }
    
    func getTotalCompletedLevels() -> Int {
        return completedLevels.count
    }
    
    func getTotalScore() -> Int {
        return bestScores.values.reduce(0, +)
    }
    
    private func saveProgress() {
        let data = ProgressData(
            unlockedLevels: Array(unlockedLevels),
            completedLevels: Array(completedLevels),
            bestScores: bestScores
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "GameProgress")
        }
    }
    
    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: "GameProgress"),
              let progress = try? JSONDecoder().decode(ProgressData.self, from: data) else {
            return
        }
        
        unlockedLevels = Set(progress.unlockedLevels)
        completedLevels = Set(progress.completedLevels)
        bestScores = progress.bestScores
    }
}

struct ProgressData: Codable {
    let unlockedLevels: [Int]
    let completedLevels: [Int]
    let bestScores: [Int: Int]
}
