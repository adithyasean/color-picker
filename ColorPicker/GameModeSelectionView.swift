import SwiftUI

struct GameModeSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedMode: GameMode?
    @State private var showGame = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.9), Color.purple.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Select Mode")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text("Choose your challenge")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Mode Cards
                    ForEach(GameMode.allCases) { mode in
                        GameModeCard(mode: mode, isSelected: selectedMode == mode)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedMode = mode
                                }
                                
                                #if os(iOS)
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
                                #endif
                            }
                    }
                    
                    // Play Button
                    Button {
                        if selectedMode != nil {
                            showGame = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Game")
                        }
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(selectedMode != nil ? Color.white : Color.white.opacity(0.3), in: Capsule())
                        .foregroundStyle(selectedMode != nil ? .indigo : .white.opacity(0.5))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .disabled(selectedMode == nil)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
        }
        .navigationDestination(isPresented: $showGame) {
            if let mode = selectedMode {
                GameView(gameMode: mode)
            }
        }
    }
}

struct GameModeCard: View {
    let mode: GameMode
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon
                Image(systemName: mode.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(mode.color)
                    .frame(width: 50, height: 50)
                    .background(mode.color.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(mode.displayName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        // Difficulty stars
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < mode.difficultyStars ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundStyle(index < mode.difficultyStars ? .yellow : .gray.opacity(0.3))
                            }
                        }
                    }
                    
                    Text(mode.gridDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Text(mode.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            // Stats row
            HStack(spacing: 16) {
                if mode != .progressive {
                    StatBadge(icon: "square.grid.2x2", text: "\(mode.pairsToMatch) Pairs")
                }
                
                if let time = mode.timeLimit {
                    StatBadge(icon: "clock", text: "\(time)s")
                } else {
                    StatBadge(icon: "clock", text: "No Limit")
                }
                
                StatBadge(icon: "star.fill", text: "\(mode.scoreMultiplier, specifier: "%.1f")x")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? mode.color : .clear, lineWidth: 3)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(color: isSelected ? mode.color.opacity(0.3) : .black.opacity(0.1), radius: isSelected ? 15 : 8, x: 0, y: 5)
    }
}

struct StatBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.15), in: Capsule())
    }
}

#Preview {
    NavigationStack {
        GameModeSelectionView()
    }
}
