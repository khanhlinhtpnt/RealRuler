//
//  ViewController.swift
//  RealRuler
//
//  Created by Linh Huynh on 12/29/18.
//  Copyright © 2018 Linh Huynh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    
    var textNode = SCNNode()
    
    @IBOutlet weak var unitOption: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            removeAllDots()
        }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        let dot  = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        
        material.diffuse.contents = UIColor.red
        
        dot.materials = [material]
        
        let node = SCNNode()
        
        node.geometry = dot
        node.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(node)
        dotNodes.append(node)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[dotNodes.count - 2]
        let end = dotNodes[dotNodes.count - 1]
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z

        let distance = sqrt(a*a + b*b + c*c)
        
        if unitOption.selectedSegmentIndex == 0 {
            updateText(string: String(format: "%0.3fm", distance), at: end.position)
        }
        else {
            updateText(string: String(format: "%0.3fin", distance / 0.0254), at: end.position)
        }
        
    }
    
    func updateText(string text: String, at position: SCNVector3) {
        let text = SCNText(string: text, extrusionDepth: 0.5)
        text.firstMaterial?.diffuse.contents = UIColor.red
        textNode.removeFromParentNode()
        textNode.geometry = text
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.001)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func removeAllDots() {
        for dot in dotNodes {
            dot.removeFromParentNode()
        }
        dotNodes.removeAll()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        removeAllDots()
        textNode.removeFromParentNode()
    }
}
