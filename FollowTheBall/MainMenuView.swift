import SwiftUI

struct MainMenuView: View {
    // Navigation uses NavigationView + NavigationLink for iOS 15 compatibility
    
    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // App Title
                    VStack(spacing: 10) {
                        Text("Follow The Ball")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0)) // F8FDFF
                        
                        Text("Catch the ball to score points!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961)) // 61D5F5
                    }
                    
                    Spacer()
                    
                    // Menu Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: GameView()) {
                            MenuButton(
                                title: "Play",
                                icon: "play.fill",
                                color: Color(red: 0.051, green: 0.365, blue: 0.843)
                            )
                        }
                        NavigationLink(destination: LevelSelectionView()) {
                            MenuButton(
                                title: "Select Level",
                                icon: "list.bullet",
                                color: Color(red: 0.561, green: 0.443, blue: 0.941)
                            )
                        }
                        NavigationLink(destination: StatisticsView()) {
                            MenuButton(
                                title: "Statistics",
                                icon: "chart.bar.fill",
                                color: Color(red: 0.380, green: 0.835, blue: 0.961)
                            )
                        }
                        NavigationLink(destination: AchievementsView()) {
                            MenuButton(
                                title: "Achievements",
                                icon: "trophy.fill",
                                color: Color(red: 0.972, green: 0.992, blue: 1.0), // F8FDFF (light)
                                foregroundColor: Color(red: 0.012, green: 0.043, blue: 0.341)
                            )
                        }
                        NavigationLink(destination: RewardsView()) {
                            MenuButton(
                                title: "Rewards",
                                icon: "gift.fill",
                                color: Color(red: 0.012, green: 0.043, blue: 0.341)
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    var foregroundColor: Color = .white
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(foregroundColor)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(foregroundColor)
            
            Spacer()
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color)
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}
