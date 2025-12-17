import Foundation
import Combine
import simd



/// Protocol for pose data from any source (ARKit or MediaPipe)
protocol PoseData {
    func jointPosition(for joint: UniversalJoint) -> CGPoint?
    func jointPosition3D(for joint: UniversalJoint) -> SIMD3<Float>?
    var confidence: Float { get }
    var timestamp: TimeInterval { get }
}



/// Main engine for keyframe matching
class KeyframeMatcher: ObservableObject {


    @Published var currentKeyframeIndex: Int = 0
    @Published var lastMatchResult: KeyframeMatchResult?
    @Published var repCount: Int = 0
    @Published var currentAngles: [String: Double] = [:]
    @Published var exerciseState: KeyframeExerciseState = .idle
    @Published var formScore: Double = 100.0
    @Published var feedback: String = "Get ready"
    
    
    private let exercise: ExerciseDefinition
    private var keyframeHistory: [KeyframeMatchResult] = []
    private var repScores: [Double] = []
    private var matchThreshold: Double = 0.7
    private var stableFrameCount: Int = 0
    private let stableFramesRequired: Int = 5
    
    // Timing
    private var keyframeEntryTime: Date?
    private var lastPoseTime: Date = Date()
    

    
    enum KeyframeExerciseState {
        case idle               // Not started
        case preparingStart     // Getting into start position
        case ready              // In start position, ready to begin
        case inProgress         // Performing exercise
        case betweenKeyframes   // Transitioning between keyframes
        case holdingKeyframe    // Holding a keyframe (if required)
        case repCompleted       // Just finished a rep
        case paused             // Exercise paused
        
        var displayText: String {
            switch self {
            case .idle: return "Get in starting position"
            case .preparingStart: return "Almost there..."
            case .ready: return "Ready!  Start your curl"
            case . inProgress: return "Keep going!"
            case .betweenKeyframes: return "Transitioning..."
            case .holdingKeyframe: return "Hold..."
            case .repCompleted: return "Rep complete!"
            case .paused: return "Paused"
            }
        }
    }
    
    // MARK: - Initialization
    
    init(exercise: ExerciseDefinition) {
        self.exercise = exercise
    }
    
    convenience init(isRightArm: Bool = true) {
        let exercise = BicepCurlExerciseFactory.create(isRightArm: isRightArm)
        self.init(exercise: exercise)
    }
    
    // MARK: - Main Update Method
    
    /// Process new pose data and update keyframe matching
    func update(with pose: PoseData) -> KeyframeMatchResult?  {
        lastPoseTime = Date()
        
        // Calculate all angles from pose
        let angles = calculateAngles(from: pose)
        currentAngles = angles
        
        // Get current target keyframe
        guard currentKeyframeIndex < exercise.keyframes.count else {
            return nil
        }
        
        let currentKeyframe = exercise.keyframes[currentKeyframeIndex]
        
        // Check if we match the current keyframe
        let matchResult = currentKeyframe.matches(angles: angles, threshold: matchThreshold)
        lastMatchResult = matchResult
        
        // Update state based on match
        updateState(matchResult: matchResult, keyframe: currentKeyframe)
        
        // Update feedback
        updateFeedback(matchResult: matchResult)
        
        return matchResult
    }
    
    // MARK: - Angle Calculation
    
    private func calculateAngles(from pose: PoseData) -> [String: Double] {
        var angles: [String: Double] = [:]
        
        for angleDef in exercise.angleDefinitions {
            guard let jointA = UniversalJoint(rawValue: angleDef.jointA),
                  let jointB = UniversalJoint(rawValue: angleDef.jointB),
                  let jointC = UniversalJoint(rawValue: angleDef.jointC) else {
                continue
            }
            
            // Try 3D first (ARKit), fall back to 2D (MediaPipe)
            if let posA = pose.jointPosition3D(for: jointA),
               let posB = pose.jointPosition3D(for: jointB),
               let posC = pose.jointPosition3D(for: jointC) {
                angles[angleDef.id] = calculateAngle3D(a: posA, b: posB, c: posC)
            } else if let posA = pose.jointPosition(for: jointA),
                      let posB = pose.jointPosition(for: jointB),
                      let posC = pose.jointPosition(for: jointC) {
                angles[angleDef.id] = calculateAngle2D(a: posA, b: posB, c: posC)
            }
        }
        
        return angles
    }
    
    private func calculateAngle2D(a: CGPoint, b: CGPoint, c: CGPoint) -> Double {
        let vectorBA = CGPoint(x: a.x - b.x, y: a.y - b.y)
        let vectorBC = CGPoint(x: c.x - b.x, y: c.y - b.y)
        
        let dotProduct = vectorBA.x * vectorBC.x + vectorBA.y * vectorBC.y
        let magnitudeBA = sqrt(vectorBA.x * vectorBA.x + vectorBA.y * vectorBA.y)
        let magnitudeBC = sqrt(vectorBC.x * vectorBC.x + vectorBC.y * vectorBC.y)
        
        guard magnitudeBA > 0, magnitudeBC > 0 else { return 0 }
        
        let cosAngle = max(-1, min(1, dotProduct / (magnitudeBA * magnitudeBC)))
        return acos(cosAngle) * 180 / .pi
    }
    
