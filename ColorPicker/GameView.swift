import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var cards: [Card] = []
    @State private var firstSelectedIndex: Int?
    @State private var score = 0
    @State private var moves = 0
    @State private var matchedPairs = 0
    @State private var showGameOver = false
    @State private var playerName = ""
    @State private var showExitConfirmation = false
    @State private var showRestartConfirmation = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header & Score
                HStack(spacing: 40) {
                    VStack(spacing: 5) {
                        Text("Score")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        Text("\(score)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(spacing: 5) {
                        Text("Moves")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        Text("\(moves)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top)
                
                // Game Grid
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(cards.indices, id: \.self) { index in
                        CardView(card: cards[index])
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    choose(index)
                                }
                            }
                    }
                }
                .padding(20)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    // Confirm exit if game has progress
                    if moves > 0 && matchedPairs < 4 {
                        showExitConfirmation = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // Confirm restart if game has progress
                    if moves > 0 && matchedPairs < 4 {
                        showRestartConfirmation = true
                    } else {
                        restartGame()
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .alert("End Game?", isPresented: $showExitConfirmation) {
            Button("End Game", role: .destructive) { dismiss() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Current progress will be lost.")
        }
        .alert("Restart Game?", isPresented: $showRestartConfirmation) {
            Button("Restart", role: .destructive) { restartGame() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Current progress will be lost.")
        }
        .alert("Game Over!", isPresented: $showGameOver) {
            TextField("Your Name", text: $playerName)
            Button("Save & Play Again") {
                saveScoreAndRestart()
            }
            Button("Save & Menu") {
                saveScore()
                dismiss()
            }
            Button("Discard & Menu", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Final Score: \(score)\nMoves: \(moves)\nEnter your name to save.")
        }
        .onAppear {
            if cards.isEmpty {
                cards = GameView.createDeck()
            }
        }
    }
    
    func choose(_ index: Int) {
        if cards[index].isFaceUp || cards[index].isMatched { return }
        
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        #endif
        
        if let firstIndex = firstSelectedIndex {
            // Second card
            cards[index].isFaceUp = true
            firstSelectedIndex = nil
            checkForMatch(index1: firstIndex, index2: index)
        } else {
            // First card
            cards[index].isFaceUp = true
            firstSelectedIndex = index
        }
    }
    
    func checkForMatch(index1: Int, index2: Int) {
        if cards[index1].color == cards[index2].color {
            // Match
            cards[index1].isMatched = true
            cards[index2].isMatched = true
            score += 2
            matchedPairs += 1
            moves += 1
            
            // Success Haptic
            #if os(iOS)
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            #endif
            
            if matchedPairs == 4 {
                // Win!
                endGame()
            }
        } else {
            // Mismatch
            if score > 0 { score -= 1 }
            moves += 1
            
            // Failure Haptic
            #if os(iOS)
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.warning)
            #endif
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if cards.indices.contains(index1) && cards.indices.contains(index2) {
                    if !cards[index1].isMatched {
                        withAnimation { cards[index1].isFaceUp = false }
                    }
                    if !cards[index2].isMatched {
                        withAnimation { cards[index2].isFaceUp = false }
                    }
                }
            }
        }
    }
    
    func endGame() {
        // Delay slightly to show visual state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showGameOver = true
        }
    }
    
    func saveScore() {
        ScoreManager.shared.saveScore(score: score, name: playerName)
    }
    
    func saveScoreAndRestart() {
        saveScore()
        restartGame()
    }

    
    func restartGame() {
        cards = Self.createDeck()
        firstSelectedIndex = nil
        score = 0
        moves = 0
        matchedPairs = 0
        playerName = ""
    }
    
    static func createDeck() -> [Card] {
        let colors: [Color] = [.cyan, .mint, .orange, .pink]
        var deck = colors + colors
        deck.append(.white)
        deck.shuffle()
        return deck.map { Card(color: $0) }
    }
}
