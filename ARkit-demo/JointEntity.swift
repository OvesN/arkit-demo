
import ARKit
import BodyTracking
import RealityKit
import RKUtilities

final class JointEntity: Entity {
    /// This is used for tracked joints.
    private static let blueSphereComp = makeSphereComponent(color: .blue, radius: 0.025)

    /// This is used for untracked joints.
    private static let greenSphereComp = makeSphereComponent(color: .green, radius: 0.01)

    private let noseLocalTransform = simd_float4x4([[0.9998477, 0.017452404, 0.0, 0.0],
                                                    [-0.017452404, 0.9998477, 0.0, 0.0],
                                                    [0.0, 0.0, 1.0, 0.0],
                                                    [1.4210854e-16, 0.11, -7.632783e-19, 1.0]])

    required init(joint: ThreeDBodyJoint) {
        super.init()

        let default3DBody = ARSkeletonDefinition.defaultBody3D
        guard let jointLocalTransforms = default3DBody.neutralBodySkeleton3D?.jointLocalTransforms else {
            assertionFailure("Could Not access jointLocalTransforms.")
            return
        }

        if joint.isTracked() {
            // Tracked joints look like a larger, blue sphere.
            modelComponent = Self.blueSphereComp
        } else {
            // Untracked joints look like a smaller, green sphere.
            modelComponent = Self.greenSphereComp
        }

        // For each child joint, add one bone that points towards the child joint.
        let childJoints = joint.getChildJoints()
        for childJoint in childJoints {
            // Untracked bones are smaller.
            let boneScale: Float = childJoint.isTracked() ? 1.0 : 0.2

            // Local space refers to a joint's position relative to its parent joint.
            var localTransform = jointLocalTransforms[childJoint.rawValue]

            // For some reason on iOS 15.0 the nose joint's local transform is different between the neutralBodySkeleton3D and the active, real-world tracked body.
            if #unavailable(iOS 16.0),
               childJoint == .nose_joint
            {
                localTransform = noseLocalTransform
            }

            let childPositionRelativeToParent = localTransform.translation

            let distanceToParent = simd_length(childPositionRelativeToParent)

            let bone = BoneEntity(length: distanceToParent)

            addChild(bone)

            bone.scale = [boneScale, boneScale, 1.0]

            bone.look(at: childPositionRelativeToParent, from: .zero, relativeTo: self)

            // Not totally necessary to do this, but it saves memory to remove unnecessary synchronization component. This component is added to Entities by default and is only used in multi-user sessions, which this app does not need.
            visit(using: { $0.synchronization = nil })
        }
    }

    @MainActor required init() {
        fatalError("init() has not been implemented")
    }

    static func makeSphereComponent(color: SimpleMaterial.Color = .blue,
                                    radius: Float = 0.05) -> ModelComponent
    {
        let sphereMesh = MeshResource.generateSphere(radius: radius)
        let sphereMaterial = SimpleMaterial(color: color,
                                            isMetallic: true)
        return ModelComponent(mesh: sphereMesh, materials: [sphereMaterial])
    }
}

final class BoneEntity: Entity {
    private static var cylinderModel = makeCylinder()

    required init(length: Float) {
        super.init()

        // Make the cylinder be the pivot point of the transform.
        // - i.e. We do not want to rotate the cylinder with the pivot point being in the middle / center of mass.
        //  We want the pivot point to be at one of the the ends of the cylinder, so we place its parent at the bottom end.
        // It is more efficient to make the ModelEntity once and then clone it than to make it multiple times.
        let cylinderModel = Self.cylinderModel.clone(recursive: true)

        addChild(cylinderModel)

        // Put the pivot point at the tip of the cylinder instead of the center of the clinder.
        cylinderModel.position = [0, 0, -length / 2]

        // The cylinder is by default a length of 1.0, and points along the Z-axis. Therefore, its Z-Scale will match its Z-length in meters. e.g. If its Z-scale is 0.2, then its length will be 0.2 meters.
        cylinderModel.scale = [1, 1, length]
    }

    @MainActor required init() {
        fatalError("init() has not been implemented")
    }

    private static func makeCylinder() -> ModelEntity {
        // We do Not want our material to be lit / to have shading, so that the individual shapes will be less distinct and look more like one continuous line.
        let cyanUnlitMaterial = UnlitMaterial(color: .cyan)

        let diameter: Float = 0.005
        let cylinderMesh = MeshResource.generateBox(width: diameter, height: diameter, depth: 1.0, cornerRadius: diameter / 2)

        return ModelEntity(mesh: cylinderMesh, materials: [cyanUnlitMaterial])
    }
}
