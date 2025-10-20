import Foundation

struct Reward {
    let id: String
    let title: String
    let description: String
    let icon: String
    let cost: Int
    let isUnlocked: Bool
}

class RewardManager: ObservableObject {
    static let shared = RewardManager()
    
    @Published private var totalPoints: Int = 0
    @Published private var claimedRewards: Set<String> = []
    private let rewards: [Reward] = [
        Reward(
            id: "ball_skin_1",
            title: "Blue Ball Skin",
            description: "A cool blue ball skin",
            icon: "circle.fill",
            cost: 50,
            isUnlocked: true
        ),
        Reward(
            id: "ball_skin_2",
            title: "Purple Ball Skin",
            description: "A stylish purple ball skin",
            icon: "circle.fill",
            cost: 100,
            isUnlocked: true
        ),
        Reward(
            id: "ball_skin_3",
            title: "Golden Ball Skin",
            description: "A luxurious golden ball skin",
            icon: "circle.fill",
            cost: 200,
            isUnlocked: true
        ),
        Reward(
            id: "background_1",
            title: "Space Background",
            description: "A cosmic space background",
            icon: "moon.stars.fill",
            cost: 150,
            isUnlocked: true
        ),
        Reward(
            id: "background_2",
            title: "Ocean Background",
            description: "A calming ocean background",
            icon: "water.waves",
            cost: 150,
            isUnlocked: true
        ),
        Reward(
            id: "particle_effect",
            title: "Sparkle Effect",
            description: "Add sparkles when catching balls",
            icon: "sparkles",
            cost: 75,
            isUnlocked: true
        ),
        Reward(
            id: "sound_pack",
            title: "Retro Sound Pack",
            description: "Classic arcade sound effects",
            icon: "speaker.wave.2.fill",
            cost: 100,
            isUnlocked: true
        ),
        Reward(
            id: "special_ball",
            title: "Rainbow Ball",
            description: "A magical rainbow ball",
            icon: "rainbow",
            cost: 300,
            isUnlocked: true
        )
    ]
    
    private init() {
        loadProgress()
    }
    
    func getTotalPoints() -> Int {
        return totalPoints
    }
    
    func getAvailableRewards() -> [Reward] {
        return rewards
    }
    
    func isRewardUnlocked(_ id: String) -> Bool {
        return claimedRewards.contains(id)
    }
    
    func canClaimReward(_ id: String) -> Bool {
        guard let reward = rewards.first(where: { $0.id == id }) else { return false }
        return !claimedRewards.contains(id) && totalPoints >= reward.cost
    }
    
    func claimReward(_ id: String) {
        guard canClaimReward(id) else { return }
        
        claimedRewards.insert(id)
        saveProgress()
    }
    
    func updatePoints(_ newPoints: Int) {
        totalPoints = newPoints
        saveProgress()
    }
    
    private func saveProgress() {
        UserDefaults.standard.set(totalPoints, forKey: "TotalPoints")
        UserDefaults.standard.set(Array(claimedRewards), forKey: "ClaimedRewards")
    }
    
    private func loadProgress() {
        totalPoints = UserDefaults.standard.integer(forKey: "TotalPoints")
        if let claimed = UserDefaults.standard.array(forKey: "ClaimedRewards") as? [String] {
            claimedRewards = Set(claimed)
        }
    }
}
