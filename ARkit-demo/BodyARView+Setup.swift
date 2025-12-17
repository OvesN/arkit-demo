import ARKit
import RealityKit
import BodyTracking
import RKUtilities

protocol BodySkeletonRenderable: AnyObject {
    var bodyEntity: BodyEntity3D! { get set }
    var bodyAnchor: BodyAnchor? { get set }
}

extension BodySkeletonRenderable where Self: ARView {
    func setupBodyRendering() {
        let anchor = BodyAnchor(session: session)
        scene.addAnchor(anchor)

        let entity = BodyEntity3D()
        anchor.attach(bodyEntity: entity)

        bodyAnchor = anchor
        bodyEntity = entity

        make3DJoints()
    }

    func make3DJoints() {
        // Keeping track of created joints so we can use them as parents of other joints.
        let trackedJoints = makeTrackedJoints()

        makeUntrackedJoints(trackedJoints)

        // fixFeet(joints: trackedJoints)
    }

    private func makeTrackedJoints() -> [ThreeDBodyJoint: JointEntity] {
        var trackedJoints = [ThreeDBodyJoint: JointEntity]()

        for joint in ThreeDBodyJoint.trackedJoints {
            let jointEnt = JointEntity(joint: joint)

            trackedJoints[joint] = jointEnt

            // * IMPORTANT * This is what is doing most of the work for us.
            bodyEntity.attach(entity: jointEnt, to: joint)
        }

        return trackedJoints
    }

    // For some reason on certain minor versions of iOS 16 the feet do not update their transform values and the default skeleton has them pointing downwards. So we fix this here.
    private func fixFeet(joints: [ThreeDBodyJoint: JointEntity]) {
        if #available(iOS 16.0, *) {
            if let rightFootEntity = joints[.right_foot_joint] {
                rightFootEntity.orientation = simd_quatf(angle: .pi / 2, axis: .yaw) * simd_quatf(angle: .pi / 2, axis: .pitch)
            }

            if let leftFootEntity = joints[.left_foot_joint] {
                leftFootEntity.orientation = simd_quatf(angle: -.pi / 2, axis: .yaw) * simd_quatf(angle: -.pi / 2, axis: .pitch)
            }
        }
    }

    private func makeUntrackedJoints(_ trackedJoints: [ThreeDBodyJoint: JointEntity]) {
        let default3DBody = ARSkeletonDefinition.defaultBody3D

        guard let jointLocalTransforms = default3DBody.neutralBodySkeleton3D?.jointLocalTransforms else {
            assertionFailure("Could Not access jointLocalTransforms.")
            return
        }

        let parentIndices = default3DBody.parentIndices

        let untrackedJoints = ThreeDBodyJoint.allCases.filter { $0.isTracked() == false }

        var untrackedJointEnts = [ThreeDBodyJoint: JointEntity]()

        /// Find the parent joint. It could be tracked or untracked, so we attempt to locate it in the proper dictionary.
        func findParentEnt(for parentJoint: ThreeDBodyJoint) -> Entity? {
            trackedJoints[parentJoint] ?? untrackedJointEnts[parentJoint]
        }

        for untrackedJoint in untrackedJoints {
            let parentIndex = parentIndices[untrackedJoint.rawValue]

            guard
                let parentJoint = ThreeDBodyJoint(rawValue: parentIndex),
                let parentJointEnt = findParentEnt(for: parentJoint)
            else {
                assertionFailure("No parentJointEnt found for joint \(untrackedJoint)")
                return
            }

            // No need to use `bodyEntity.attach` for untracked joints, since their transform values do not change relative to their parent joint.
            let untrackedJointEnt = JointEntity(joint: untrackedJoint)

            parentJointEnt.addChild(untrackedJointEnt)

            untrackedJointEnt.transform = Transform(matrix: jointLocalTransforms[untrackedJoint.rawValue])

            untrackedJointEnts[untrackedJoint] = untrackedJointEnt
        }
    }
}
