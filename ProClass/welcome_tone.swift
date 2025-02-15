import Foundation
import AVFoundation

class WelcomeToneGenerator {
    static func generateTone() -> URL? {
        // Create a more pleasant welcome tone
        let duration: Double = 5.0 // 5 seconds
        let sampleRate: Double = 44100.0
        
        // Get the documents directory path
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileURL = documentsPath.appendingPathComponent("welcome_music.wav")
        
        // Audio file settings
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        do {
            // Remove existing file if it exists
            try? FileManager.default.removeItem(at: audioFileURL)
            
            let audioFile = try AVAudioFile(
                forWriting: audioFileURL,
                settings: settings,
                commonFormat: .pcmFormatFloat32,
                interleaved: false
            )
            
            let format = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: sampleRate,
                channels: 2,
                interleaved: false
            )!
            
            let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(sampleRate * duration)
            )!
            
            // Generate a more complex chord progression
            let chordProgression: [(frequencies: [Double], duration: Double)] = [
                ([440.0, 554.37, 659.25], 1.0),     // A major (A4, C#5, E5)
                ([493.88, 587.33, 739.99], 1.0),    // B minor (B4, D5, F#5)
                ([523.25, 659.25, 783.99], 1.0),    // C major (C5, E5, G5)
                ([587.33, 739.99, 880.00], 1.0),    // D major (D5, F#5, A5)
                ([440.0, 554.37, 659.25], 1.0)      // Back to A major
            ]
            
            for frame in 0..<Int(sampleRate * duration) {
                let time = Double(frame) / sampleRate
                var sample: Float = 0.0
                
                // Determine which chord to play
                let totalChordDuration = chordProgression.reduce(0) { $0 + $1.duration }
                let currentTime = time.truncatingRemainder(dividingBy: totalChordDuration)
                
                var elapsedTime = 0.0
                var currentChord = chordProgression[0].frequencies
                
                for (frequencies, chordDuration) in chordProgression {
                    if currentTime >= elapsedTime && currentTime < elapsedTime + chordDuration {
                        currentChord = frequencies
                        break
                    }
                    elapsedTime += chordDuration
                }
                
                // Create a more complex waveform for each note
                for frequency in currentChord {
                    // Main frequency
                    let main = sin(2.0 * .pi * frequency * time)
                    // Add harmonics
                    let harmonic1 = 0.5 * sin(4.0 * .pi * frequency * time)
                    let harmonic2 = 0.25 * sin(6.0 * .pi * frequency * time)
                    
                    // Combine waveforms with envelope
                    let fadeIn = min(time / 0.1, 1.0)
                    let fadeOut = min((duration - time) / 0.1, 1.0)
                    let fade = min(fadeIn, fadeOut)
                    
                    sample += Float((main + harmonic1 + harmonic2) * 0.2 * fade)
                }
                
                // Apply to both channels with soft clipping
                let clippedSample = tanh(sample) * 0.7
                buffer.floatChannelData?[0][frame] = clippedSample
                buffer.floatChannelData?[1][frame] = clippedSample
            }
            
            buffer.frameLength = AVAudioFrameCount(sampleRate * duration)
            
            // Write the buffer to the file
            try audioFile.write(from: buffer)
            
            print("Welcome tone generated at: \(audioFileURL)")
            return audioFileURL
            
        } catch {
            print("Error generating welcome tone: \(error)")
            return nil
        }
    }
} 