import SpriteKit
import SwiftUI

class GameScene: SKScene {
    var gameDelegate: GameDelegate?
    private var ball: SKShapeNode!
    private var score = 0
    private var isBallCaught = false
    private var ballSpeed: CGFloat = 3.0
    private var ballDirection = CGPoint(x: 1, y: 1)
    private var lastUpdateTime: TimeInterval = 0
    private var ballStopTimer: Timer?
    private var currentLevel: Int = 1
    
    override func didMove(to view: SKView) {
        setupScene()
        if ball == nil {
            setupBall()
            startBallMovement()
        }
    }
    
    private func setupScene() {
        backgroundColor = .clear
        physicsWorld.gravity = CGVector.zero
    }
    
    private func setupBall() {
        let ballSize: CGFloat = 30
        let ballColor = SKColor.black
        
        // Create circular ball using SKShapeNode
        ball = SKShapeNode(circleOfRadius: ballSize / 2)
        ball.fillColor = ballColor
        ball.strokeColor = ballColor
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball.name = "ball"
        
        // Make ball circular physics body
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballSize / 2)
        ball.physicsBody?.isDynamic = false
        ball.physicsBody?.categoryBitMask = 1
        ball.physicsBody?.contactTestBitMask = 2
        
        addChild(ball)
    }
    
    private func startBallMovement() {
        // Set ball speed based on level
        let level = LevelManager.shared.getLevel(currentLevel)
        ballSpeed = level?.ballSpeed ?? 3.0
        
        // Random initial direction
        let angle = Double.random(in: 0...2*Double.pi)
        ballDirection = CGPoint(x: cos(angle), y: sin(angle))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if !isBallCaught {
            moveBall(deltaTime: deltaTime)
        }
    }
    
    private func moveBall(deltaTime: TimeInterval) {
        guard let ball = ball else { return }
        
        let moveDistance = ballSpeed * CGFloat(deltaTime * 60) // 60 FPS
        
        ball.position.x += ballDirection.x * moveDistance
        ball.position.y += ballDirection.y * moveDistance
        
        // Bounce off walls
        if ball.position.x <= 20 || ball.position.x >= size.width - 20 {
            ballDirection.x *= -1
            ball.position.x = max(20, min(size.width - 20, ball.position.x))
        }
        
        if ball.position.y <= 20 || ball.position.y >= size.height - 20 {
            ballDirection.y *= -1
            ball.position.y = max(20, min(size.height - 20, ball.position.y))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let ball = ball else { return }
        let location = touch.location(in: self)
        
        if ball.contains(location) && !isBallCaught {
            catchBall()
        }
    }
    
    private func catchBall() {
        guard let ball = ball else { return }
        
        isBallCaught = true
        
        // Stop ball movement
        ball.physicsBody?.isDynamic = false
        
        // Add catch animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let catchAnimation = SKAction.sequence([scaleUp, scaleDown])
        
        ball.run(catchAnimation)
        
        // Add particle effect
        addCatchEffect()
        
        // Update score
        score += 1
        gameDelegate?.onScoreUpdate(score)
        
        // Resume ball movement after 1 second
        ballStopTimer?.invalidate()
        ballStopTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.resumeBallMovement()
        }
    }
    
    private func addCatchEffect() {
        guard let ball = ball else { return }
        
        // Create simple sparkle effect using small circles
        for i in 0..<8 {
            let sparkle = SKShapeNode(circleOfRadius: 2)
            sparkle.fillColor = SKColor(red: 0.380, green: 0.835, blue: 0.961, alpha: 1.0)
            sparkle.strokeColor = SKColor.white
            sparkle.position = ball.position
            
            // Random direction for each sparkle
            let angle = Double(i) * (Double.pi * 2 / 8) + Double.random(in: -0.5...0.5)
            let distance: CGFloat = 30
            let endPosition = CGPoint(
                x: ball.position.x + cos(angle) * distance,
                y: ball.position.y + sin(angle) * distance
            )
            
            addChild(sparkle)
            
            // Animate sparkle
            let moveAction = SKAction.move(to: endPosition, duration: 0.3)
            let fadeAction = SKAction.fadeOut(withDuration: 0.3)
            let scaleAction = SKAction.scale(to: 0.1, duration: 0.3)
            let groupAction = SKAction.group([moveAction, fadeAction, scaleAction])
            let removeAction = SKAction.removeFromParent()
            
            sparkle.run(SKAction.sequence([groupAction, removeAction]))
        }
    }
    
    private func resumeBallMovement() {
        isBallCaught = false
        
        // New random direction
        let angle = Double.random(in: 0...2*Double.pi)
        ballDirection = CGPoint(x: cos(angle), y: sin(angle))
        
        // Slightly increase speed
        ballSpeed = min(ballSpeed + 0.2, 8.0)
    }
    
    func setLevel(_ level: Int) {
        currentLevel = level
        resetGame()
    }
    
    func resetGame() {
        score = 0
        isBallCaught = false
        ballStopTimer?.invalidate()
        
        // Remove all children to clean up any duplicate balls
        removeAllChildren()
        ball = nil
        
        // Create new ball with level properties
        setupBall()
        startBallMovement()
    }
}
