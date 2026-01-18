import SwiftUI

struct HighScoresView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                Text("High Scores")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top)
                
                if scoreManager.highScores.isEmpty {
                    Spacer()
                    Text("No scores yet!")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                } else {
                    List {
                        ForEach(Array(scoreManager.highScores.enumerated()), id: \.offset) { index, item in
                            HStack(spacing: 16) {
                                Text("#\(index + 1)")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 35, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(item.score)")
                                    .font(.system(.title3, design: .rounded, weight: .bold))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.regularMaterial)
                                    .padding(.vertical, 4) // Add spacing between rows
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

#Preview {
    HighScoresView()
}
