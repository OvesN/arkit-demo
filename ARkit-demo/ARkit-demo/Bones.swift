//
//  Bones.swift
//  ARkit-demo
//
//  Created by veronika ovsyannikova on 20.11.2025.
//

import Foundation

enum Bones: CaseIterable {
    // root / hips / legs
    case rootToHips
    case hipsToLeftUpLeg
    case leftUpLegToLeftLeg
    case leftLegToLeftFoot
    case leftFootToLeftToes
    case leftToesToLeftToesEnd
    case hipsToRightUpLeg
    case rightUpLegToRightLeg
    case rightLegToRightFoot
    case rightFootToRightToes
    case rightToesToRightToesEnd
    
    // hips -> spine
    case hipsToSpine1
    case spine1ToSpine2
    case spine2ToSpine3
    case spine3ToSpine4
    case spine4ToSpine5
    case spine5ToSpine6
    case spine6ToSpine7
    
    // spine -> shoulders / arms (left)
    case spine7ToLeftShoulder1
    case leftShoulderToLeftArm
    case leftArmToLeftForearm
    case leftForearmToLeftHand
    
    // left hand - index finger
    case leftHandToLeftIndexStart
    case leftIndexStartTo1
    case leftIndex1To2
    case leftIndex2To3
    case leftIndex3ToEnd
    
    // left hand - middle finger
    case leftHandToLeftMidStart
    case leftMidStartTo1
    case leftMid1To2
    case leftMid2To3
    case leftMid3ToEnd
    
    // left hand - pinky finger
    case leftHandToLeftPinkyStart
    case leftPinkyStartTo1
    case leftPinky1To2
    case leftPinky2To3
    case leftPinky3ToEnd
    
    // left hand - ring finger
    case leftHandToLeftRingStart
    case leftRingStartTo1
    case leftRing1To2
    case leftRing2To3
    case leftRing3ToEnd
    
    // left hand - thumb
    case leftHandToLeftThumbStart
    case leftThumbStartTo1
    case leftThumb1To2
    case leftThumb2ToEnd
    
    // spine -> neck -> head
    case spine7ToNeck1
    case neck1ToNeck2
    case neck2ToNeck3
    case neck3ToNeck4
    case neck4ToHead
    case headToJaw
    case jawToChin
    
    // head -> left face (eyes, eyelids, eyeball, nose)
    case headToLeftEye
    case leftEyeToLeftEyeLowerLid
    case leftEyeToLeftEyeUpperLid
    case leftEyeToLeftEyeball
    case headToNose
    
    // head -> right face
    case headToRightEye
    case rightEyeToRightEyeLowerLid
    case rightEyeToRightEyeUpperLid
    case rightEyeToRightEyeball
    
    // spine -> shoulders / arms (right)
    case spine7ToRightShoulder1
    case rightShoulderToRightArm
    case rightArmToRightForearm
    case rightForearmToRightHand
    
    // right hand - index finger
    case rightHandToRightIndexStart
    case rightIndexStartTo1
    case rightIndex1To2
    case rightIndex2To3
    case rightIndex3ToEnd
    
    // right hand - middle finger
    case rightHandToRightMidStart
    case rightMidStartTo1
    case rightMid1To2
    case rightMid2To3
    case rightMid3ToEnd
    
    // right hand - pinky finger
    case rightHandToRightPinkyStart
    case rightPinkyStartTo1
    case rightPinky1To2
    case rightPinky2To3
    case rightPinky3ToEnd
    
    // right hand - ring finger
    case rightHandToRightRingStart
    case rightRingStartTo1
    case rightRing1To2
    case rightRing2To3
    case rightRing3ToEnd
    
    // right hand - thumb
    case rightHandToRightThumbStart
    case rightThumbStartTo1
    case rightThumb1To2
    case rightThumb2ToEnd
    
    // Human readable name for a bone (jointFrom-jointTo)
    var name: String {
        return "\(self.jointFromName)-\(self.jointToName)"
    }
    
