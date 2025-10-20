import SwiftUI

struct WinPopupView: View {
    let level: Int
    let score: Int
    let onHome: () -> Void
    let onNextLevel: () -> Void
    
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { }
            
            // Popup content
            VStack(spacing: 25) {
                // Confetti animation
                if showConfetti {
                    ConfettiView()
                        .frame(height: 100)
                }
                
                // Win icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 1.0, green: 0.843, blue: 0.0))
                    .shadow(color: Color(red: 1.0, green: 0.843, blue: 0.0).opacity(0.5), radius: 10)
                
                // Win text
                VStack(spacing: 10) {
                    Text("Level Complete!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    
                    Text("Congratulations!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                }
                
                // Score info
                VStack(spacing: 8) {
                    Text("Level \(level)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.972, green: 0.992, blue: 1.0))
                    
                    Text("Score: \(score)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.380, green: 0.835, blue: 0.961))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.012, green: 0.043, blue: 0.341).opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.380, green: 0.835, blue: 0.961), lineWidth: 1)
                        )
                )
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: onNextLevel) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20))
                            Text("Next Level")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.051, green: 0.365, blue: 0.843))
                                .shadow(color: Color(red: 0.051, green: 0.365, blue: 0.843).opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                    
                    Button(action: onHome) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 20))
                            Text("Home")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 0.012, green: 0.043, blue: 0.341))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.972, green: 0.992, blue: 1.0))
                                .shadow(color: Color(red: 0.972, green: 0.992, blue: 1.0).opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.012, green: 0.027, blue: 0.169),
                                Color(red: 0.012, green: 0.043, blue: 0.341)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.380, green: 0.835, blue: 0.961),
                                        Color(red: 0.561, green: 0.443, blue: 0.941)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                showConfetti = true
            }
        }
    }
}

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(piece.position)
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            createConfetti()
        }
    }
    
    private func createConfetti() {
        let colors = [
            Color(red: 0.380, green: 0.835, blue: 0.961),
            Color(red: 0.561, green: 0.443, blue: 0.941),
            Color(red: 0.051, green: 0.365, blue: 0.843),
            Color(red: 0.972, green: 0.992, blue: 1.0)
        ]
        
        for i in 0..<50 {
            let piece = ConfettiPiece(
                id: i,
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -20
                ),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 4...8),
                opacity: 1.0
            )
            confettiPieces.append(piece)
            
            withAnimation(
                .easeOut(duration: Double.random(in: 2...4))
                .delay(Double(i) * 0.02)
            ) {
                if let index = confettiPieces.firstIndex(where: { $0.id == i }) {
                    confettiPieces[index].position.y = UIScreen.main.bounds.height + 50
                    confettiPieces[index].opacity = 0
                }
            }
        }
    }
}

struct ConfettiPiece {
    let id: Int
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}

#Preview {
    WinPopupView(
        level: 1,
        score: 5,
        onHome: {},
        onNextLevel: {}
    )
}
