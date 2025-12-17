//import Foundation
//import MediaPipeTasksVision
//
///// Adapts MediaPipe landmarks to the PoseData protocol
//struct MediaPipePoseData: PoseData {
//    
//    private let landmarks: [NormalizedLandmark]
//    private let imageSize: CGSize
//    let timestamp: TimeInterval
//    let confidence: Float
//    
//    init(landmarks: [NormalizedLandmark], imageSize: CGSize, timestamp: TimeInterval = Date().timeIntervalSince1970) {
//        self.landmarks = landmarks
//        self.imageSize = imageSize
//        self.timestamp = timestamp
//        
//        // Calculate average confidence from visible landmarks
//        let visibilities = landmarks.compactMap { $0.visibility?.floatValue }
//        self.confidence = visibilities.isEmpty ? 0 : visibilities.reduce(0, +) / Float(visibilities.count)
//    }
//    
//    // MARK: - Joint Positions
//    
//    func jointPosition(for joint: UniversalJoint) -> CGPoint? {
//        // Handle computed joints
//        switch joint {
//        case .hipCenter:
//            guard let leftHip = jointPosition(for: .leftHip),
//                  let rightHip = jointPosition(for: .rightHip) else {
//                return nil
//            }
//            return CGPoint(
//                x: (leftHip.x + rightHip.x) / 2,
//                y: (leftHip.y + rightHip.y) / 2
//            )
//            
//        case .shoulderCenter:
//            guard let leftShoulder = jointPosition(for: . leftShoulder),
//                  let rightShoulder = jointPosition(for: . rightShoulder) else {
//                return nil
//            }
//            return CGPoint(
//                x: (leftShoulder.x + rightShoulder.x) / 2,
//                y: (leftShoulder.y + rightShoulder.y) / 2
//            )
//            
//        default:
//            guard let index = joint.mediaPipeIndex,
//                  index < landmarks.count else {
//                return nil
//            }
//            
//            let landmark = landmarks[index]
//            
//            // Check visibility threshold
//            guard (landmark.visibility?.floatValue ?? 0) > 0.5 else {
//                return nil
//            }
//            
//            return CGPoint(
//                x: CGFloat(landmark.x) * imageSize.width,
//                y: CGFloat(landmark.y) * imageSize.height
//            )
//        }
//    }
//    
//    func jointPosition3D(for joint: UniversalJoint) -> SIMD3<Float>?  {
//        // MediaPipe provides limited 3D - we use 2D with estimated z
//        // For most exercises, 2D is sufficient
//        
//        guard let pos2D = jointPosition(for: joint) else {
//            return nil
//        }
//        
//        // Get z from landmark if available
//        var z: Float = 0
//        if let index = joint.mediaPipeIndex, index < landmarks.count {
//            z = landmarks[index].z?.floatValue ?? 0
//        }
//        
//        return SIMD3<Float>(
//            Float(pos2D.x / imageSize.width) * 2 - 1,  // Normalize to -1... 1
//            Float(pos2D.y / imageSize.height) * 2 - 1,
//            z
//        )
//    }
//}
