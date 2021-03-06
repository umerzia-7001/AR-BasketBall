//
//  ViewController.swift
//  AR_BasketBall
//
//  Created by Apple on 02/05/2020.
//  Copyright © 2020 apple. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

   
    @IBOutlet weak var addHoopBtn: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var currentNode:SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
       
        RegisterGestureRecognizer()
    }
    func addBackboard(){
        guard let backboardScene=SCNScene(named:"art.scnassets/hoop.scn")else{
            return
    }
        guard let backboardNode=backboardScene.rootNode.childNode(withName:"backboard",recursively:false)
            else{
                return
        }
        backboardNode.position=SCNVector3(x:0,y:0.5,z:-3)
            
        let physicsShape=SCNPhysicsShape(node:backboardNode,options:[ SCNPhysicsShape.Option.type:SCNPhysicsShape.ShapeType.concavePolyhedron])
        let PhysicsBody=SCNPhysicsBody(type:.static,shape:physicsShape)

        backboardNode.physicsBody=PhysicsBody
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
        
        currentNode=backboardNode
    }
    func horizontalAction(node:SCNNode){
        let leftAction=SCNAction.move(by: SCNVector3(x:-1,y:0,z:0), duration: 3)
        let rightAction=SCNAction.move(by: SCNVector3(x:1,y:0,z:0), duration: 3)
        
        let actionSequence=SCNAction.sequence([leftAction,rightAction])
        node.runAction(SCNAction.repeat(actionSequence,count:4))
    }
    func roundAction(node:SCNNode){
        let upLeft=SCNAction.move(by: SCNVector3(x:1,y:1,z:0), duration: 2)
         let downRight=SCNAction.move(by: SCNVector3(x:1,y:-1,z:0), duration: 2)
         let downLeft=SCNAction.move(by: SCNVector3(x:-1,y:-1,z:0), duration: 2)
         let upRight=SCNAction.move(by: SCNVector3(x:-1,y:1,z:0), duration: 2)
        let actionSequence=SCNAction.sequence([upLeft,downRight,downLeft,upRight])
        node.runAction(SCNAction.repeat(actionSequence,count:4))
    }
   
    func RegisterGestureRecognizer(){
        let tap=UITapGestureRecognizer(target:self,action:#selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }
    
     @objc func handleTap(gestureRecognizer:UIGestureRecognizer){
        //sceneView access then acess center point
        guard let sceneView=gestureRecognizer.view as? ARSCNView else{
                return
            }
            guard let centerPoint=sceneView.pointOfView else{
                return
            }
        let cameraTransform=centerPoint.transform
        let cameraLocation=SCNVector3(x:cameraTransform.m41, y:cameraTransform.m42, z:cameraTransform.m43)
        let cameraOrientation=SCNVector3(x:-cameraTransform.m31,y:-cameraTransform.m32, z:-cameraTransform.m33)
        let cameraPosition=SCNVector3Make(cameraLocation.x+cameraOrientation.x, cameraLocation.y+cameraOrientation.y, cameraLocation.z+cameraOrientation.z)
        
        let ball=SCNSphere(radius:0.15)
        let material=SCNMaterial()
        material.diffuse.contents=UIImage(named:"basketballSkin.png")
        ball.materials=[material]
        let ballNode=SCNNode(geometry: ball)
        ballNode.position=cameraPosition
        
        
        let physicsShape=SCNPhysicsShape(node:ballNode,options:nil)
        let physicsbody=SCNPhysicsBody(type:.dynamic,shape:physicsShape)
        
        ballNode.physicsBody=physicsbody
        
        let forceVector:Float=6
        ballNode.physicsBody?.applyForce(SCNVector3(x:cameraOrientation.x*forceVector,y:cameraOrientation.y*forceVector,z:cameraOrientation.z*forceVector),asImpulse : true)
        
        sceneView.scene.rootNode.addChildNode(ballNode)
        
        
        
        
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

    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @IBAction func addHoop(_ sender: Any) {
        addBackboard()
        addHoopBtn.isHidden=true
    }
    @IBAction func startRoundAction(_ sender: Any) {
        roundAction(node: currentNode)
    }
    
    @IBAction func stopAllActions(_ sender: Any) {
        currentNode.removeAllActions()
        
    }
    
    @IBAction func startHorizontailAction(_ sender: Any) {
        horizontalAction(node: currentNode)
    }
    
}
