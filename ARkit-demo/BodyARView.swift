import ARKit
import BodyTracking
import RealityKit
import SwiftUI

class BodyARView: ARView, BodySkeletonRenderable {
    var bodyEntity: BodyEntity3D!
    var bodyAnchor: BodyAnchor?

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)

        setupBodyRendering()
        runNewConfiguration()
    }

    func runNewConfiguration() {
        guard ARBodyTrackingConfiguration.isSupported else {
            assertionFailure("3D Body Tracking is not supported on this device.")
            return
        }
        // automatically enables both finding 3D-ARBodyAnchors, and 2D-frame-semantics body detection.
        let configuration = ARBodyTrackingConfiguration()

        configuration.isLightEstimationEnabled = false

        // Disable costly post processing for performance.
        renderOptions.insert(.disableMotionBlur)

        session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }

    // required function.
    @available(*, unavailable)
    @objc dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
