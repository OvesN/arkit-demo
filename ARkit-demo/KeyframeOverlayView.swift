import SwiftUI

struct KeyframeOverlayView: View {
    @ObservedObject var matcher: KeyframeMatcher
    let matchResult: KeyframeMatchResult?
    
    var body: some View {
        VStack {
            // Top HUD
            HStack(alignment: .top) {
                // Rep Counter
                StatBox(title: "REPS", value:  "\(matcher.repCount)")
                
                Spacer()
                
                // Form Score
                ScoreCircle(score: matcher.formScore)
            }
            . padding()
            
            Spacer()
            
            // Center - State/Keyframe indicator
            if matcher.exerciseState == .idle || matcher.exerciseState == .preparingStart {
                StartPositionGuide(state:  matcher.exerciseState)
            } else if let keyframe = matcher.currentKeyframe {
                KeyframeIndicator(
                    keyframe: keyframe,
                    matchResult: matchResult,
                    progress: matcher.progress
                )
            }
            
            Spacer()
            
            // Bottom - Angle readings and feedback
            VStack(spacing:  12) {
                // Current angles display
                if !matcher.currentAngles.isEmpty {
                    AngleReadingsView(
                        angles: matcher.currentAngles,
                        targetAngles: matcher.currentKeyframe?.targetAngles ?? [:]
                    )
                }
                
                // Feedback bar
                FeedbackBar(
                    message: matcher.feedback,
                    state: matcher.exerciseState,
                    score: matchResult?.overallScore
                )
            }
            .padding()
        }
    }
}

// MARK: - Subviews

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 32, weight:  .bold, design: .rounded))
        }
        .padding()
        .background(. ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct ScoreCircle: View {
    let score: Double
    
    var color: Color {
        if score >= 80 { return .green }
        if score >= 60 { return . yellow }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("FORM")
                .font(.caption)
                .foregroundColor(.gray)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 6)
                
                Circle()
                    .trim(from: 0, to:  score / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(score))%")
                    .font(. system(size: 18, weight: .bold, design: .rounded))
            }
            .frame(width: 70, height:  70)
        }
        .padding()
        .background(. ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct StartPositionGuide: View {
    let state: KeyframeMatcher.KeyframeExerciseState
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: state == .preparingStart ? "figure.arms.open" : "figure.stand")
                .font(.system(size: 80))
                .foregroundColor(state == .preparingStart ?  .green : .gray)
            
            Text(state.displayText)
                .font(.title2)
                .fontWeight(.medium)
            
            if state == .preparingStart {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
}

struct KeyframeIndicator: View {
    let keyframe: Keyframe
    let matchResult: KeyframeMatchResult?
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index <= Int(progress * 4) ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }
            
            // Current keyframe name
            Text(keyframe.name)
                .font(.headline)
            
            // Match score
            if let result = matchResult {
                HStack {
                    Image(systemName: result.isMatched ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(result.isMatched ? .green :  .orange)
                    Text("\(result.percentage)%")
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

struct AngleReadingsView: View {
    let angles: [String:  Double]
    let targetAngles: [String: Double]
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(Array(angles.keys.sorted()), id: \.self) { angleId in
                if let current = angles[angleId] {
                    let target = targetAngles[angleId]
                    AngleReading(
                        name: angleId.replacingOccurrences(of: "_", with: " ").capitalized,
                        current: current,
                        target: target
                    )
                }
            }
        }
    }
}

struct AngleReading: View {
    let name: String
    let current: Double
    let target: Double?
    
    var isGood: Bool {
        guard let target = target else { return true }
        return abs(current - target) <= 15
    }
    
    var body:  some View {
        VStack(spacing: 4) {
            Text(name)
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text("\(Int(current))°")
                .font(. system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(isGood ? .green : . orange)
            
            if let target = target {
                Text("→ \(Int(target))°")
                    .font(. caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(. horizontal, 12)
        .padding(.vertical, 8)
        .background(isGood ?  Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FeedbackBar: View {
    let message:  String
    let state: KeyframeMatcher.KeyframeExerciseState
    let score: Double?
    
    var backgroundColor:  Color {
        switch state {
        case .ready, .repCompleted:
            return .green.opacity(0.2)
        case . inProgress, .holdingKeyframe:
            if let score = score, score >= 0.7 {
                return .green.opacity(0.2)
            }
            return .orange.opacity(0.2)
        default:
            return .gray.opacity(0.2)
        }
    }
    
    var body: some View {
        Text(message)
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        
        KeyframeOverlayView(
            matcher: KeyframeMatcher(isRightArm: true),
            matchResult: nil
        )
    }
}
