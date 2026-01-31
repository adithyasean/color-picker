import SwiftUI

struct HighScoresView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @State private var selectedMode: GameMode?
    
    var filteredScores: [PlayerScore] {
        if let mode = selectedMode {
            return scoreManager.scores(for: mode)
        }
        return scoreManager.highScores
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("High Scores")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top)
                
                // Mode filter tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ModeFilterPill(
                            name: "All",
                            icon: "list.bullet",
                            color: .white,
                            isSelected: selectedMode == nil
                        )
                        .onTapGesture { selectedMode = nil }
                        
                        ForEach(GameMode.allCases) { mode in
                            ModeFilterPill(
                                name: mode.displayName,
                                icon: mode.icon,
                                color: mode.color,
                                isSelected: selectedMode == mode
                            )
                            .onTapGesture { selectedMode = mode }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
                
                if filteredScores.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "trophy")
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("No scores yet!")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.7))
                        if selectedMode != nil {
                            Text("Play \(selectedMode!.displayName) mode to set a score")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(Array(filteredScores.enumerated()), id: \.offset) { index, item in
                            ScoreRow(index: index, item: item)
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.regularMaterial)
                                        .padding(.vertical, 4)
                                )
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding()
                }
            }
        }
    }
}

struct ModeFilterPill: View {
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

struct ScoreRow: View {
    let index: Int
    let item: PlayerScore
    
    var modeColor: Color {
        if let mode = GameMode(rawValue: item.gameMode) {
            return mode.color
        }
        return .gray
    }
    
    var modeName: String {
        if let mode = GameMode(rawValue: item.gameMode) {
            return mode.displayName
        }
        return "Classic"
    }
    
    var rankIcon: String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return ""
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                if index < 3 {
                    Text(rankIcon)
                        .font(.title2)
                } else {
                    Text("#\(index + 1)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 40, alignment: .center)
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    // Mode badge
                    Text(modeName)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(modeColor.opacity(0.8), in: Capsule())
                }
                
                HStack(spacing: 8) {
                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if item.maxStreak > 1 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                            Text("\(item.maxStreak)")
                                .font(.caption2)
                        }
                        .foregroundStyle(.orange)
                    }
                    
                    if item.maxCombo > 1.0 {
                        HStack(spacing: 2) {
                            Image(systemName: "multiply.circle.fill")
                                .font(.caption2)
                            Text(String(format: "%.1fx", item.maxCombo))
                                .font(.caption2)
                        }
                        .foregroundStyle(.purple)
                    }
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(item.score)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                
                if item.level > 1 {
                    Text("Lv.\(item.level)")
                        .font(.caption2)
                        .foregroundStyle(.purple)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HighScoresView()
}
