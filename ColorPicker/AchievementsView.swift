import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @State private var selectedCategory: AchievementCategory?
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementManager.achievements.filter { $0.category == category }
        }
        return achievementManager.achievements
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Achievements")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    // Progress indicator
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("\(achievementManager.unlockedCount)/\(achievementManager.totalCount)")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryPill(
                            name: "All",
                            icon: "square.grid.2x2",
                            color: .white,
                            isSelected: selectedCategory == nil
                        )
                        .onTapGesture { selectedCategory = nil }
                        
                        ForEach(AchievementCategory.allCases, id: \.self) { category in
                            CategoryPill(
                                name: category.rawValue,
                                icon: category.icon,
                                color: category.color,
                                isSelected: selectedCategory == category
                            )
                            .onTapGesture { selectedCategory = category }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
                
                // Achievement list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementRow(
                                achievement: achievement,
                                progress: achievementManager.getProgress(for: achievement.id)
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct CategoryPill: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(name)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isSelected ? color.opacity(0.8) : .white.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(isSelected ? color : .clear, lineWidth: 2)
        )
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let progress: AchievementProgress
    
    var progressPercent: Double {
        guard achievement.requirement > 0 else { return 0 }
        return min(1.0, Double(progress.currentProgress) / Double(achievement.requirement))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(progress.isUnlocked ? achievement.color.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                if progress.isUnlocked {
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundStyle(achievement.color)
                } else if achievement.isSecret && !progress.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundStyle(.gray)
                } else {
                    Image(systemName: achievement.icon)
                        .font(.title2)
                        .foregroundStyle(.gray.opacity(0.5))
                }
                
                // Progress ring for locked achievements
                if !progress.isUnlocked && !achievement.isSecret {
                    Circle()
                        .stroke(.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .trim(from: 0, to: progressPercent)
                        .stroke(achievement.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if achievement.isSecret && !progress.isUnlocked {
                        Text("???")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    } else {
                        Text(achievement.name)
                            .font(.headline)
                            .foregroundStyle(progress.isUnlocked ? .primary : .secondary)
                    }
                    
                    Spacer()
                    
                    if progress.isUnlocked {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                if achievement.isSecret && !progress.isUnlocked {
                    Text("Keep playing to discover this secret achievement!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    Text(achievement.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                // Progress text
                if !progress.isUnlocked && !achievement.isSecret {
                    HStack {
                        Text("\(progress.currentProgress)/\(achievement.requirement)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(progressPercent * 100))%")
                            .font(.caption2)
                            .foregroundStyle(achievement.color)
                    }
                    .padding(.top, 2)
                }
                
                // Unlock date
                if progress.isUnlocked, let date = progress.unlockedDate {
                    Text("Unlocked \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundStyle(.green.opacity(0.8))
                        .padding(.top, 2)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .opacity(progress.isUnlocked ? 1 : 0.7)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(progress.isUnlocked ? achievement.color.opacity(0.5) : .clear, lineWidth: 2)
        )
    }
}

// MARK: - Stats View (Bonus feature)

struct StatsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    
    var stats: PlayerStats {
        achievementManager.stats
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Stats")
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatCard(title: "Games Played", value: "\(stats.totalGamesPlayed)", icon: "gamecontroller.fill", color: .blue)
                StatCard(title: "Total Score", value: "\(stats.totalScore)", icon: "star.fill", color: .yellow)
                StatCard(title: "Total Matches", value: "\(stats.totalMatches)", icon: "checkmark.circle.fill", color: .green)
                StatCard(title: "Best Streak", value: "\(stats.longestStreak)", icon: "flame.fill", color: .orange)
                StatCard(title: "Best Combo", value: String(format: "%.1fx", stats.highestCombo), icon: "multiply.circle.fill", color: .purple)
                StatCard(title: "Modes Played", value: "\(stats.modesPlayed.count)/4", icon: "square.grid.2x2.fill", color: .teal)
            }
        }
        .padding()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title.bold())
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
}
