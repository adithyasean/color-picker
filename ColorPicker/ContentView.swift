//
//  ContentView.swift
//  ColorPicker
//
//  Created by Adithya Ekanayaka on 2026-01-17.
//

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let color: Color
    var isFaceUp = false
    var isMatched = false
}

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var firstSelectedIndex: Int?
    @State private var score = 0
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init() {
        _cards = State(initialValue: Self.createDeck())
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header & Score
                VStack(spacing: 10) {
                    Text("Memory Game")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                    
                    Text("Score: \(score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
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
                
                // Reset Button
                Button {
                    withAnimation {
                        restartGame()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Restart Game")
                    }
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.indigo)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
        }
    }
    
    func choose(_ index: Int) {
        if cards[index].isFaceUp || cards[index].isMatched { return }
        
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
        } else {
            // Mismatch
            // Only penalize if score > 0
            if score > 0 { score -= 1 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Verify card indices are still valid and they are not matched
                if cards.indices.contains(index1) && cards.indices.contains(index2) {
                    if !cards[index1].isMatched {
                        withAnimation {
                           cards[index1].isFaceUp = false
                        }
                    }
                    if !cards[index2].isMatched {
                         withAnimation {
                            cards[index2].isFaceUp = false
                         }
                    }
                }
            }
        }
    }
    
    func restartGame() {
        cards = Self.createDeck()
        firstSelectedIndex = nil
        score = 0
    }
    
    static func createDeck() -> [Card] {
        // Bright, vibrant colors
        let colors: [Color] = [.cyan, .mint, .orange, .pink]
        var deck = colors + colors
        deck.append(.white) // Odd one out is white/neutral
        deck.shuffle()
        return deck.map { Card(color: $0) }
    }
}

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 16)
            
            if card.isFaceUp || card.isMatched {
                shape
                    .fill()
                    .foregroundColor(.white) // Border/Background for color
                shape
                    .fill(card.color)
                    .padding(4)
                
                if card.isMatched {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                shape
                    .fill(Color(white: 0.2)) // Dark gray back
                Image(systemName: "questionmark")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        // 3D Rotation Calculation
        // If faceUp, angle is 0 (or 180 depending on start). 
        // Let's keep it simple: Just conditional view rendering with `rotation3DEffect`
        // But for a true flip, we effectively rotate 180.
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        // Note: For a real 2-sided flip, we'd need a more complex ZStack structure where front/back opacity changes.
        // However, SwiftUI's Conditional + Rotation often works 'okay' if opacity transitions are default.
        // To make it look "Physical", 180 degrees shows the mirrored back.
        // A common trick is:
        // Always show the front, but if not faceUp, overlay the back?
        // Let's refine this slightly for better visual result:
        // Actually, the simplest reliable flip in SwiftUI without advanced geometry readers:
        // Just animate the state change. The rotation above might show the "back" of the drawn rectangle which is just the color reversed.
        // Let's stick to the conditional rendering + a transition or just let the rotation happen on the whole container?
        // 
        // Better Move:
        // Use the `.rotation3DEffect` but realizing that at 180 degrees, the view is mirrored.
        // So we need to handle that content-wise or just accept it's a simple flip.
        // Given constraints, I'll stick to a simple animated transition for now, but apply the rotation to the modifier.
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
