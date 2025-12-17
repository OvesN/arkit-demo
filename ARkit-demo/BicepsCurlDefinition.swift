import Foundation


struct BicepCurlExerciseFactory {
    
 
    static func create(isRightArm: Bool = true) -> ExerciseDefinition {
        
        // Define which arm we're tracking
        let shoulder: UniversalJoint = isRightArm ? .rightShoulder : .leftShoulder
        let elbow: UniversalJoint = isRightArm ?  .rightElbow : .leftElbow
        let wrist: UniversalJoint = isRightArm ? .rightWrist : .leftWrist
        let hip: UniversalJoint = isRightArm ? . rightHip : . leftHip
        
        let armSide = isRightArm ? "Right" : "Left"
        
        // MARK: - Angle Definitions
        
        let angleDefinitions: [AngleDefinition] = [
            // Primary: Elbow flexion angle
            AngleDefinition(
                id: "elbow_flexion",
                name: "\(armSide) Elbow Angle",
                jointA: shoulder,
                jointB: elbow,
                jointC: wrist,
                weight: 1.0
            ),
            
            // Secondary: Shoulder angle (should stay relatively stable)
            AngleDefinition(
                id: "shoulder_angle",
                name: "\(armSide) Shoulder Angle",
                jointA: hip,
                jointB: shoulder,
                jointC: elbow,
                weight: 0.6
            ),
            
            // Tertiary: Upper arm alignment (elbow shouldn't drift forward)
            AngleDefinition(
                id: "upper_arm_vertical",
                name: "Upper Arm Position",
                jointA: shoulder,
                jointB: elbow,
                jointC: hip,
                weight: 0.4
            )
        ]
        
        // MARK: - Keyframes
        
        let keyframes: [Keyframe] = [
            // Keyframe 1: Starting Position (arm fully extended)
            Keyframe(
                id: "start_position",
                name: "Starting Position",
                description: "Arm fully extended at your side",
                orderIndex: 0,
                targetAngles: [
                    "elbow_flexion": 170.0,     // Nearly straight arm
                    "shoulder_angle": 15.0,     // Arm close to body
                    "upper_arm_vertical": 170.0 // Upper arm vertical
                ],
                tolerances: [
                    "elbow_flexion": 15.0,
                    "shoulder_angle": 10.0,
                    "upper_arm_vertical": 15.0
                ],
                holdDuration: nil,
                transitionHint: "Curl the weight up toward your shoulder"
            ),
            
            // Keyframe 2: Mid-Curl (halfway up)
            Keyframe(
                id: "mid_curl_up",
                name: "Mid Curl",
                description: "Forearm at 90 degrees",
                orderIndex: 1,
                targetAngles: [
                    "elbow_flexion": 90.0,      // Right angle at elbow
                    "shoulder_angle": 20.0,     // Slight forward lean ok
                    "upper_arm_vertical": 165.0
                ],
                tolerances: [
                    "elbow_flexion": 20.0,
                    "shoulder_angle": 15.0,
                    "upper_arm_vertical": 20.0
                ],
                holdDuration: nil,
                transitionHint: "Continue curling to the top"
            ),
            
            // Keyframe 3: Top Position (maximum contraction)
            Keyframe(
                id: "top_position",
                name: "Top Position",
                description: "Maximum curl - squeeze the bicep",
                orderIndex: 2,
                targetAngles: [
                    "elbow_flexion": 45.0,      // Fully curled
                    "shoulder_angle": 25.0,     // Slight forward is ok
                    "upper_arm_vertical": 160.0
                ],
                tolerances: [
                    "elbow_flexion": 15.0,
                    "shoulder_angle": 15.0,
                    "upper_arm_vertical": 25.0
                ],
                holdDuration: 0.5,              // Hold for half second
                transitionHint: "Slowly lower the weight back down"
            ),
            
            // Keyframe 4: Mid-Lower (halfway down)
            Keyframe(
                id: "mid_curl_down",
                name: "Lowering",
                description: "Control the descent",
                orderIndex: 3,
                targetAngles: [
                    "elbow_flexion": 90.0,
                    "shoulder_angle": 20.0,
                    "upper_arm_vertical": 165.0
                ],
                tolerances: [
                    "elbow_flexion": 25.0,      // More tolerance on way down
                    "shoulder_angle": 15.0,
                    "upper_arm_vertical": 20.0
                ],
                holdDuration: nil,
                transitionHint: "Continue to starting position"
            ),
            
            // Keyframe 5: End Position (same as start)
            Keyframe(
                id: "end_position",
                name: "End Position",
                description: "Fully extend to complete the rep",
                orderIndex: 4,
                targetAngles: [
                    "elbow_flexion": 170.0,
                    "shoulder_angle": 15.0,
                    "upper_arm_vertical": 170.0
                ],
                tolerances: [
                    "elbow_flexion": 15.0,
                    "shoulder_angle": 10.0,
                    "upper_arm_vertical": 15.0
                ],
                holdDuration: nil,
                transitionHint: "Start next rep or rest"
            )
        ]
        
        // MARK: - Rep Pattern
        
        // One complete rep follows this keyframe sequence
        let repPattern = [
            "start_position",
            "mid_curl_up",
            "top_position",
            "mid_curl_down",
            "end_position"
        ]
        
        return ExerciseDefinition(
            id: "bicep_curl_\(armSide.lowercased())",
            name: "\(armSide) Arm Bicep Curl",
            description: "Standard bicep curl exercise targeting the biceps brachii",
            angleDefinitions: angleDefinitions,
            keyframes: keyframes,
            repPattern: repPattern
        )
    }
}
