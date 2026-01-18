import Foundation
import Combine

struct PlayerScore: Codable, Identifiable {
    var id = UUID()
    let name: String
    let score: Int
    let date: Date
}

class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    
    private let key = "high_scores_v2" 
    @Published var highScores: [PlayerScore] = []
    
    init() {
        loadScores()
    }
    
    func saveScore(score: Int, name: String) {
        let finalName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Anonymous" : name
        let newScore = PlayerScore(name: finalName, score: score, date: Date())
        
        highScores.append(newScore)
        highScores.sort { $0.score > $1.score } // Descending order
        highScores = Array(highScores.prefix(10)) // Keep top 10
        
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadScores() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([PlayerScore].self, from: data) {
            highScores = saved
        }
    }
}
