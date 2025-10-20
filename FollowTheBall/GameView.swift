import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentLevel: Int
    @State private var score = 0
    @State private var targetScore = 10
    @State private var showWinPopup = false
    @State private var gameScene: GameScene
    
    init(initialLevel: Int = 1) {
        _currentLevel = State(initialValue: initialLevel)
        // Инициализируем сцену здесь, чтобы она создавалась только один раз
        _gameScene = State(initialValue: {
            let scene = GameScene()
            scene.scaleMode = .resizeFill
            return scene
        }())
    }
    
    var body: some View {
        ZStack {
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
            
            // Game Scene behind HUD, full screen, transparent
            SpriteView(scene: gameScene, options: [.allowsTransparency])
                .ignoresSafeArea()
            
            VStack {
                // Top HUD
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Level \(currentLevel)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                        
                        Text("Score: \(score)/\(targetScore)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Настраиваем свойства сцены и делегат при появлении представления
            gameScene.setLevel(currentLevel)
            gameScene.gameDelegate = GameDelegate(
                onScoreUpdate: { newScore in
                    score = newScore
                    if score >= targetScore {
                        LevelManager.shared.completeLevel(currentLevel, score: score)
                        showWinPopup = true
                    }
                }
            )
            setupLevel()
        }
        .onChange(of: currentLevel) { newLevel in
            gameScene.setLevel(newLevel)
            setupLevel()
        }
        .overlay {
            if showWinPopup {
                WinPopupView(
                    level: currentLevel,
                    score: score,
                    onHome: {
                        showWinPopup = false
                        dismiss()
                    },
                    onNextLevel: {
                        showWinPopup = false
                        nextLevel()
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
    }
    
    
    private func setupLevel() {
        targetScore = LevelManager.shared.getTargetScore(for: currentLevel)
        score = 0
    }
    
    private func nextLevel() {
        currentLevel += 1
        setupLevel()
    }
}

class GameDelegate: ObservableObject {
    let onScoreUpdate: (Int) -> Void
    
    init(onScoreUpdate: @escaping (Int) -> Void) {
        self.onScoreUpdate = onScoreUpdate
    }
}

#Preview {
    GameView()
}