    var jointFromName: String {
        switch self {
            // root / hips / legs
        case .rootToHips: return "root"
        case .hipsToLeftUpLeg: return "hips_joint"
        case .leftUpLegToLeftLeg: return "left_upLeg_joint"
        case .leftLegToLeftFoot: return "left_leg_joint"
        case .leftFootToLeftToes: return "left_foot_joint"
        case .leftToesToLeftToesEnd: return "left_toes_joint"
        case .hipsToRightUpLeg: return "hips_joint"
        case .rightUpLegToRightLeg: return "right_upLeg_joint"
        case .rightLegToRightFoot: return "right_leg_joint"
        case .rightFootToRightToes: return "right_foot_joint"
        case .rightToesToRightToesEnd: return "right_toes_joint"
            
            // hips -> spine
        case .hipsToSpine1: return "hips_joint"
        case .spine1ToSpine2: return "spine_1_joint"
        case .spine2ToSpine3: return "spine_2_joint"
        case .spine3ToSpine4: return "spine_3_joint"
        case .spine4ToSpine5: return "spine_4_joint"
        case .spine5ToSpine6: return "spine_5_joint"
        case .spine6ToSpine7: return "spine_6_joint"
            
            // spine -> shoulders / left arm
        case .spine7ToLeftShoulder1: return "spine_7_joint"
        case .leftShoulderToLeftArm: return "left_shoulder_1_joint"
        case .leftArmToLeftForearm: return "left_arm_joint"
        case .leftForearmToLeftHand: return "left_forearm_joint"
            
            // left hand - index
        case .leftHandToLeftIndexStart: return "left_hand_joint"
        case .leftIndexStartTo1: return "left_handIndexStart_joint"
        case .leftIndex1To2: return "left_handIndex_1_joint"
        case .leftIndex2To3: return "left_handIndex_2_joint"
        case .leftIndex3ToEnd: return "left_handIndex_3_joint"
            
            // left hand - middle
        case .leftHandToLeftMidStart: return "left_hand_joint"
        case .leftMidStartTo1: return "left_handMidStart_joint"
        case .leftMid1To2: return "left_handMid_1_joint"
        case .leftMid2To3: return "left_handMid_2_joint"
        case .leftMid3ToEnd: return "left_handMid_3_joint"
            
            // left hand - pinky
        case .leftHandToLeftPinkyStart: return "left_hand_joint"
        case .leftPinkyStartTo1: return "left_handPinkyStart_joint"
        case .leftPinky1To2: return "left_handPinky_1_joint"
        case .leftPinky2To3: return "left_handPinky_2_joint"
        case .leftPinky3ToEnd: return "left_handPinky_3_joint"
            
            // left hand - ring
        case .leftHandToLeftRingStart: return "left_hand_joint"
        case .leftRingStartTo1: return "left_handRingStart_joint"
        case .leftRing1To2: return "left_handRing_1_joint"
        case .leftRing2To3: return "left_handRing_2_joint"
        case .leftRing3ToEnd: return "left_handRing_3_joint"
            
            // left hand - thumb
        case .leftHandToLeftThumbStart: return "left_hand_joint"
        case .leftThumbStartTo1: return "left_handThumbStart_joint"
            
            
            // neck / head
        case .spine7ToNeck1: return "spine_7_joint"
        case .neck1ToNeck2: return "neck_1_joint"
        case .neck2ToNeck3: return "neck_2_joint"
        case .neck3ToNeck4: return "neck_3_joint"
        case .neck4ToHead: return "neck_4_joint"
        case .headToJaw: return "head_joint"
        case .jawToChin: return "jaw_joint"
            
            // head -> left face
        case .headToLeftEye: return "head_joint"
        case .leftEyeToLeftEyeLowerLid: return "left_eye_joint"
        case .leftEyeToLeftEyeUpperLid: return "left_eye_joint"
        case .leftEyeToLeftEyeball: return "left_eye_joint"
        case .headToNose: return "head_joint"
            
            // head -> right face
        case .headToRightEye: return "head_joint"
        case .rightEyeToRightEyeLowerLid: return "right_eye_joint"
        case .rightEyeToRightEyeUpperLid: return "right_eye_joint"
        case .rightEyeToRightEyeball: return "right_eye_joint"
            
            // spine -> shoulders / right arm
        case .spine7ToRightShoulder1: return "spine_7_joint"
        case .rightShoulderToRightArm: return "right_shoulder_1_joint"
        case .rightArmToRightForearm: return "right_arm_joint"
        case .rightForearmToRightHand: return "right_forearm_joint"
            
            // right hand - index
        case .rightHandToRightIndexStart: return "right_hand_joint"
        case .rightIndexStartTo1: return "right_handIndexStart_joint"
        case .rightIndex1To2: return "right_handIndex_1_joint"
        case .rightIndex2To3: return "right_handIndex_2_joint"
        case .rightIndex3ToEnd: return "right_handIndex_3_joint"
            
            // right hand - middle
        case .rightHandToRightMidStart: return "right_hand_joint"
        case .rightMidStartTo1: return "right_handMidStart_joint"
        case .rightMid1To2: return "right_handMid_1_joint"
        case .rightMid2To3: return "right_handMid_2_joint"
        case .rightMid3ToEnd: return "right_handMid_3_joint"
            
            // right hand - pinky
        case .rightHandToRightPinkyStart: return "right_hand_joint"
        case .rightPinkyStartTo1: return "right_handPinkyStart_joint"
        case .rightPinky1To2: return "right_handPinky_1_joint"
        case .rightPinky2To3: return "right_handPinky_2_joint"
        case .rightPinky3ToEnd: return "right_handPinky_3_joint"
            
            // right hand - ring
        case .rightHandToRightRingStart: return "right_hand_joint"
        case .rightRingStartTo1: return "right_handRingStart_joint"
        case .rightRing1To2: return "right_handRing_1_joint"
        case .rightRing2To3: return "right_handRing_2_joint"
        case .rightRing3ToEnd: return "right_handRing_3_joint"
            
            // right hand - thumb
        case .rightHandToRightThumbStart: return "right_hand_joint"
        case .rightThumbStartTo1: return "right_handThumbStart_joint"
        case .rightThumb1To2: return "right_handThumb_1_joint"
        case .rightThumb2ToEnd: return "right_handThumb_2_joint"
            
            
        case .leftThumbStartTo1, .leftThumb1To2, .leftThumb2ToEnd:
            // handled below individually to satisfy compiler - fallthrough not allowed in Swift switch
            
            // Fallback (shouldn't happen)
            return ""
        }}
        
