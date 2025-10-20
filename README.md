# FollowTheBall

A small but polished iOS game built with SwiftUI + SpriteKit.
Catch the ball, grow your score, and clear levels with increasing goals.

## Features
- Multiple levels, each with its own target score
- Fast, responsive SpriteKit gameplay (tap to catch the ball)
- 1-second freeze and satisfying spark effect on every catch
- Win popup with Next/Home actions
- Level selection screen with progress and best scores
- Statistics, Achievements, and Rewards sections
- Consistent color palette and full-screen gradient background

## How to Play
- Tap the moving ball to catch it.
- Each catch pauses the ball for a second and adds +1 point.
- Reach the level target to win.

## Tech Stack
- SwiftUI for screens and navigation
- SpriteKit for the game scene and animations
- UserDefaults for lightweight persistence

## Project Structure
- `MainMenuView.swift` — entry UI with primary actions
- `LevelSelectionView.swift` — pick a level, view progress
- `GameView.swift` — hosts the SpriteKit scene and HUD
- `GameScene.swift` — ball logic, movement, catch effects
- `LevelManager.swift` — level data (targets, speed, size)
- `AchievementsView.swift`, `RewardsView.swift`, `StatisticsView.swift`

## Build & Run
1. Open `FollowTheBall.xcodeproj` in Xcode 15 or newer.
2. Select an iOS Simulator (e.g., iPhone 15) and press Run.

If the Simulator misbehaves:
- Quit Simulator and Xcode, then re-open.
- Clear DerivedData (Xcode → Settings → Locations → DerivedData).
- From Terminal: `xcrun simctl shutdown all && xcrun simctl erase all`.

## Customization Tips
- Colors live inline in views; adjust gradient stops to your taste.
- Level parameters (target score, speed, size) are defined in `LevelManager`.

## License
This project is provided for learning and demo purposes.
