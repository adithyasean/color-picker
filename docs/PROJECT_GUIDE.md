# Color Picker App - Project Guide

Welcome to the **Color Picker** iOS App project! 

This guide is designed for anyone, regardless of their coding experience, to understand how this app works, how it was built, and how to run it.

---

## 📱 What is this App?

**Color Picker** is a memory matching game built for iPhone with multiple game modes and a comprehensive achievement system.

**The Goal:**
The player is presented with a grid of face-down cards. They must flip two cards at a time to find matching colors.
- **Match:** The cards stay face up, and you earn points (base +10, modified by combos and mode multipliers).
- **Mismatch:** The cards flip back down, combo resets, and you lose points (-3).
- **Decoy:** One white card can't be matched - tapping it costs points (-5)!
- **Win:** Find all pairs before time runs out (in timed modes) to save your high score!

---

## 🎮 Game Modes

### Classic (3×3 Grid) ⭐
- **Grid:** 3×3 (9 cards)
- **Pairs:** 4 pairs + 1 decoy
- **Time Limit:** None
- **Difficulty:** ⭐☆☆☆☆
- **Score Multiplier:** 1.0x
- Perfect for beginners and casual play.

### Medium (5×5 Grid) ⭐⭐⭐
- **Grid:** 5×5 (25 cards)
- **Pairs:** 12 pairs + 1 decoy
- **Time Limit:** 2 minutes
- **Difficulty:** ⭐⭐⭐☆☆
- **Score Multiplier:** 1.5x
- A step up in challenge with time pressure.

### Hard (7×7 Grid) ⭐⭐⭐⭐⭐
- **Grid:** 7×7 (49 cards)
- **Pairs:** 24 pairs + 1 decoy
- **Time Limit:** 3 minutes
- **Difficulty:** ⭐⭐⭐⭐⭐
- **Score Multiplier:** 2.0x
- Master level for experienced players.

### Progressive Mode ⭐⭐⭐⭐
- **Starting Grid:** 3×3, evolves to 7×7
- **Time Limit:** Per-level (starts at 45s, decreases)
- **Difficulty:** ⭐⭐⭐⭐☆
- **Score Multiplier:** Increases with level (1.0x → 2.5x+)
- Start easy and progress through increasingly difficult levels!

#### Progressive Level Structure:
| Level | Grid | Pairs | Time | Multiplier |
|-------|------|-------|------|------------|
| 1 | 3×3 | 4 | 45s | 1.0x |
| 2 | 3×3 | 4 | 35s | 1.2x |
| 3 | 5×5 | 12 | 90s | 1.5x |
| 4 | 5×5 | 12 | 75s | 1.8x |
| 5 | 7×7 | 24 | 150s | 2.0x |
| 6+ | 7×7 | 24 | 120s- | 2.5x+ |

---

## 💰 Scoring System

### Base Points
| Action | Points |
|--------|--------|
| Match | +10 × Mode Multiplier × Combo |
| Mismatch | -3 |
| Tap Decoy | -5 |
| Time Out | -20 |

### Combo System
- Each consecutive match increases your combo multiplier by 0.25x
- Maximum combo: 3.0x
- Mismatch resets combo to 1.0x
- Example: 5 matches in a row = 2.25x multiplier

### Streak Bonuses
| Streak | Bonus |
|--------|-------|
| 3 matches | +15 |
| 5 matches | +30 |
| 7 matches | +50 |

### Time Bonuses
| Condition | Bonus |
|-----------|-------|
| Quick Match (within 3s) | +5 |
| Speed Run (>50% time left) | +50 |
| Clutch Win (<10% time left) | +25 |

### Special Bonuses
| Condition | Bonus |
|-----------|-------|
| Perfect Game (no mistakes) | +100 |

---

## 🏆 Achievements

### Categories

#### 🌟 Beginner
- **First Steps** - Complete your first match
- **Getting Started** - Complete your first game
- **Dedicated Player** - Complete 10 games
- **Veteran** - Complete 50 games
- **Centurion** - Complete 100 games

#### 👑 Mastery
- **Classic Master** - Score 50+ in Classic mode
- **Medium Master** - Score 150+ in Medium mode
- **Hard Master** - Score 300+ in Hard mode
- **Rising Star** - Reach level 5 in Progressive mode
- **Unstoppable** - Reach level 10 in Progressive mode

#### ⚡ Speed
- **Quick Hands** - Complete Classic in under 30 seconds
- **Lightning Fast** - Complete Medium in under 60 seconds
- **Time Bender** - Complete Hard in under 90 seconds
- **Speed Demon** - Get 10 quick match bonuses

