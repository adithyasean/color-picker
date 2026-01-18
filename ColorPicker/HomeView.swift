import SwiftUI

struct HomeView: View {
    @State private var animateGradient = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Gradient Background
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple, Color.indigo]), startPoint: animateGradient ? .topLeading : .bottomLeading, endPoint: animateGradient ? .bottomTrailing : .topTrailing)
                    .ignoresSafeArea()
                    .hueRotation(.degrees(animateGradient ? 45 : 0))
                    .onAppear {
                        withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                            animateGradient.toggle()
                        }
                    }
                
                VStack(spacing: 40) {
                    // Logo / Title
                    Spacer()
                    
                    VStack {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                            .shadow(radius: 10)
                        
                        Text("Color Picker")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                            .padding(.top)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: GameView()) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play Game")
                            }
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white, in: Capsule())
                            .foregroundStyle(.indigo)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        
                        NavigationLink(destination: HighScoresView()) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                Text("High Scores")
                            }
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
