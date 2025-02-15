import SwiftUI
import CoreHaptics
import AVFoundation

// Haptics Manager to handle continuous feedback
class HapticsManager: ObservableObject {
    private var engine: CHHapticEngine?
    private var player: CHHapticPatternPlayer?
    private var timer: Timer?
    
    init() {
        setupHaptics()
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { 
            print("Device doesn't support haptics")
            return 
        }
        
        do {
            engine = try CHHapticEngine()
            
            engine?.resetHandler = { [weak self] in
                print("Resetting engine")
                self?.setupHaptics()
            }
            
            engine?.stoppedHandler = { reason in
                print("Engine stopped: \(reason)")
            }
            
            try engine?.start()
        } catch {
            print("Haptics error: \(error)")
        }
    }
    
    func startContinuousHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        stopHaptics()
        
        do {
            try engine?.start()
            
            // Create a heartbeat pattern
            var events = [CHHapticEvent]()
            
            // First beat (stronger)
            let strongIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let strongSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            let strongBeat = CHHapticEvent(eventType: .hapticTransient,
                                         parameters: [strongIntensity, strongSharpness],
                                         relativeTime: 0)
            
            // Quick follow-up beat (weaker)
            let weakIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
            let weakSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let weakBeat = CHHapticEvent(eventType: .hapticTransient,
                                       parameters: [weakIntensity, weakSharpness],
                                       relativeTime: 0.1)
            
            events.append(strongBeat)
            events.append(weakBeat)
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            player = try engine?.makePlayer(with: pattern)
            
            // Play the heartbeat pattern repeatedly
            timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                do {
                    try self.player?.start(atTime: 0)
                } catch {
                    print("Failed to play pattern: \(error)")
                    self.timer?.invalidate()
                }
            }
            
            // Start immediately
            try player?.start(atTime: 0)
            
        } catch {
            print("Failed to create haptic pattern: \(error)")
        }
    }
    
    func stopHaptics() {
        timer?.invalidate()
        timer = nil
        
        if let player = player {
            do {
                try player.stop(atTime: 0)
            } catch {
                print("Failed to stop haptic player: \(error)")
            }
        }
        player = nil
    }
    
    deinit {
        stopHaptics()
    }
}

// Audio Manager to handle background music
class AudioManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        setupAudio()
        prepareWelcomeTone()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func prepareWelcomeTone() {
        // Generate welcome tone if it doesn't exist
        if let audioURL = WelcomeToneGenerator.generateTone() {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Failed to prepare welcome tone: \(error)")
            }
        }
    }
    
    func startBackgroundMusic() {
        guard let player = audioPlayer else {
            print("Audio player not ready")
            return
        }
        
        player.numberOfLoops = -1 // Loop indefinitely
        player.volume = 0 // Start with volume 0 for fade-in
        player.play()
        
        // Fade in
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let player = self?.audioPlayer else {
                timer.invalidate()
                return
            }
            
            if player.volume < 0.7 {
                player.volume += 0.02
            } else {
                timer.invalidate()
            }
        }
    }
    
    func stopBackgroundMusic() {
        // Fade out
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let player = self?.audioPlayer else {
                timer.invalidate()
                return
            }
            
            if player.volume > 0 {
                player.volume -= 0.02
            } else {
                timer.invalidate()
                player.stop()
                self?.audioPlayer = nil
            }
        }
    }
}

struct WelcomeScreen: View {
    @Binding var hasSeenWelcome: Bool
    @StateObject private var hapticsManager = HapticsManager()
    @StateObject private var audioManager = AudioManager()
    @State private var welcomeOpacity: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var currentScreen = 0 // 0: Welcome, 1: One Place For, 2: Students, 3: And, 4: Teachers, 5: Get Started
    @State private var textOpacity: Double = 0
    @State private var backgroundColorOpacity: Double = 1
    @State private var glowEffect: Bool = false
    @State private var scanlineOffset: CGFloat = 1000
    @State private var welcomeTextOffset: CGFloat = 50
    
