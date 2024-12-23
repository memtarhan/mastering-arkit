//
//  ViewController.swift
//  App1
//
//  Created by Mehmet Tarhan on 23.12.2024.
//

import ARKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)

        addBox()
        addTapGesture()
        addPanGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)

        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)

        sceneView.scene.rootNode.addChildNode(boxNode)
    }

    func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func addPanGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handleTap(withGestureRecognizer recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, options: nil)

        if let node = hitTestResults.first?.node {
            node.removeFromParentNode()
            return
        }

        guard let raycastQuery = sceneView.raycastQuery(from: tapLocation, allowing: .estimatedPlane, alignment: .any),
              let raycastResult = sceneView.session.raycast(raycastQuery).first else { return }

        let translation = raycastResult.worldTransform.translation
        addBox(x: translation.x, y: translation.y, z: translation.z)
    }
    
    @objc func handlePan(withGestureRecognizer recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .possible:
            print("possible")
        case .began:
            print("began")
        case .changed:
            print("changed")
            let tapLocation = recognizer.location(in: sceneView)
            guard let raycastQuery = sceneView.raycastQuery(from: tapLocation, allowing: .estimatedPlane, alignment: .any),
                  let raycastResult = sceneView.session.raycast(raycastQuery).first else { return }
            let worldTransform = SCNMatrix4(raycastResult.worldTransform)
            let hitTestResults = sceneView.hitTest(tapLocation, options: nil)
            guard let node = hitTestResults.first?.node else { return }
            node.setWorldTransform(worldTransform)
            
        case .ended:
            print("ended")
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        case .recognized:
            print("recognized")
        @unknown default:
            break
        }
        
        
    }
}

extension float4x4 {
    var translation: SIMD3<Float> {
        SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}


/*
 
 Differences Between hitTest and raycast

Purpose and Functionality
– hitTest: Used for detecting intersections between
–
a 2D screen point and virtual objects or feature
points in the 3D AR scene. It’s primarily about
interaction with elements that are already rendered
in the AR environment.
– raycast: Designed to find intersections between a 2D
–
screen point and real-world surfaces as understood
by the AR framework. It’s more about placing new
objects or understanding the physical environment.
Accuracy and Efficiency
– hitTest: Earlier versions of ARKit relied heavily on
–
this method, but it may not always provide the most
accurate results, especially for surface detection.
– raycast: Introduced in later versions of ARKit, it
–
offers more precise and reliable detection of real-
world surfaces, thanks to improved algorithms and
better integration with ARKit’s spatial understanding.
Use of Feature Points
– hitTest: Can detect feature points, which are
–
points automatically identified by ARKit on
surfaces. However, it’s less efficient in
understanding the context or the type of surface.
– raycast: Focuses more on plane detection (like
–
floors or tables) rather than individual feature
points, making it better for understanding larger
surface areas.
 
 Supported ARKit Versions
 – hitTest: Available from the earliest versions
 –
 of ARKit
 – raycast: raycast: Introduced in later versions (ARKit 3.0
 –
 and above), offering more advanced features for
 newer AR applications
 
 
 Use Cases
 •
 •
 hitTest Use Cases
 – Interacting with Virtual Objects: Selecting or
 –
 manipulating virtual objects already placed in the
 AR scene, such as picking up, moving, or resizing a
 virtual item
 – Legacy AR Applications: Maintaining older AR
 –
 apps built on previous versions of ARKit, where
 updating to newer methods might not be feasible
 – Simple Surface Detection: For basic AR experi-
 –
 ences where high precision in surface detection is
 not critical.
 raycast Use Cases
 – Placing New Virtual Objects: Precisely positioning
 –
 new virtual objects on real-world surfaces, like
 placing furniture in an AR-based interior design app
 – Advanced Surface Detection: Creating experi-
 –
 ences that require a nuanced understanding of the
 environment, such as games or applications where
 virtual objects interact closely with physical
 surroundings.
 
 – Spatial Mapping and Environment
 –
 Understanding: In applications where a detailed
 understanding of the physical space is crucial, such
 as navigation aids or educational tools that overlay
 information onto the physical world.
 
 */