        var jointToName: String {
            switch self {
                // root / hips / legs
            case .rootToHips: return "hips_joint"
            case .hipsToLeftUpLeg: return "left_upLeg_joint"
            case .leftUpLegToLeftLeg: return "left_leg_joint"
            case .leftLegToLeftFoot: return "left_foot_joint"
            case .leftFootToLeftToes: return "left_toes_joint"
            case .leftToesToLeftToesEnd: return "left_toesEnd_joint"
            case .hipsToRightUpLeg: return "right_upLeg_joint"
            case .rightUpLegToRightLeg: return "right_leg_joint"
            case .rightLegToRightFoot: return "right_foot_joint"
            case .rightFootToRightToes: return "right_toes_joint"
            case .rightToesToRightToesEnd: return "right_toesEnd_joint"
                
                // hips -> spine
            case .hipsToSpine1: return "spine_1_joint"
            case .spine1ToSpine2: return "spine_2_joint"
            case .spine2ToSpine3: return "spine_3_joint"
            case .spine3ToSpine4: return "spine_4_joint"
            case .spine4ToSpine5: return "spine_5_joint"
            case .spine5ToSpine6: return "spine_6_joint"
            case .spine6ToSpine7: return "spine_7_joint"
                
                // spine -> shoulders / left arm
            case .spine7ToLeftShoulder1: return "left_shoulder_1_joint"
            case .leftShoulderToLeftArm: return "left_arm_joint"
            case .leftArmToLeftForearm: return "left_forearm_joint"
            case .leftForearmToLeftHand: return "left_hand_joint"
                
                // left hand - index
            case .leftHandToLeftIndexStart: return "left_handIndexStart_joint"
            case .leftIndexStartTo1: return "left_handIndex_1_joint"
            case .leftIndex1To2: return "left_handIndex_2_joint"
            case .leftIndex2To3: return "left_handIndex_3_joint"
            case .leftIndex3ToEnd: return "left_handIndexEnd_joint"
                
                // left hand - middle
            case .leftHandToLeftMidStart: return "left_handMidStart_joint"
            case .leftMidStartTo1: return "left_handMid_1_joint"
            case .leftMid1To2: return "left_handMid_2_joint"
            case .leftMid2To3: return "left_handMid_3_joint"
            case .leftMid3ToEnd: return "left_handMidEnd_joint"
                
                // left hand - pinky
            case .leftHandToLeftPinkyStart: return "left_handPinkyStart_joint"
            case .leftPinkyStartTo1: return "left_handPinky_1_joint"
            case .leftPinky1To2: return "left_handPinky_2_joint"
            case .leftPinky2To3: return "left_handPinky_3_joint"
            case .leftPinky3ToEnd: return "left_handPinkyEnd_joint"
                
                // left hand - ring
            case .leftHandToLeftRingStart: return "left_handRingStart_joint"
            case .leftRingStartTo1: return "left_handRing_1_joint"
            case .leftRing1To2: return "left_handRing_2_joint"
            case .leftRing2To3: return "left_handRing_3_joint"
            case .leftRing3ToEnd: return "left_handRingEnd_joint"
                
                // left hand - thumb
            case .leftHandToLeftThumbStart: return "left_handThumbStart_joint"
            case .leftThumbStartTo1: return "left_handThumb_1_joint"
            case .leftThumb1To2: return "left_handThumb_2_joint"
            case .leftThumb2ToEnd: return "left_handThumbEnd_joint"
                
                // neck / head
            case .spine7ToNeck1: return "neck_1_joint"
            case .neck1ToNeck2: return "neck_2_joint"
            case .neck2ToNeck3: return "neck_3_joint"
            case .neck3ToNeck4: return "neck_4_joint"
            case .neck4ToHead: return "head_joint"
            case .headToJaw: return "jaw_joint"
            case .jawToChin: return "chin_joint"
                
                // head -> left face
            case .headToLeftEye: return "left_eye_joint"
            case .leftEyeToLeftEyeLowerLid: return "left_eyeLowerLid_joint"
            case .leftEyeToLeftEyeUpperLid: return "left_eyeUpperLid_joint"
            case .leftEyeToLeftEyeball: return "left_eyeball_joint"
            case .headToNose: return "nose_joint"
                
                // head -> right face
            case .headToRightEye: return "right_eye_joint"
            case .rightEyeToRightEyeLowerLid: return "right_eyeLowerLid_joint"
            case .rightEyeToRightEyeUpperLid: return "right_eyeUpperLid_joint"
            case .rightEyeToRightEyeball: return "right_eyeball_joint"
                
                // spine -> shoulders / right arm
            case .spine7ToRightShoulder1: return "right_shoulder_1_joint"
            case .rightShoulderToRightArm: return "right_arm_joint"
            case .rightArmToRightForearm: return "right_forearm_joint"
            case .rightForearmToRightHand: return "right_hand_joint"
                
                // right hand - index
            case .rightHandToRightIndexStart: return "right_handIndexStart_joint"
            case .rightIndexStartTo1: return "right_handIndex_1_joint"
            case .rightIndex1To2: return "right_handIndex_2_joint"
            case .rightIndex2To3: return "right_handIndex_3_joint"
            case .rightIndex3ToEnd: return "right_handIndexEnd_joint"
                
                // right hand - middle
            case .rightHandToRightMidStart: return "right_handMidStart_joint"
            case .rightMidStartTo1: return "right_handMid_1_joint"
            case .rightMid1To2: return "right_handMid_2_joint"
            case .rightMid2To3: return "right_handMid_3_joint"
            case .rightMid3ToEnd: return "right_handMidEnd_joint"
                
                // right hand - pinky
            case .rightHandToRightPinkyStart: return "right_handPinkyStart_joint"
            case .rightPinkyStartTo1: return "right_handPinky_1_joint"
            case .rightPinky1To2: return "right_handPinky_2_joint"
            case .rightPinky2To3: return "right_handPinky_3_joint"
            case .rightPinky3ToEnd: return "right_handPinkyEnd_joint"
                
                // right hand - ring
            case .rightHandToRightRingStart: return "right_handRingStart_joint"
            case .rightRingStartTo1: return "right_handRing_1_joint"
            case .rightRing1To2: return "right_handRing_2_joint"
            case .rightRing2To3: return "right_handRing_3_joint"
            case .rightRing3ToEnd: return "right_handRingEnd_joint"
                
                // right hand - thumb
            case .rightHandToRightThumbStart: return "right_handThumbStart_joint"
            case .rightThumbStartTo1: return "right_handThumb_1_joint"
            case .rightThumb1To2: return "right_handThumb_2_joint"
            case .rightThumb2ToEnd: return "right_handThumbEnd_joint"
            }
        }
    }


