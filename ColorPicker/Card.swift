import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let color: Color
    var isFaceUp = false
    var isMatched = false
}
