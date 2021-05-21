//
//  ViewController.swift
//  ARDicee
//
//  Created by Yuancheng Zhang on 2021/5/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //        let sphere = SCNSphere(radius: 0.2)
        //        let material = SCNMaterial()
        //        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        //        sphere.materials = [material]
        //
        //        let node = SCNNode()
        //        node.position = SCNVector3(0, 0.1, -0.5)
        //        node.geometry = sphere
        //        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        print("Session is supported = \(ARConfiguration.isSupported)")
        print("World Tracking is supported = \(ARWorldTrackingConfiguration.isSupported)")
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
//            ARSCNView raycastQueryFromPoint:allowingTarget:alignment
//           let results = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneInfinite, alignment: .horizontal)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z
                    )
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi * 0.5)
                    let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi * 0.5)
                    diceNode.runAction(SCNAction.rotateBy(
                                        x: CGFloat(randomX * 10),
                                        y: 0.0,
                                        z: CGFloat(randomZ * 10),
                        duration: 0.5
                    ))
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let plantAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(plantAnchor.extent.x), height: CGFloat(plantAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: plantAnchor.center.x, y: 0.0, z: plantAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi * 0.5, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
            print("Plane detected")
        } else {
            return
        }
    }
}
