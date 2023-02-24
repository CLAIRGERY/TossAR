//
//  ViewController.swift
//  TossAR
//
//  Created by Ludovic Clairgery on 24/02/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addBasket()
        
        
        registerGestureRecognizer()
    }
    
    func registerGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer){
        //scene view to be accessed
        //access the point of view of the scene view ....the center point
        guard let sceneView = gestureRecognizer.view as? ARSCNView else{
            return
        }
        
        guard let centerPoint = sceneView.pointOfView else{
            return
        }
        
        // transform matrix
        // the orientation
        // the location of camera
        // we need the orientation and location to determine the position of the camera and its at this point which we want the ball is placed
        let cameraTransform = centerPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41, y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31, y: -cameraTransform.m32, z: -cameraTransform.m33)
        // x1+x2, y1+y2, z1+z2
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.x + cameraOrientation.x)
        
        guard let ballScene = SCNScene(named: "art.scnassets/Paperball2.scn") else{
            return
        }
        guard let ballNode = ballScene.rootNode.childNode(withName: "Paperball", recursively: false) else{
            return
        }
        //let material = SCNMaterial()
        //material.diffuse.contents = UIImage(named: "notebook.png")
        //ballNode.geometry!.materials = [material]
        
        ballNode.position = SCNVector3(x: 0,y: 0,z: -2)
        
        sceneView.scene.rootNode.addChildNode(ballNode)
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody =  SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        
        ballNode.physicsBody = physicsBody
        let forceVector:Float = 6
        
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraPosition.x * forceVector, y: cameraPosition.y * forceVector, z: cameraPosition.z * forceVector), asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(ballNode)
        
    }
    
    
    func addBasket(){
        guard let basketScene = SCNScene(named: "art.scnassets/trashbin23.scn") else{
            return
        }
        guard let basketNode = basketScene.rootNode.childNode(withName: "untitled_14_23_22", recursively: false) else{
            return
            
        }
        basketNode.position = SCNVector3(x: 0,y: -2,z: -2)
        
        let physicsShape = SCNPhysicsShape(node: basketNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        
        basketNode.physicsBody = physicsBody
        
        
        sceneView.scene.rootNode.addChildNode(basketNode)
        horizontalAction(node: basketNode)
    }
    func horizontalAction(node: SCNNode){
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        
        node.runAction(SCNAction.repeat(actionSequence, count: 4))
}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
