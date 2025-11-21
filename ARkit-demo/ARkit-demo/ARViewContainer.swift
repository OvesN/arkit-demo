//
//  ARViewContainer.swift
//  ARkit-demo
//
//  Created by veronika ovsyannikova on 20.11.2025.
//

import ARKit
import RealityKit
import SwiftUI

private var bodySkeleton: BodySkeleton?
private let bodySkeletonAnchor = AnchorEntity()

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .ar,
                          automaticallyConfigureSession: true)
        
        view.setupForBodyTracking()
        view.scene.addAnchor(bodySkeletonAnchor)
        return view
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}


extension ARView: ARSessionDelegate {
    func setupForBodyTracking() {
        let conf = ARBodyTrackingConfiguration()
        session.run(conf)
        
        self.session.delegate = self
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
        for anchor in anchors {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                if let skeleton = bodySkeleton {
                    skeleton.update(with: bodyAnchor)
                }
                else {
                    bodySkeleton = BodySkeleton(for: bodyAnchor)
                    bodySkeletonAnchor.addChild(bodySkeleton!)
                }
            }
        }
    }
}