    var body: some View {
        ZStack {
            // Background Colors
            Color.black
                .opacity(backgroundColorOpacity)
                .ignoresSafeArea()
            
            // Scanline effect for first screen
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.2),
                            .clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 2)
                .offset(y: scanlineOffset)
                .opacity(currentScreen == 0 ? 1 : 0)
            
            Color.white
                .opacity(1 - backgroundColorOpacity)
                .ignoresSafeArea()
            
            // Welcome Screen
            if currentScreen == 0 {
                Text("Welcome")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(welcomeOpacity)
                    .scaleEffect(scale)
                    .offset(y: welcomeTextOffset)
                    .shadow(color: .white.opacity(0.5), radius: 20)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowEffect)
            }
            
            // One Place For Screen
            if currentScreen == 1 {
                VStack(spacing: 10) {
                    Text("One")
                        .font(.system(size: 46, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Place for")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                .opacity(textOpacity)
                .scaleEffect(scale)
            }
            
            // Students Screen
            if currentScreen == 2 {
                studentsText
                    .opacity(textOpacity)
                    .scaleEffect(scale)
            }
            
            // And Screen
            if currentScreen == 3 {
                Text("and")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                    .scaleEffect(scale)
            }
            
            // Teachers Screen
            if currentScreen == 4 {
                teachersText
                    .opacity(textOpacity)
                    .scaleEffect(scale)
            }
            
            // Get Started Screen
            if currentScreen == 5 {
                Button(action: {
                    hapticsManager.stopHaptics()
                    audioManager.stopBackgroundMusic()
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasSeenWelcome = true
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: "006400")) // Dark green
                                .shadow(color: Color(hex: "006400").opacity(0.5), radius: 10)
                        )
                }
                .opacity(textOpacity)
                .scaleEffect(scale)
            }
        }
        .onAppear {
            startWelcomeSequence()
        }
        .onChange(of: currentScreen) { oldValue, newValue in
            // Restart haptics for each screen transition
            hapticsManager.stopHaptics()
            hapticsManager.startContinuousHaptics()
        }
        .onDisappear {
            audioManager.stopBackgroundMusic()
            hapticsManager.stopHaptics()
        }
    }
    
    private func startWelcomeSequence() {
        // Start audio and haptic feedback
        audioManager.startBackgroundMusic()
        hapticsManager.startContinuousHaptics()
        
        // Welcome animation
        withAnimation(.easeOut(duration: 1.5)) {
            welcomeOpacity = 1
            scale = 1
        }
        
        // Scanline animation
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            scanlineOffset = -1000
        }
        
        // Welcome text floating animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            welcomeTextOffset = -20
        }
        
        withAnimation {
            glowEffect = true
        }
        
        // Updated sequence timing
        let transitions = [
            (2.0, { // To "One Place for"
                self.transitionToNextScreen(1)
            }),
            (2.0, { // To "Students"
                self.transitionToNextScreen(2)
            }),
            (2.0, { // To "and"
                self.transitionToNextScreen(3)
            }),
            (2.0, { // To "Teachers"
                self.transitionToNextScreen(4)
            }),
            (2.0, { // To Get Started
                self.transitionToNextScreen(5)
            })
        ]
        
        var totalDelay: Double = 3.0
        
        for (duration, transition) in transitions {
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
                transition()
            }
            totalDelay += duration
        }
    }
    
    private func transitionToNextScreen(_ screen: Int) {
        withAnimation(.easeOut(duration: 0.6)) {
            textOpacity = 0
            scale = 0.8
        }
        
        withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
            currentScreen = screen
            if screen == 1 {
                backgroundColorOpacity = 1
            }
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.5)) {
            textOpacity = 1
            scale = 1
        }
    }
    
    // Update the Students text to white
    private var studentsText: some View {
        HStack(spacing: 0) {
            Text("S")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("tudents")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    // Update the Teachers text to white
    private var teachersText: some View {
        HStack(spacing: 0) {
            Text("T")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text("eachers")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// Preview provider for development
struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(hasSeenWelcome: .constant(false))
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 