import Foundation
import Combine

struct PlayerScore: Codable, Identifiable {
    var id = UUID()
    let name: String
    let score: Int
    let date: Date
    var gameMode: String = "classic"  // Default for backwards compatibility
    var timeElapsed: Int = 0          // Time in seconds
    var moves: Int = 0
    var mistakes: Int = 0
    var maxStreak: Int = 0
    var maxCombo: Double = 1.0
    var level: Int = 1                // For progressive mode
    var bonusesEarned: Int = 0
    var penaltiesIncurred: Int = 0
}

/// Detailed game result for score breakdown
struct GameResult {
    let baseScore: Int
    let comboBonus: Int
    let streakBonus: Int
    let timeBonus: Int
    let perfectBonus: Int
    let penalties: Int
    let finalScore: Int
    let maxStreak: Int
    let maxCombo: Double
    let mistakes: Int
    let timeElapsed: Int
    let level: Int
    
    var totalBonuses: Int {
        comboBonus + streakBonus + timeBonus + perfectBonus
    }
}

class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    
    private let key = "high_scores_v3"
    private let legacyKey = "high_scores_v2"
    @Published var highScores: [PlayerScore] = []
    
    init() {
        loadScores()
    }
    
    func saveScore(score: Int, name: String, gameMode: GameMode = .classic3x3, timeElapsed: Int = 0, moves: Int = 0, mistakes: Int = 0, maxStreak: Int = 0, maxCombo: Double = 1.0, level: Int = 1, bonuses: Int = 0, penalties: Int = 0) {
        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Anonymous" : name
        let newScore = PlayerScore(
            name: finalName,
            score: score,
            date: Date(),
            gameMode: gameMode.rawValue,
            timeElapsed: timeElapsed,
            moves: moves,
            mistakes: mistakes,
            maxStreak: maxStreak,
            maxCombo: maxCombo,
            level: level,
            bonusesEarned: bonuses,
            penaltiesIncurred: penalties
        )
        
        highScores.append(newScore)
        highScores.sort { $0.score > $1.score }
        highScores = Array(highScores.prefix(50)) // Keep top 50 across all modes
        
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadScores() {
        // Try loading new format first
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([PlayerScore].self, from: data) {
            highScores = saved
            return
        }
        
        // Fall back to legacy format
        if let data = UserDefaults.standard.data(forKey: legacyKey),
           let saved = try? JSONDecoder().decode([PlayerScore].self, from: data) {
            highScores = saved
            // Migrate to new key
            if let encoded = try? JSONEncoder().encode(highScores) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
    }
    
    /// Get scores filtered by game mode
    func scores(for mode: GameMode) -> [PlayerScore] {
        return highScores.filter { $0.gameMode == mode.rawValue }
    }
    
    /// Get top scores for a specific mode
    func topScores(for mode: GameMode, limit: Int = 10) -> [PlayerScore] {
        return Array(scores(for: mode).prefix(limit))
    }
    
    /// Get all-time best score for a mode
    func bestScore(for mode: GameMode) -> PlayerScore? {
        return scores(for: mode).first
    }
}
