import ARKit
import RealityKit
import simd

/// Adapts ARKit body anchor data to the PoseData protocol
struct ARKitPoseData: PoseData {
    
    private let bodyAnchor: ARBodyAnchor
    private let arView: ARView?
    let timestamp: TimeInterval
    let confidence: Float = 0.95
    
    init(bodyAnchor: ARBodyAnchor, arView: ARView?  = nil) {
        self.bodyAnchor = bodyAnchor
        self.arView = arView
        self.timestamp = Date().timeIntervalSince1970
    }
    

    
    func jointPosition(for joint: UniversalJoint) -> CGPoint? {
        guard let transform = jointTransform(for: joint),
              let arView = arView else {
            // If no AR view, return normalized 2D from 3D projection
            if let pos3D = jointPosition3D(for: joint) {
                return CGPoint(x: CGFloat(pos3D.x), y: CGFloat(pos3D.y))
            }
            return nil
        }
        
        // Project 3D position to screen coordinates
        let worldPosition = bodyAnchor.transform * transform
        let position3D = SIMD3<Float>(
            worldPosition.columns.3.x,
            worldPosition.columns.3.y,
            worldPosition.columns.3.z
        )
        
        if let screenPoint = arView.project(position3D) {
            return CGPoint(x: CGFloat(screenPoint.x), y: CGFloat(screenPoint.y))
        }
        
        return nil
    }
    
    func jointPosition3D(for joint: UniversalJoint) -> SIMD3<Float>? {
        // Handle computed joints
        switch joint {
        case .hipCenter:
            guard let leftHip = jointPosition3D(for: . leftHip),
                  let rightHip = jointPosition3D(for: .rightHip) else {
                return nil
            }
            return (leftHip + rightHip) / 2
            
        case .shoulderCenter:
            guard let leftShoulder = jointPosition3D(for: .leftShoulder),
                  let rightShoulder = jointPosition3D(for: .rightShoulder) else {
                return nil
            }
            return (leftShoulder + rightShoulder) / 2
            
        default:
            guard let transform = jointTransform(for: joint) else {
                return nil
            }
            
            let worldTransform = bodyAnchor.transform * transform
            return SIMD3<Float>(
                worldTransform.columns.3.x,
                worldTransform.columns.3.y,
                worldTransform.columns.3.z
            )
        }
    }
    
    // MARK: - Private Helpers
    
    private func jointTransform(for joint: UniversalJoint) -> simd_float4x4? {
        guard let jointName = joint.arKitJointName else { return nil }
        
        let skeleton = bodyAnchor.skeleton
        
        // Try to find the joint by name
        let jointIndex = skeleton.definition.index(for: ARSkeleton.JointName(rawValue: jointName))
        guard jointIndex != NSNotFound else {
            return nil
        }
        
        return skeleton.jointModelTransforms[jointIndex]
    }
}
