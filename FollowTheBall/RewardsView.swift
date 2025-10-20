import SwiftUI

struct RewardsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var levelManager = LevelManager.shared
    @StateObject private var rewardManager = RewardManager.shared
    
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
                    
                    Text("Rewards")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Color.clear
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Points summary
                VStack(spacing: 10) {
                    Text("Your Points")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    
                    Text("\(rewardManager.getTotalPoints()) points")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                    
                    Text("Earned from completing levels")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.8))
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
                        ForEach(rewardManager.getAvailableRewards(), id: \.id) { reward in
                            RewardCard(
                                reward: reward,
                                isUnlocked: rewardManager.isRewardUnlocked(reward.id),
                                canClaim: rewardManager.canClaimReward(reward.id),
                                onClaim: {
                                    rewardManager.claimReward(reward.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            rewardManager.updatePoints(levelManager.getTotalScore())
        }
    }
}

struct RewardCard: View {
    let reward: Reward
    let isUnlocked: Bool
    let canClaim: Bool
    let onClaim: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Reward icon
            ZStack {
                Circle()
                    .fill(rewardColor)
                    .frame(width: 50, height: 50)
                
                Image(systemName: reward.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                
                Text(reward.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                    .multilineTextAlignment(.leading)
                
                Text("Cost: \(reward.cost) points")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961).opacity(0.8))
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.0))
            } else if canClaim {
                Button(action: onClaim) {
                    Text("Claim")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.051, green: 0.365, blue: 0.843))
                        )
                }
            } else {
                Text("\(reward.cost) pts")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.012, green: 0.027, blue: 0.169).opacity(0.6))
                    )
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
    }
    
    private var rewardColor: Color {
        if isUnlocked {
            return Color(red: 0.0, green: 0.8, blue: 0.0)
        } else if canClaim {
            return Color(red: 0.380, green: 0.835, blue: 0.961)
        } else {
            return Color.gray.opacity(0.5)
        }
    }
    
    private var cardBackgroundColor: Color {
        if isUnlocked {
            return Color(red: 0.012, green: 0.043, blue: 0.341).opacity(0.8)
        } else {
            return Color(red: 0.012, green: 0.043, blue: 0.341).opacity(0.6)
        }
    }
    
    private var borderColor: Color {
        if isUnlocked {
            return Color(red: 0.0, green: 0.8, blue: 0.0)
        } else if canClaim {
            return Color(red: 0.380, green: 0.835, blue: 0.961)
        } else {
            return Color.gray.opacity(0.5)
        }
    }
}

#Preview {
    RewardsView()
}
