import Foundation
import simd

// MARK: - Joint Identifiers

/// Universal joint identifiers that work with both ARKit and MediaPipe
enum UniversalJoint: String, CaseIterable {
    // Upper body
    case leftShoulder
    case rightShoulder
    case leftElbow
    case rightElbow
    case leftWrist
    case rightWrist
    
    // Torso
    case leftHip
    case rightHip
    
    // For normalization
    case hipCenter
    case shoulderCenter
    
    /// MediaPipe landmark index
    var mediaPipeIndex: Int?  {
        switch self {
        case . leftShoulder: return 11
        case .rightShoulder: return 12
        case .leftElbow: return 13
        case .rightElbow: return 14
        case .leftWrist: return 15
        case .rightWrist: return 16
        case . leftHip: return 23
        case .rightHip: return 24
        case . hipCenter: return nil
        case .shoulderCenter: return nil
        }
    }
    
    /// ARKit joint name
    var arKitJointName: String?  {
        switch self {
        case . leftShoulder: return "left_shoulder_1_joint"
        case .rightShoulder: return "right_shoulder_1_joint"
        case . leftElbow: return "left_forearm_joint"
        case . rightElbow: return "right_forearm_joint"
        case .leftWrist: return "left_hand_joint"
        case . rightWrist: return "right_hand_joint"
        case .leftHip: return "left_upLeg_joint"
        case .rightHip: return "right_upLeg_joint"
        case . hipCenter: return "hips_joint"
        case . shoulderCenter: return nil
        }
    }
}


/// Defines an angle by three joints (vertex is the middle joint)
struct AngleDefinition: Codable, Identifiable {
    let id: String
    let name: String
    let jointA: String      // First joint
    let jointB: String      // Vertex (where angle is measured)
    let jointC: String      // Third joint
    let weight: Double      // Importance weight (0-1)
    
    init(id: String, name: String, jointA: UniversalJoint, jointB: UniversalJoint, jointC: UniversalJoint, weight: Double = 1.0) {
        self.id = id
        self.name = name
        self.jointA = jointA.rawValue
        self.jointB = jointB.rawValue
        self.jointC = jointC.rawValue
        self.weight = weight
    }
}


/// A single keyframe representing a critical position in an exercise
struct Keyframe: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let orderIndex: Int                     // Order in the exercise sequence
    let targetAngles: [String: Double]      // AngleDefinition. id -> target angle in degrees
    let tolerances: [String: Double]        // AngleDefinition.id -> acceptable deviation
    let holdDuration: Double?                // Optional: how long to hold (seconds)
    let transitionHint: String?             // Hint for transitioning to next keyframe
    
    /// Check if a set of angles matches this keyframe
    func matches(angles: [String: Double], threshold: Double = 0.7) -> KeyframeMatchResult {
        var totalScore = 0.0
        var totalWeight = 0.0
        var angleScores: [String: AngleMatchScore] = [:]
        
        for (angleId, targetAngle) in targetAngles {
            guard let currentAngle = angles[angleId] else { continue }
            
            let tolerance = tolerances[angleId] ?? 15.0
            let deviation = abs(currentAngle - targetAngle)
            
            // Calculate score (1.0 = perfect, 0.0 = outside tolerance)
            let score: Double
            if deviation <= tolerance {
                score = 1.0 - (deviation / tolerance) * 0.3  // 70-100% within tolerance
            } else if deviation <= tolerance * 2 {
                score = 0.7 - ((deviation - tolerance) / tolerance) * 0.4  // 30-70% near tolerance
            } else {
                score = max(0, 0.3 - ((deviation - tolerance * 2) / tolerance) * 0.3)  // 0-30% far
            }
            
            angleScores[angleId] = AngleMatchScore(
                angleId: angleId,
                currentAngle: currentAngle,
                targetAngle: targetAngle,
                tolerance: tolerance,
                deviation: deviation,
                score: score
            )
            
            // Weight the score (assuming weight is stored or default to 1.0)
            let weight = 1.0
            totalScore += score * weight
            totalWeight += weight  // Changed from Int(weight) to weight
        }
        
        let overallScore = totalWeight > 0 ?  totalScore / totalWeight : 0.0  // Changed to Double calculation
        let isMatched = overallScore >= threshold
        
        return KeyframeMatchResult(
            keyframe: self,
            isMatched: isMatched,
            overallScore: overallScore,
            angleScores:  angleScores,
            timestamp:  Date()
        )
    }
}


struct AngleMatchScore: Codable {
    let angleId: String
    let currentAngle: Double
    let targetAngle: Double
    let tolerance: Double
    let deviation: Double
    let score: Double           // 0-1
    
    var isWithinTolerance: Bool {
        deviation <= tolerance
    }
    
    var feedbackMessage: String {
        if isWithinTolerance {
            return "Good!"
        } else if currentAngle < targetAngle {
            return "Increase angle by \(Int(deviation))°"
        } else {
            return "Decrease angle by \(Int(deviation))°"
        }
    }
}

struct KeyframeMatchResult {
    let keyframe: Keyframe
    let isMatched: Bool
    let overallScore: Double    // 0-1
    let angleScores: [String: AngleMatchScore]
    let timestamp: Date
    
    var percentage: Int {
        Int(overallScore * 100)
    }
    
    var worstAngle: AngleMatchScore?  {
        angleScores.values.min { $0.score < $1.score }
    }
    
    var feedback: String {
        if isMatched {
            return "\(keyframe.name) - Perfect!"
        } else if let worst = worstAngle {
            return " \(worst.feedbackMessage)"
        } else {
            return "Adjust your position"
        }
    }
}

// MARK: - Exercise Definition

/// Complete exercise definition with all keyframes
struct ExerciseDefinition: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let angleDefinitions: [AngleDefinition]
    let keyframes: [Keyframe]
    let repPattern: [String]    // Keyframe IDs in order for one rep
    
    /// Get angle definition by ID
    func angleDefinition(id: String) -> AngleDefinition? {
        angleDefinitions.first { $0.id == id }
    }
    
    /// Get keyframe by ID
    func keyframe(id: String) -> Keyframe? {
        keyframes.first { $0.id == id }
    }
}
