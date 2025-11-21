//
//  BodySkeleton.swift
//  ARkit-demo
//
//  Created by veronika ovsyannikova on 20.11.2025.
//

import RealityKit
import ARKit


class BodySkeleton: Entity {
    var joints: [String: Entity] = [:]
    var bones: [String: Entity] = [:]
    
    required init(for bodyAnсhor: ARBodyAnchor){
        super.init()
        
        for jointName in ARSkeletonDefinition.defaultBody3D.jointNames{
            var jointRadius: Float = 0.05
            var jointColor: UIColor = .green
            
            
            // Set color and size based on specific jointName
            // Green joints are actively tracked by ARKit. Yellow joints are not tracked;
            // they just follow the motion of the closest green parent.
            switch jointName {
            case "neck_1_joint", "neck_2_joint", "neck_3_joint", "neck_4_joint", "head_joint",
                 "left_shoulder_1_joint", "right_shoulder_1_joint":
                jointRadius *= 0.5

            case "jaw_joint", "chin_joint",
                 "left_eye_joint", "left_eyeLowerLid_joint", "left_eyeUpperLid_joint",
                 "left_eyeball_joint", "nose_joint",
                 "right_eye_joint", "right_eyeLowerLid_joint", "right_eyeUpperLid_joint",
                 "right_eyeball_joint":
                jointRadius *= 0.2
                jointColor = .yellow

            case let name where name.hasPrefix("spine_"):
                jointRadius *= 0.75

            case "left_hand_joint", "right_hand_joint":
                jointRadius *= 1.0
                jointColor = .green

            case let name where name.hasPrefix("left_hand") || name.hasPrefix("right_hand"):
                jointRadius *= 0.25
                jointColor = .yellow

            case let name where name.hasPrefix("left_toes") || name.hasPrefix("right_toes"):
                jointRadius *= 0.5
                jointColor = .yellow

            default:
                jointRadius = 0.05
                jointColor = .green
            }

            let jointEntity = createJoint(radius: jointRadius, color: jointColor)
            joints[jointName] = jointEntity
            self.addChild(jointEntity)
         }
        
        for bone in Bones.allCases {
            guard let skeletoneBone = createSkeletonBone(bone: bone, bodyAnchor: bodyAnсhor) else {continue}
            
            let boneEntity = createBoneEntity(for: skeletoneBone)
            bones[bone.name] = boneEntity
            self.addChild(boneEntity)
        }
    }
    
    func update(with bodyAnchor: ARBodyAnchor) {
           // root position (world space) from the anchor transform
           let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
           
           // update joint entities: position (world) and orientation
           for jointName in ARSkeletonDefinition.defaultBody3D.jointNames {
               if let jointEntity = joints[jointName],
                  let jointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName)) {
                   
                   // joint transform is relative to the body root; extract translation and convert to world space
                   let jointEntityOffsetFromRoot = simd_make_float3(jointEntityTransform.columns.3)
                   jointEntity.position = jointEntityOffsetFromRoot + rootPosition
                   
                   // extract rotation from the joint's 4x4 matrix and apply as orientation
                   jointEntity.orientation = Transform(matrix: jointEntityTransform).rotation
               }
           }
           
           // update bone entities: position at bone center, and orient to look at the to-joint
           for bone in Bones.allCases {
               let boneName = bone.name
               guard let entity = bones[boneName],
                     let skeletonBone = createSkeletonBone(bone: bone, bodyAnchor: bodyAnchor)
               else { continue }
               
               entity.position = skeletonBone.centerPosition
               // orient the bone so it faces the to-joint; relativeTo: nil sets orientation in world space
               entity.look(at: skeletonBone.toJoint.position, from: skeletonBone.centerPosition, relativeTo: nil)
           }
       }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func createJoint(radius: Float, color: UIColor = .white) -> Entity {
        let mesh = MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: color, roughness: 0.8, isMetallic:false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        return entity
    }
    
 
    private func createSkeletonBone(bone: Bones, bodyAnchor: ARBodyAnchor) -> SkeletonBone? {
        // Get the local transform for each joint (transform relative to the body root)
        guard
            let fromJointEntityTransform = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: bone.jointFromName)),
            let toJointEntityTransform   = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: bone.jointToName))
        else {
            return nil
        }

        // Root position in world coordinates
        let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)

        // Joint positions are provided relative to the body root.
        // Convert each joint's local translation (column.3) into a world position by adding the root position.
        let jointFromEntityOffsetFromRoot = simd_make_float3(fromJointEntityTransform.columns.3)
        let jointFromEntityPosition = jointFromEntityOffsetFromRoot + rootPosition

        let jointToEntityOffsetFromRoot = simd_make_float3(toJointEntityTransform.columns.3)
        let jointToEntityPosition = jointToEntityOffsetFromRoot + rootPosition

        // Create your joint model objects (types assumed from your project)
        let fromJoint = SkeletonJoint(name: bone.jointFromName, position: jointFromEntityPosition)
        let toJoint = SkeletonJoint(name: bone.jointToName,   position: jointToEntityPosition)

        return SkeletonBone(fromJoint: fromJoint, toJoint: toJoint)
    }
    
    private func createBoneEntity(for skeletonBone: SkeletonBone, diameter: Float = 0.04, color: UIColor = .white) -> Entity {
        let mesh = MeshResource.generateBox(size: [diameter, diameter, skeletonBone.length], cornerRadius: diameter / 2)
        let material = SimpleMaterial(color: color, roughness: 0.5, isMetallic: true)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        return entity
    }
}

