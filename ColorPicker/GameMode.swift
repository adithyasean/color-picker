import SwiftUI

/// Game difficulty mode determining grid size and complexity
enum GameMode: String, CaseIterable, Codable, Identifiable {
    case classic3x3 = "classic"
    case medium5x5 = "medium"
    case hard7x7 = "hard"
    case progressive = "progressive"
    
    var id: String { rawValue }
    
    /// Display name for the mode
    var displayName: String {
        switch self {
        case .classic3x3: return "Classic"
        case .medium5x5: return "Medium"
        case .hard7x7: return "Hard"
        case .progressive: return "Progressive"
        }
    }
    
    /// Grid size description
    var gridDescription: String {
        switch self {
        case .classic3x3: return "3×3 Grid"
        case .medium5x5: return "5×5 Grid"
        case .hard7x7: return "7×7 Grid"
        case .progressive: return "Evolving"
        }
    }
    
    /// Detailed description
    var description: String {
        switch self {
        case .classic3x3:
            return "Perfect for beginners. Match 4 pairs in a 3×3 grid with 1 decoy card."
        case .medium5x5:
            return "Step up the challenge! Match 12 pairs in a 5×5 grid with 1 decoy."
        case .hard7x7:
            return "Master level. Match 24 pairs in a 7×7 grid with 1 decoy card."
        case .progressive:
            return "Start easy and progress through increasingly difficult levels. Time bonuses and combo multipliers!"
        }
    }
    
    /// Icon for the mode
    var icon: String {
        switch self {
        case .classic3x3: return "square.grid.3x3"
        case .medium5x5: return "square.grid.3x3.fill"
        case .hard7x7: return "square.grid.4x3.fill"
        case .progressive: return "chart.line.uptrend.xyaxis"
        }
    }
    
    /// Color theme for the mode
    var color: Color {
        switch self {
        case .classic3x3: return .green
        case .medium5x5: return .orange
        case .hard7x7: return .red
        case .progressive: return .purple
        }
    }
    
    /// Number of columns in the grid
    var columns: Int {
        switch self {
        case .classic3x3: return 3
        case .medium5x5: return 5
        case .hard7x7: return 7
        case .progressive: return 3 // Starts at 3, changes dynamically
        }
    }
    
    /// Total cards in the grid
    var totalCards: Int {
        switch self {
        case .classic3x3: return 9  // 4 pairs + 1 decoy = 9
        case .medium5x5: return 25 // 12 pairs + 1 decoy = 25
        case .hard7x7: return 49   // 24 pairs + 1 decoy = 49
        case .progressive: return 9 // Starting value
        }
    }
    
    /// Number of pairs to match
    var pairsToMatch: Int {
        switch self {
        case .classic3x3: return 4
        case .medium5x5: return 12
        case .hard7x7: return 24
        case .progressive: return 4 // Starting value
        }
    }
    
    /// Time limit in seconds (nil = no limit)
    var timeLimit: Int? {
        switch self {
        case .classic3x3: return nil
        case .medium5x5: return 120    // 2 minutes
        case .hard7x7: return 180      // 3 minutes
        case .progressive: return 30   // 30 seconds per level
        }
    }
    
    /// Base score multiplier
    var scoreMultiplier: Double {
        switch self {
        case .classic3x3: return 1.0
        case .medium5x5: return 1.5
        case .hard7x7: return 2.0
        case .progressive: return 1.0 // Increases with level
        }
    }
    
    /// Difficulty level for display (1-5 stars)
    var difficultyStars: Int {
        switch self {
        case .classic3x3: return 1
        case .medium5x5: return 3
        case .hard7x7: return 5
        case .progressive: return 4
        }
    }
}

/// Progressive mode level configuration
struct ProgressiveLevel {
    let level: Int
    let columns: Int
    let pairsToMatch: Int
    let timeLimit: Int
    let scoreMultiplier: Double
    
    /// Get level configuration for a given level number
    static func forLevel(_ level: Int) -> ProgressiveLevel {
        switch level {
        case 1:
            return ProgressiveLevel(level: 1, columns: 3, pairsToMatch: 4, timeLimit: 45, scoreMultiplier: 1.0)
        case 2:
            return ProgressiveLevel(level: 2, columns: 3, pairsToMatch: 4, timeLimit: 35, scoreMultiplier: 1.2)
        case 3:
            return ProgressiveLevel(level: 3, columns: 5, pairsToMatch: 12, timeLimit: 90, scoreMultiplier: 1.5)
        case 4:
            return ProgressiveLevel(level: 4, columns: 5, pairsToMatch: 12, timeLimit: 75, scoreMultiplier: 1.8)
        case 5:
            return ProgressiveLevel(level: 5, columns: 7, pairsToMatch: 24, timeLimit: 150, scoreMultiplier: 2.0)
        case 6:
            return ProgressiveLevel(level: 6, columns: 7, pairsToMatch: 24, timeLimit: 120, scoreMultiplier: 2.5)
        default:
            // Beyond level 6, increasingly hard
            let extraLevel = level - 6
            let timeReduction = min(extraLevel * 10, 60) // Max 60 second reduction
            return ProgressiveLevel(
                level: level,
                columns: 7,
                pairsToMatch: 24,
                timeLimit: max(120 - timeReduction, 60),
                scoreMultiplier: 2.5 + Double(extraLevel) * 0.5
            )
        }
    }
    
    var totalCards: Int {
        return columns * columns
    }
}

/// Scoring configuration for bonuses and penalties
struct ScoringConfig {
    // Base points
    static let matchPoints = 10
    static let mismatchPenalty = -3
    
    // Combo system
    static let comboMultiplierIncrement = 0.25  // Each consecutive match adds 25%
    static let maxComboMultiplier = 3.0
    
    // Time bonuses
    static let quickMatchBonus = 5        // Match within 3 seconds
    static let speedRunBonus = 50         // Finish with >50% time remaining
    static let clutchBonus = 25           // Finish with <10% time remaining
    
    // Streak bonuses
    static let streak3Bonus = 15          // 3 matches in a row
    static let streak5Bonus = 30          // 5 matches in a row
    static let streak7Bonus = 50          // 7 matches in a row
    
    // Special bonuses
    static let perfectGameBonus = 100     // No mistakes
    static let noHintBonus = 25           // Finish without hints (future feature)
    static let firstTryBonus = 5          // First pair found on first try
    
    // Penalties
    static let decoyTapPenalty = -5       // Tapping the decoy card
    static let timeoutPenalty = -20       // Running out of time (per level in progressive)
    static let repeatedMismatchPenalty = -2  // Extra penalty for same wrong pair
}
