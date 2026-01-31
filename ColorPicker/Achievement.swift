import Foundation
import SwiftUI

/// Achievement definition
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int  // The target value to unlock
    var isSecret: Bool = false
    
    /// Icon color based on category
    var color: Color {
        category.color
    }
}

/// Achievement categories
enum AchievementCategory: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case mastery = "Mastery"
    case speed = "Speed"
    case streak = "Streak"
    case collection = "Collection"
    case special = "Special"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .mastery: return .purple
        case .speed: return .orange
        case .streak: return .red
        case .collection: return .blue
        case .special: return .yellow
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "star"
        case .mastery: return "crown"
        case .speed: return "bolt"
        case .streak: return "flame"
        case .collection: return "square.stack.3d.up"
        case .special: return "sparkles"
        }
    }
}

/// Player progress for an achievement
struct AchievementProgress: Codable, Identifiable {
    var id: String { achievementId }
    let achievementId: String
    var currentProgress: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
}

/// Manages achievement definitions and player progress
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    private let progressKey = "achievement_progress_v1"
    private let statsKey = "player_stats_v1"
    
    @Published var achievements: [Achievement] = []
    @Published var progress: [String: AchievementProgress] = [:]
    @Published var stats: PlayerStats = PlayerStats()
    @Published var recentUnlock: Achievement? = nil
    
    init() {
        setupAchievements()
        loadProgress()
        loadStats()
    }
    
    // MARK: - Achievement Definitions
    
    private func setupAchievements() {
        achievements = [
            // Beginner achievements
            Achievement(id: "first_match", name: "First Steps", description: "Complete your first match", icon: "hand.tap", category: .beginner, requirement: 1),
            Achievement(id: "first_game", name: "Getting Started", description: "Complete your first game", icon: "flag.checkered", category: .beginner, requirement: 1),
            Achievement(id: "games_10", name: "Dedicated Player", description: "Complete 10 games", icon: "gamecontroller", category: .beginner, requirement: 10),
            Achievement(id: "games_50", name: "Veteran", description: "Complete 50 games", icon: "medal", category: .beginner, requirement: 50),
            Achievement(id: "games_100", name: "Centurion", description: "Complete 100 games", icon: "trophy", category: .beginner, requirement: 100),
            
            // Mastery achievements
            Achievement(id: "classic_master", name: "Classic Master", description: "Score 50+ in Classic mode", icon: "star.fill", category: .mastery, requirement: 50),
            Achievement(id: "medium_master", name: "Medium Master", description: "Score 150+ in Medium mode", icon: "star.circle.fill", category: .mastery, requirement: 150),
            Achievement(id: "hard_master", name: "Hard Master", description: "Score 300+ in Hard mode", icon: "star.square.fill", category: .mastery, requirement: 300),
            Achievement(id: "progressive_5", name: "Rising Star", description: "Reach level 5 in Progressive mode", icon: "chart.line.uptrend.xyaxis", category: .mastery, requirement: 5),
            Achievement(id: "progressive_10", name: "Unstoppable", description: "Reach level 10 in Progressive mode", icon: "arrow.up.circle.fill", category: .mastery, requirement: 10),
            
            // Speed achievements
            Achievement(id: "speed_classic", name: "Quick Hands", description: "Complete Classic in under 30 seconds", icon: "hare", category: .speed, requirement: 30),
            Achievement(id: "speed_medium", name: "Lightning Fast", description: "Complete Medium in under 60 seconds", icon: "bolt.fill", category: .speed, requirement: 60),
            Achievement(id: "speed_hard", name: "Time Bender", description: "Complete Hard in under 90 seconds", icon: "timer", category: .speed, requirement: 90),
            Achievement(id: "quick_match_10", name: "Speed Demon", description: "Get 10 quick match bonuses", icon: "gauge.with.dots.needle.67percent", category: .speed, requirement: 10),
            
            // Streak achievements
            Achievement(id: "streak_3", name: "On Fire", description: "Get a 3-match streak", icon: "flame", category: .streak, requirement: 3),
            Achievement(id: "streak_5", name: "Blazing", description: "Get a 5-match streak", icon: "flame.fill", category: .streak, requirement: 5),
            Achievement(id: "streak_7", name: "Inferno", description: "Get a 7-match streak", icon: "flame.circle.fill", category: .streak, requirement: 7),
            Achievement(id: "streak_10", name: "Legendary Streak", description: "Get a 10-match streak", icon: "fireworks", category: .streak, requirement: 10),
            Achievement(id: "combo_max", name: "Combo King", description: "Reach maximum combo multiplier (3x)", icon: "multiply.circle.fill", category: .streak, requirement: 3),
            
            // Collection achievements
            Achievement(id: "all_modes", name: "Explorer", description: "Play all game modes", icon: "map", category: .collection, requirement: 4),
            Achievement(id: "total_matches_100", name: "Match Collector", description: "Make 100 total matches", icon: "square.grid.2x2", category: .collection, requirement: 100),
            Achievement(id: "total_matches_500", name: "Match Hoarder", description: "Make 500 total matches", icon: "square.grid.3x3", category: .collection, requirement: 500),
            Achievement(id: "total_score_1000", name: "Point Collector", description: "Earn 1,000 total points", icon: "123.rectangle", category: .collection, requirement: 1000),
            Achievement(id: "total_score_10000", name: "Point Hoarder", description: "Earn 10,000 total points", icon: "banknote", category: .collection, requirement: 10000),
            
            // Special achievements
            Achievement(id: "perfect_classic", name: "Perfectionist", description: "Complete Classic with no mistakes", icon: "checkmark.seal.fill", category: .special, requirement: 1),
            Achievement(id: "perfect_medium", name: "Flawless", description: "Complete Medium with no mistakes", icon: "sparkle", category: .special, requirement: 1),
            Achievement(id: "perfect_hard", name: "Immaculate", description: "Complete Hard with no mistakes", icon: "crown.fill", category: .special, requirement: 1),
            Achievement(id: "clutch_win", name: "Clutch Player", description: "Win with less than 5 seconds remaining", icon: "clock.badge.exclamationmark", category: .special, requirement: 1),
            Achievement(id: "comeback", name: "Comeback Kid", description: "Win after being at 0 points", icon: "arrow.uturn.up.circle", category: .special, requirement: 1, isSecret: true),
            Achievement(id: "decoy_avoided", name: "Decoy Dodger", description: "Complete 10 games without tapping decoy", icon: "eyes", category: .special, requirement: 10, isSecret: true)
        ]
    }
    
    // MARK: - Progress Tracking
    
    func incrementProgress(for achievementId: String, by amount: Int = 1) {
        guard let achievement = achievements.first(where: { $0.id == achievementId }) else { return }
        
        var current = progress[achievementId] ?? AchievementProgress(achievementId: achievementId, currentProgress: 0, isUnlocked: false)
        
        if !current.isUnlocked {
            current.currentProgress += amount
            
            if current.currentProgress >= achievement.requirement {
                current.isUnlocked = true
                current.unlockedDate = Date()
                recentUnlock = achievement
                
                // Haptic feedback for unlock
                #if os(iOS)
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
                #endif
            }
            
            progress[achievementId] = current
            saveProgress()
        }
    }
    
    func setProgress(for achievementId: String, to value: Int) {
        guard let achievement = achievements.first(where: { $0.id == achievementId }) else { return }
        
        var current = progress[achievementId] ?? AchievementProgress(achievementId: achievementId, currentProgress: 0, isUnlocked: false)
        
        if !current.isUnlocked {
            current.currentProgress = max(current.currentProgress, value)
            
            if current.currentProgress >= achievement.requirement {
                current.isUnlocked = true
                current.unlockedDate = Date()
                recentUnlock = achievement
                
                #if os(iOS)
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.success)
                #endif
            }
            
            progress[achievementId] = current
            saveProgress()
        }
    }
    
    func unlockAchievement(_ achievementId: String) {
        guard let achievement = achievements.first(where: { $0.id == achievementId }) else { return }
        
        var current = progress[achievementId] ?? AchievementProgress(achievementId: achievementId, currentProgress: 0, isUnlocked: false)
        
        if !current.isUnlocked {
            current.currentProgress = achievement.requirement
            current.isUnlocked = true
            current.unlockedDate = Date()
            recentUnlock = achievement
            
            #if os(iOS)
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            #endif
            
            progress[achievementId] = current
            saveProgress()
        }
    }
    
    func getProgress(for achievementId: String) -> AchievementProgress {
        return progress[achievementId] ?? AchievementProgress(achievementId: achievementId, currentProgress: 0, isUnlocked: false)
    }
    
    func isUnlocked(_ achievementId: String) -> Bool {
        return progress[achievementId]?.isUnlocked ?? false
    }
    
    var unlockedCount: Int {
        return progress.values.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        return achievements.count
    }
    
    func clearRecentUnlock() {
        recentUnlock = nil
    }
    
    // MARK: - Stats Tracking
    
    func recordGameCompletion(mode: GameMode, score: Int, time: Int, moves: Int, mistakes: Int, maxStreak: Int, maxCombo: Double, level: Int = 1, tappedDecoy: Bool = false) {
        stats.totalGamesPlayed += 1
        stats.totalScore += score
        stats.totalMatches += (moves - mistakes)
        stats.modesPlayed.insert(mode.rawValue)
        
        if maxStreak > stats.longestStreak {
            stats.longestStreak = maxStreak
        }
        
        if maxCombo > stats.highestCombo {
            stats.highestCombo = maxCombo
        }
        
        if !tappedDecoy {
            stats.gamesWithoutDecoy += 1
        } else {
            stats.gamesWithoutDecoy = 0
        }
        
        saveStats()
        
        // Check various achievements
        incrementProgress(for: "first_game")
        incrementProgress(for: "games_10")
        incrementProgress(for: "games_50")
        incrementProgress(for: "games_100")
        incrementProgress(for: "total_matches_100", by: moves - mistakes)
        incrementProgress(for: "total_matches_500", by: moves - mistakes)
        incrementProgress(for: "total_score_1000", by: score)
        incrementProgress(for: "total_score_10000", by: score)
        setProgress(for: "all_modes", to: stats.modesPlayed.count)
        setProgress(for: "streak_3", to: maxStreak)
        setProgress(for: "streak_5", to: maxStreak)
        setProgress(for: "streak_7", to: maxStreak)
        setProgress(for: "streak_10", to: maxStreak)
        
        if maxCombo >= 3.0 {
            unlockAchievement("combo_max")
        }
        
        if !tappedDecoy {
            incrementProgress(for: "decoy_avoided")
        }
        
        // Mode-specific achievements
        switch mode {
        case .classic3x3:
            if score >= 50 { unlockAchievement("classic_master") }
            if time <= 30 { unlockAchievement("speed_classic") }
            if mistakes == 0 { unlockAchievement("perfect_classic") }
        case .medium5x5:
            if score >= 150 { unlockAchievement("medium_master") }
            if time <= 60 { unlockAchievement("speed_medium") }
            if mistakes == 0 { unlockAchievement("perfect_medium") }
        case .hard7x7:
            if score >= 300 { unlockAchievement("hard_master") }
            if time <= 90 { unlockAchievement("speed_hard") }
            if mistakes == 0 { unlockAchievement("perfect_hard") }
        case .progressive:
            setProgress(for: "progressive_5", to: level)
            setProgress(for: "progressive_10", to: level)
        }
    }
    
    func recordMatch() {
        incrementProgress(for: "first_match")
    }
    
    func recordQuickMatch() {
        incrementProgress(for: "quick_match_10")
    }
    
    func recordClutchWin() {
        unlockAchievement("clutch_win")
    }
    
    func recordComeback() {
        unlockAchievement("comeback")
    }
    
    // MARK: - Persistence
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let saved = try? JSONDecoder().decode([String: AchievementProgress].self, from: data) {
            progress = saved
        }
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    private func loadStats() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let saved = try? JSONDecoder().decode(PlayerStats.self, from: data) {
            stats = saved
        }
    }
}

/// Player statistics across all games
struct PlayerStats: Codable {
    var totalGamesPlayed: Int = 0
    var totalScore: Int = 0
    var totalMatches: Int = 0
    var longestStreak: Int = 0
    var highestCombo: Double = 1.0
    var modesPlayed: Set<String> = []
    var gamesWithoutDecoy: Int = 0
}
