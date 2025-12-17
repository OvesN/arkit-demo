import ARKit
import BodyTracking
import RealityKit
import Combine

class KeyframeBodyARView: ARView, BodySkeletonRenderable {
    
    var bodyEntity: BodyEntity3D!
    var bodyAnchor: BodyAnchor?
    private(set) var keyframeMatcher: KeyframeMatcher!
    
    // Publishers for UI updates
    private let matchResultSubject = PassthroughSubject<KeyframeMatchResult?, Never>()
    var matchResultPublisher: AnyPublisher<KeyframeMatchResult?, Never> {
        matchResultSubject.eraseToAnyPublisher()
    }
    
    required init(frame frameRect: CGRect, isRightArm: Bool = true) {
        super.init(frame: frameRect)
        
        keyframeMatcher = KeyframeMatcher(isRightArm: isRightArm)
        
        setupBodyTracking()
        setupBodyRendering()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        keyframeMatcher = KeyframeMatcher(isRightArm: true)
        setupBodyTracking()
        setupBodyRendering()
    }
    
    private func setupBodyTracking() {
        guard ARBodyTrackingConfiguration.isSupported else {
            print("Body tracking not supported on this device")
            return
        }
        
        let configuration = ARBodyTrackingConfiguration()
        configuration.isLightEstimationEnabled = false
        
        // Performance optimizations
        renderOptions.insert(.disableMotionBlur)
        
        session.delegate = self
        session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    func resetExercise() {
        keyframeMatcher.reset()
    }
}



extension KeyframeBodyARView: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
 
            let poseData = ARKitPoseData(bodyAnchor: bodyAnchor, arView: self)
            

            let result = keyframeMatcher.update(with: poseData)
            
        
            matchResultSubject.send(result)
        }
    }
}