#### 🔥 Streak
- **On Fire** - Get a 3-match streak
- **Blazing** - Get a 5-match streak
- **Inferno** - Get a 7-match streak
- **Legendary Streak** - Get a 10-match streak
- **Combo King** - Reach maximum combo multiplier (3x)

#### 📦 Collection
- **Explorer** - Play all game modes
- **Match Collector** - Make 100 total matches
- **Match Hoarder** - Make 500 total matches
- **Point Collector** - Earn 1,000 total points
- **Point Hoarder** - Earn 10,000 total points

#### ✨ Special (includes Secret achievements!)
- **Perfectionist** - Complete Classic with no mistakes
- **Flawless** - Complete Medium with no mistakes
- **Immaculate** - Complete Hard with no mistakes
- **Clutch Player** - Win with less than 5 seconds remaining
- **???** - Secret achievements to discover!

---

## 🛠️ Technology Stack

This app is built using **Apple's latest technologies**:

*   **Language:** [Swift](https://developer.apple.com/swift/)
    *   Modern, safe, and readable programming language for Apple platforms.
*   **User Interface:** [SwiftUI](https://developer.apple.com/xcode/swiftui/)
    *   Declarative UI framework - we describe the interface in code.
*   **Haptics:** `CoreHaptics` / `UIKit`
    *   Physical feedback via iPhone's Taptic Engine.
*   **Data Persistence:** `UserDefaults`
    *   Stores high scores and achievement progress.

---

## 📂 Project Structure

### Core Logic
| File | Purpose |
|------|---------|
| `Card.swift` | Card model with color, face-up state, matched state, decoy flag |
| `GameMode.swift` | Game mode definitions, progressive level configs, scoring rules |
| `Achievement.swift` | Achievement definitions, progress tracking, player stats |
| `ScoreManager.swift` | High score persistence with mode filtering |

### User Interface
| File | Purpose |
|------|---------|
| `ColorPickerApp.swift` | App entry point |
| `HomeView.swift` | Main menu with navigation to all features |
| `GameModeSelectionView.swift` | Mode selection with difficulty indicators |
| `GameView.swift` | Main game logic, timer, combos, streaks |
| `CardView.swift` | Individual card with 3D flip animation |
| `HighScoresView.swift` | Leaderboard with mode filtering |
| `AchievementsView.swift` | Achievement gallery with progress tracking |

### Assets
| Folder | Contents |
|--------|----------|
| `Assets.xcassets` | App icon, accent colors, images |

---

## 🚀 How to Run

1. **Requirements:**
   - Mac with Xcode 15+ installed
   - iOS 17+ target device or simulator

2. **Open Project:**
   - Double-click `ColorPicker.xcodeproj`

3. **Select Target:**
   - Choose a simulator (e.g., "iPhone 15 Pro") from the device dropdown

4. **Build & Run:**
   - Press ▶️ or `Cmd + R`

---

## 🎨 Design Philosophy

### Premium UX Features
- **Glassmorphism:** Translucent, frosted-glass materials
- **Animations:** 
  - Animated gradient backgrounds
  - 3D card flip animations
  - Achievement unlock celebrations
- **Haptic Feedback:**
  - Light tap on card selection
  - Success vibration on match
  - Warning vibration on mismatch
  - Error vibration on decoy tap
- **Visual Feedback:**
  - Combo multiplier display
  - Streak counter with flame icon
  - Real-time bonus/penalty text
  - Timer progress bar with color states

### Accessibility Considerations
- High contrast text on gradients
- Clear visual hierarchy
- Large touch targets
- Progress indicators for achievements

---

## 📝 Glossary

| Term | Definition |
|------|------------|
| `@State` | SwiftUI property wrapper for view-local mutable state |
| `@StateObject` | Property wrapper for observable objects owned by a view |
| `@Published` | Marks properties that trigger UI updates when changed |
| Combo | Multiplier that increases with consecutive matches |
| Streak | Count of matches without any mismatches |
| Decoy | The white card that cannot be matched |
| Progressive | Game mode that evolves through increasingly difficult levels |

---

## 🔄 Version History

### v2.0 (Current)
- Added 5×5 Medium mode
- Added 7×7 Hard mode  
- Added Progressive mode with level progression
- Implemented combo and streak systems
- Added 30+ achievements with progress tracking
- Time-based gameplay with bonuses/penalties
- Enhanced scoring with multipliers
- Mode filtering for high scores
- Player statistics tracking

### v1.0
- Initial release with 3×3 Classic mode
- Basic match/mismatch scoring
- Simple high score system

---

*Built with ❤️ using SwiftUI*
