import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var achievementManager = AchievementManager.shared
    
    // Game configuration
    let gameMode: GameMode
    
    // Game state
    @State private var cards: [Card] = []
    @State private var firstSelectedIndex: Int?
    @State private var score = 0
    @State private var moves = 0
    @State private var matchedPairs = 0
    @State private var mistakes = 0
    @State private var showGameOver = false
    @State private var playerName = ""
    @State private var showExitConfirmation = false
    @State private var showRestartConfirmation = false
    
    // Timer state
    @State private var timeRemaining: Int = 0
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    @State private var lastMatchTime: Date?
    
    // Combo & Streak tracking
    @State private var currentStreak = 0
    @State private var maxStreak = 0
    @State private var comboMultiplier = 1.0
    @State private var maxCombo = 1.0
    
    // Bonus tracking
    @State private var totalBonuses = 0
    @State private var totalPenalties = 0
    @State private var quickMatchCount = 0
    @State private var tappedDecoy = false
    @State private var wasAtZero = false
    
    // Progressive mode state
    @State private var currentLevel = 1
    @State private var currentLevelConfig: ProgressiveLevel?
    @State private var showLevelComplete = false
    @State private var levelScore = 0
    
    // Feedback
    @State private var showBonusText: String?
    @State private var showPenaltyText: String?
    @State private var showAchievementUnlock = false
    
    // Game result for end screen
    @State private var gameResult: GameResult?
    
    // Computed columns based on mode/level
    var columns: [GridItem] {
        let columnCount = currentLevelConfig?.columns ?? gameMode.columns
        return Array(repeating: GridItem(.flexible(), spacing: columnCount > 5 ? 8 : 12), count: columnCount)
    }
    
    var currentPairsToMatch: Int {
        currentLevelConfig?.pairsToMatch ?? gameMode.pairsToMatch
    }
    
    var hasTimeLimit: Bool {
        gameMode.timeLimit != nil || gameMode == .progressive
    }
    
    init(gameMode: GameMode = .classic3x3) {
        self.gameMode = gameMode
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.indigo.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header with stats
                gameHeader
                
                // Timer bar (if applicable)
                if hasTimeLimit {
                    timerBar
                }
                
                // Game Grid
                LazyVGrid(columns: columns, spacing: columns.count > 5 ? 8 : 12) {
                    ForEach(cards.indices, id: \.self) { index in
                        CardView(card: cards[index])
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    choose(index)
                                }
                            }
                    }
                }
                .padding(.horizontal, columns.count > 5 ? 8 : 16)
                
                Spacer()
                
                // Bonus/Penalty feedback
                if let bonus = showBonusText {
                    Text(bonus)
                        .font(.headline)
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
                
                if let penalty = showPenaltyText {
                    Text(penalty)
                        .font(.headline)
                        .foregroundStyle(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Achievement unlock overlay
            if showAchievementUnlock, let achievement = achievementManager.recentUnlock {
                achievementUnlockOverlay(achievement)
            }
            
            // Level complete overlay (Progressive mode)
            if showLevelComplete {
                levelCompleteOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    if moves > 0 && matchedPairs < currentPairsToMatch {
                        showExitConfirmation = true
                    } else {
                        stopTimer()
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(gameMode.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    if gameMode == .progressive {
                        Text("Level \(currentLevel)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if moves > 0 && matchedPairs < currentPairsToMatch {
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
            Button("End Game", role: .destructive) {
                stopTimer()
                dismiss()
            }
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
            if let result = gameResult {
                Text(gameOverMessage(result))
            } else {
                Text("Final Score: \(score)\nMoves: \(moves)")
            }
        }
        .onAppear {
            if cards.isEmpty {
                setupGame()
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: achievementManager.recentUnlock) { _, newValue in
            if newValue != nil {
                withAnimation(.spring()) {
                    showAchievementUnlock = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showAchievementUnlock = false
                        achievementManager.clearRecentUnlock()
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var gameHeader: some View {
        HStack(spacing: 20) {
            // Score
            VStack(spacing: 4) {
                Text("Score")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text("\(score)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            
            // Combo
            VStack(spacing: 4) {
                Text("Combo")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text("\(comboMultiplier, specifier: "%.1f")x")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(comboMultiplier > 1 ? .yellow : .white)
            }
            
            // Streak
            VStack(spacing: 4) {
                Text("Streak")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                HStack(spacing: 2) {
                    if currentStreak > 0 {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                    }
                    Text("\(currentStreak)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(currentStreak > 0 ? .orange : .white)
                }
            }
            
            // Moves
            VStack(spacing: 4) {
                Text("Moves")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text("\(moves)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.top, 8)
    }
    
    private var timerBar: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(timeRemaining < 10 ? .red : .white)
                Text(timeString)
                    .font(.system(.headline, design: .monospaced))
                    .foregroundStyle(timeRemaining < 10 ? .red : .white)
                Spacer()
                Text("\(matchedPairs)/\(currentPairsToMatch) pairs")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(timerColor)
                        .frame(width: geometry.size.width * timerProgress)
                        .animation(.linear(duration: 0.5), value: timeRemaining)
                }
            }
            .frame(height: 6)
            .padding(.horizontal)
        }
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var timerProgress: CGFloat {
        let total = currentLevelConfig?.timeLimit ?? gameMode.timeLimit ?? 60
        return CGFloat(timeRemaining) / CGFloat(total)
    }
    
    private var timerColor: Color {
        if timerProgress > 0.5 { return .green }
        if timerProgress > 0.25 { return .yellow }
        return .red
    }
    
    private func achievementUnlockOverlay(_ achievement: Achievement) -> some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 50))
                .foregroundStyle(achievement.color)
            
            Text("Achievement Unlocked!")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text(achievement.name)
                .font(.title2.bold())
                .foregroundStyle(.white)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .transition(.scale.combined(with: .opacity))
    }
    
    private var levelCompleteOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("Level \(currentLevel) Complete!")
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text("Score: +\(levelScore)")
                .font(.title2)
                .foregroundStyle(.yellow)
            
            Button {
                advanceToNextLevel()
            } label: {
                Text("Next Level")
                    .font(.headline)
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(.white, in: Capsule())
            }
        }
        .padding(40)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 20)
    }
    
    // MARK: - Game Logic
    
    func setupGame() {
        if gameMode == .progressive {
            currentLevelConfig = ProgressiveLevel.forLevel(currentLevel)
        }
        
        cards = createDeck()
        timeRemaining = currentLevelConfig?.timeLimit ?? gameMode.timeLimit ?? 0
        
        if hasTimeLimit {
            startTimer()
        }
    }
    
    func choose(_ index: Int) {
        guard !isPaused else { return }
        if cards[index].isFaceUp || cards[index].isMatched { return }
        
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        #endif
        
        // Check for decoy card
        if cards[index].isDecoy {
            handleDecoyTap()
            cards[index].isFaceUp = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { cards[index].isFaceUp = false }
            }
            return
        }
        
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
        moves += 1
        
        if cards[index1].color == cards[index2].color {
            handleMatch(index1: index1, index2: index2)
        } else {
            handleMismatch(index1: index1, index2: index2)
        }
    }
    
    func handleMatch(index1: Int, index2: Int) {
        cards[index1].isMatched = true
        cards[index2].isMatched = true
        matchedPairs += 1
        
        // Track first match achievement
        achievementManager.recordMatch()
        
        // Calculate time since last match for quick match bonus
        var quickMatchBonus = 0
        if let lastMatch = lastMatchTime {
            let timeSince = Date().timeIntervalSince(lastMatch)
            if timeSince <= 3.0 {
                quickMatchBonus = ScoringConfig.quickMatchBonus
                quickMatchCount += 1
                achievementManager.recordQuickMatch()
                showBonus("+\(quickMatchBonus) Quick!")
            }
        }
        lastMatchTime = Date()
        
        // Update streak
        currentStreak += 1
        if currentStreak > maxStreak {
            maxStreak = currentStreak
        }
        
        // Calculate streak bonus
        var streakBonus = 0
        switch currentStreak {
        case 3:
            streakBonus = ScoringConfig.streak3Bonus
            showBonus("+\(streakBonus) 3x Streak!")
        case 5:
            streakBonus = ScoringConfig.streak5Bonus
            showBonus("+\(streakBonus) 5x Streak!")
        case 7:
            streakBonus = ScoringConfig.streak7Bonus
            showBonus("+\(streakBonus) 7x Streak!")
        default:
            break
        }
        
        // Update combo
        comboMultiplier = min(comboMultiplier + ScoringConfig.comboMultiplierIncrement, ScoringConfig.maxComboMultiplier)
        if comboMultiplier > maxCombo {
            maxCombo = comboMultiplier
        }
        
        // Calculate score with multipliers
        let modeMultiplier = currentLevelConfig?.scoreMultiplier ?? gameMode.scoreMultiplier
        let basePoints = Int(Double(ScoringConfig.matchPoints) * modeMultiplier * comboMultiplier)
        let totalPoints = basePoints + quickMatchBonus + streakBonus
        
        score += totalPoints
        totalBonuses += quickMatchBonus + streakBonus
        
        // Success Haptic
        #if os(iOS)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        #endif
        
        // Check for win
        if matchedPairs >= currentPairsToMatch {
            handleWin()
        }
    }
    
    func handleMismatch(index1: Int, index2: Int) {
        mistakes += 1
        
        // Reset streak and combo
        currentStreak = 0
        comboMultiplier = 1.0
        
        // Apply penalty
        let penalty = ScoringConfig.mismatchPenalty
        
        // Track if player reaches zero
        if score > 0 && score + penalty <= 0 {
            wasAtZero = true
        }
        
        score = max(0, score + penalty)
        totalPenalties += abs(penalty)
        
        showPenalty("\(penalty) Miss")
        
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
    
    func handleDecoyTap() {
        tappedDecoy = true
        let penalty = ScoringConfig.decoyTapPenalty
        score = max(0, score + penalty)
        totalPenalties += abs(penalty)
        
        showPenalty("\(penalty) Decoy!")
        
        #if os(iOS)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
        #endif
    }
    
    func handleWin() {
        stopTimer()
        
        // Calculate bonuses
        var timeBonus = 0
        var perfectBonus = 0
        var clutchBonus = 0
        
        // Time bonus
        if hasTimeLimit {
            let totalTime = currentLevelConfig?.timeLimit ?? gameMode.timeLimit ?? 60
            let percentRemaining = Double(timeRemaining) / Double(totalTime)
            
            if percentRemaining > 0.5 {
                timeBonus = ScoringConfig.speedRunBonus
                showBonus("+\(timeBonus) Speed Run!")
            } else if percentRemaining < 0.1 && percentRemaining > 0 {
                clutchBonus = ScoringConfig.clutchBonus
                showBonus("+\(clutchBonus) Clutch!")
                achievementManager.recordClutchWin()
            }
            
            // Check for clutch achievement (< 5 seconds)
            if timeRemaining > 0 && timeRemaining < 5 {
                achievementManager.recordClutchWin()
            }
        }
        
        // Perfect game bonus
        if mistakes == 0 {
            perfectBonus = ScoringConfig.perfectGameBonus
            showBonus("+\(perfectBonus) Perfect!")
        }
        
        // Comeback achievement
        if wasAtZero && score > 0 {
            achievementManager.recordComeback()
        }
        
        // Apply final bonuses
        score += timeBonus + perfectBonus + clutchBonus
        totalBonuses += timeBonus + perfectBonus + clutchBonus
        
        // Create game result
        gameResult = GameResult(
            baseScore: score - totalBonuses + totalPenalties,
            comboBonus: 0,
            streakBonus: totalBonuses - timeBonus - perfectBonus,
            timeBonus: timeBonus,
            perfectBonus: perfectBonus,
            penalties: totalPenalties,
            finalScore: score,
            maxStreak: maxStreak,
            maxCombo: maxCombo,
            mistakes: mistakes,
            timeElapsed: timeElapsed,
            level: currentLevel
        )
        
        if gameMode == .progressive {
            levelScore = score
            showLevelComplete = true
        } else {
            endGame()
        }
    }
    
    func handleTimeOut() {
        stopTimer()
        
        // Apply timeout penalty
        let penalty = ScoringConfig.timeoutPenalty
        score = max(0, score + penalty)
        totalPenalties += abs(penalty)
        
        gameResult = GameResult(
            baseScore: score - totalBonuses + totalPenalties,
            comboBonus: 0,
            streakBonus: totalBonuses,
            timeBonus: 0,
            perfectBonus: 0,
            penalties: totalPenalties,
            finalScore: score,
            maxStreak: maxStreak,
            maxCombo: maxCombo,
            mistakes: mistakes,
            timeElapsed: timeElapsed,
            level: currentLevel
        )
        
        endGame()
    }
    
    func advanceToNextLevel() {
        showLevelComplete = false
        currentLevel += 1
        currentLevelConfig = ProgressiveLevel.forLevel(currentLevel)
        
        // Reset per-level state but keep cumulative
        cards = createDeck()
        matchedPairs = 0
        firstSelectedIndex = nil
        currentStreak = 0
        comboMultiplier = 1.0
        lastMatchTime = nil
        
        timeRemaining = currentLevelConfig?.timeLimit ?? 30
        startTimer()
    }
    
    func endGame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showGameOver = true
        }
    }
    
    func saveScore() {
        ScoreManager.shared.saveScore(
            score: score,
            name: playerName,
            gameMode: gameMode,
            timeElapsed: timeElapsed,
            moves: moves,
            mistakes: mistakes,
            maxStreak: maxStreak,
            maxCombo: maxCombo,
            level: currentLevel,
            bonuses: totalBonuses,
            penalties: totalPenalties
        )
        
        // Record game completion for achievements
        achievementManager.recordGameCompletion(
            mode: gameMode,
            score: score,
            time: timeElapsed,
            moves: moves,
            mistakes: mistakes,
            maxStreak: maxStreak,
            maxCombo: maxCombo,
            level: currentLevel,
            tappedDecoy: tappedDecoy
        )
    }
    
    func saveScoreAndRestart() {
        saveScore()
        restartGame()
    }
    
    func restartGame() {
        stopTimer()
        
        // Reset all state
        cards = []
        firstSelectedIndex = nil
        score = 0
        moves = 0
        matchedPairs = 0
        mistakes = 0
        playerName = ""
        currentStreak = 0
        maxStreak = 0
        comboMultiplier = 1.0
        maxCombo = 1.0
        totalBonuses = 0
        totalPenalties = 0
        quickMatchCount = 0
        tappedDecoy = false
        wasAtZero = false
        lastMatchTime = nil
        timeElapsed = 0
        gameResult = nil
        
        if gameMode == .progressive {
            currentLevel = 1
            currentLevelConfig = ProgressiveLevel.forLevel(1)
        }
        
        setupGame()
    }
    
    // MARK: - Timer
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isPaused {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    timeElapsed += 1
                } else {
                    handleTimeOut()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Helpers
    
    func createDeck() -> [Card] {
        let cols = currentLevelConfig?.columns ?? gameMode.columns
        let pairs = currentLevelConfig?.pairsToMatch ?? gameMode.pairsToMatch
        let totalCards = cols * cols
        
        // Extended color palette for larger grids
        let allColors: [Color] = [
            .cyan, .mint, .orange, .pink, .red, .green, .blue, .yellow,
            .purple, .teal, .indigo, .brown,
            Color(red: 1, green: 0.5, blue: 0),      // Deep orange
            Color(red: 0.5, green: 0, blue: 0.5),    // Dark purple
            Color(red: 0, green: 0.5, blue: 0.5),    // Dark teal
            Color(red: 0.8, green: 0.2, blue: 0.2),  // Crimson
            Color(red: 0.2, green: 0.6, blue: 0.2),  // Forest green
            Color(red: 0.4, green: 0.4, blue: 0.8),  // Periwinkle
            Color(red: 0.9, green: 0.7, blue: 0.1),  // Gold
            Color(red: 0.6, green: 0.3, blue: 0.1),  // Sienna
            Color(red: 0.1, green: 0.5, blue: 0.7),  // Steel blue
            Color(red: 0.7, green: 0.2, blue: 0.5),  // Magenta
            Color(red: 0.3, green: 0.7, blue: 0.3),  // Lime
            Color(red: 0.5, green: 0.3, blue: 0.7),  // Violet
        ]
        
        let colors = Array(allColors.prefix(pairs))
        var deck = colors + colors  // Create pairs
        
        // Add decoy card(s) to fill the grid
        let decoysNeeded = totalCards - (pairs * 2)
        for _ in 0..<decoysNeeded {
            deck.append(.white)
        }
        
        deck.shuffle()
        
        return deck.map { color in
            var card = Card(color: color)
            if color == .white {
                card.isDecoy = true
            }
            return card
        }
    }
    
    func showBonus(_ text: String) {
        withAnimation(.spring()) {
            showBonusText = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showBonusText = nil
            }
        }
    }
    
    func showPenalty(_ text: String) {
        withAnimation(.spring()) {
            showPenaltyText = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showPenaltyText = nil
            }
        }
    }
    
    func gameOverMessage(_ result: GameResult) -> String {
        var message = "Final Score: \(result.finalScore)\n"
        message += "Time: \(result.timeElapsed)s • Moves: \(moves)\n"
        
        if result.maxStreak > 1 {
            message += "Best Streak: \(result.maxStreak) 🔥\n"
        }
        
        if result.maxCombo > 1 {
            message += "Max Combo: \(String(format: "%.1f", result.maxCombo))x\n"
        }
        
        if result.mistakes == 0 {
            message += "⭐ Perfect Game!\n"
        }
        
        if gameMode == .progressive {
            message += "Level Reached: \(result.level)\n"
        }
        
        message += "\nEnter your name to save."
        return message
    }
}

#Preview {
    NavigationStack {
        GameView(gameMode: .classic3x3)
    }
}
