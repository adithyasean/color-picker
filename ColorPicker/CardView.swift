import SwiftUI

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
                ZStack {
                    shape
                        .fill(Color(white: 0.2)) // Dark gray back
                    Image(systemName: "questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.3))
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // Fix mirroring
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp || card.isMatched ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