    private func calculateAngle3D(a: SIMD3<Float>, b: SIMD3<Float>, c: SIMD3<Float>) -> Double {
        let vectorBA = a - b
        let vectorBC = c - b
        
        let dotProduct = simd_dot(vectorBA, vectorBC)
        let magnitudeBA = simd_length(vectorBA)
        let magnitudeBC = simd_length(vectorBC)
        
        guard magnitudeBA > 0, magnitudeBC > 0 else { return 0 }
        
        let cosAngle = max(-1, min(1, dotProduct / (magnitudeBA * magnitudeBC)))
        return Double(acos(cosAngle)) * 180 / .pi
    }
    
    // MARK: - State Management
    
    private func updateState(matchResult: KeyframeMatchResult, keyframe: Keyframe) {
        switch exerciseState {
        case .idle, .preparingStart:
            // Looking for start position
            if currentKeyframeIndex == 0 && matchResult.isMatched {
                stableFrameCount += 1
                if stableFrameCount >= stableFramesRequired {
                    exerciseState = .ready
                    stableFrameCount = 0
                } else {
                    exerciseState = .preparingStart
                }
            } else {
                stableFrameCount = 0
                exerciseState = . idle
            }
            
        case .ready:
            // Waiting for user to start moving (leave start position)
            if !matchResult.isMatched && currentKeyframeIndex == 0 {
                // User started moving - advance to next keyframe
                advanceToNextKeyframe()
                exerciseState = .inProgress
            }
            
        case . inProgress, .betweenKeyframes:
            if matchResult.isMatched {
                stableFrameCount += 1
                
                if stableFrameCount >= stableFramesRequired {
                    // Successfully reached keyframe
                    keyframeHistory.append(matchResult)
                    keyframeEntryTime = Date()
                    
                    // Check if keyframe requires holding
                    if let holdDuration = keyframe.holdDuration, holdDuration > 0 {
                        exerciseState = .holdingKeyframe
                    } else {
                        advanceToNextKeyframe()
                    }
                    stableFrameCount = 0
                }
            } else {
                stableFrameCount = 0
                exerciseState = .betweenKeyframes
            }
            
        case .holdingKeyframe:
            // Check if still in position
            if matchResult.isMatched {
                if let entryTime = keyframeEntryTime,
                   let holdDuration = keyframe.holdDuration {
                    let elapsed = Date().timeIntervalSince(entryTime)
                    if elapsed >= holdDuration {
                        advanceToNextKeyframe()
                    }
                }
            } else {
                // Lost position during hold
                exerciseState = .inProgress
                keyframeEntryTime = nil
            }
            
        case .repCompleted:
            // Brief state after completing rep
            exerciseState = .inProgress
            
        case .paused:
            // Do nothing until resumed
            break
        }
    }
    
    private func advanceToNextKeyframe() {
        currentKeyframeIndex += 1
        
        // Check if rep is complete
        if currentKeyframeIndex >= exercise.repPattern.count {
            completeRep()
        } else {
            exerciseState = .inProgress
        }
    }
    
    private func completeRep() {
        repCount += 1
        
        // Calculate rep score from keyframe history
        let repScore = calculateRepScore()
        repScores.append(repScore)
        formScore = repScore
        
        // Reset for next rep
        currentKeyframeIndex = 0
        keyframeHistory.removeAll()
        exerciseState = .repCompleted
        
        // Brief delay then back to looking for start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.exerciseState = .ready
        }
    }
    
    private func calculateRepScore() -> Double {
        guard !keyframeHistory.isEmpty else { return 0 }
        
        let totalScore = keyframeHistory.reduce(0.0) { $0 + $1.overallScore }
        return (totalScore / Double(keyframeHistory.count)) * 100
    }
    
    // MARK: - Feedback
    
    private func updateFeedback(matchResult: KeyframeMatchResult) {
        switch exerciseState {
        case .idle:
            feedback = "Get into starting position - arm extended"
            
        case .preparingStart:
            feedback = "Almost there... hold steady"
            
        case .ready:
            feedback = "Perfect! Start curling when ready"
            
        case .inProgress, .betweenKeyframes:
            if let worst = matchResult.worstAngle, !matchResult.isMatched {
                feedback = worst.feedbackMessage
            } else if let hint = exercise.keyframes[safe: currentKeyframeIndex]?.transitionHint {
                feedback = hint
            } else {
                feedback = "Keep going!"
            }
            
        case .holdingKeyframe:
            feedback = "Hold this position..."
            
        case .repCompleted:
            feedback = "Rep \(repCount) complete! Score: \(Int(formScore))%"
            
        case .paused:
            feedback = "Paused - resume when ready"
        }
    }
    
    // MARK: - Control Methods
    
    func reset() {
        currentKeyframeIndex = 0
        repCount = 0
        formScore = 100.0
        exerciseState = .idle
        keyframeHistory.removeAll()
        repScores.removeAll()
        stableFrameCount = 0
        feedback = "Get ready"
    }
    
    func pause() {
        exerciseState = .paused
    }
    
    func resume() {
        exerciseState = .inProgress
    }
    
    // MARK: - Statistics
    
    var averageScore: Double {
        guard !repScores.isEmpty else { return 0 }
        return repScores.reduce(0, +) / Double(repScores.count)
    }
    
    var currentKeyframe: Keyframe?  {
        exercise.keyframes[safe: currentKeyframeIndex]
    }
    
    var progress: Double {
        Double(currentKeyframeIndex) / Double(exercise.keyframes.count)
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
