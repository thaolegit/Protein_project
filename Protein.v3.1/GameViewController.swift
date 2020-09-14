//
//  GameViewController.swift
//  Protein.v3.1
//
//  Created by Thao P Le on 14/08/2020.
//  Copyright © 2020 Thao P Le. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Foundation
import ReplayKit
import AVFoundation
                                                                                                                                 
class GameViewController: UIViewController, ARSCNViewDelegate, UITextViewDelegate, RPPreviewViewControllerDelegate {
    
  
 //Outlets connections
    @IBOutlet weak var thirdSceneView: ARSCNView!
        let configuration = ARWorldTrackingConfiguration()
        let scene = SCNScene()
    var newAngleZ : Float = 0.0
    var currentAngleZ : Float = 0.0

//Button connections
    
     @IBAction func showButton(_ sender: UIButton) {
             showOptions()
         }
    
    @IBOutlet weak var recordButton: UIButton!
    
    
    @IBAction func cameraButton(_ sender: UIButton) {
        takeScreenshot()
        
    }
    
        
    
    var proteinArray = [String]()
    
    @IBAction func flexCoil(_ sender: UIButton) {
       addProtein(name: "flexCoil")
       proteinArray.append("fCoil")
    }
    
    
    @IBAction func rigCoil(_ sender: UIButton) {
        addProtein(name: "rigCoil")
        proteinArray.append("rCoil")
    }
    
    
    @IBAction func helix(_ sender: UIButton) {
       addProtein(name: "helix")
       proteinArray.append("Helix")
        
    }
    
    
    @IBAction func sheet(_ sender: UIButton) {
       addProtein(name: "sheet")
       proteinArray.append("Sheet")
    }
    
    
    @IBAction func tryButton(_ sender: UIButton) {
        createProtein()
    }
    
    @IBAction func clearButton(_ sender: UIButton) {
            deleteAll()
        }
    
    //Gestures Recognizer
    // Pinch Gestures
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .changed{
                let areaPinched = sender.view as? SCNView
                    let location = sender.location(in: areaPinched)
                    let hitTestResults = thirdSceneView.hitTest(location, options: nil)
                    
                    if let hitTest = hitTestResults.first {
                        let plane = hitTest.node
                        
                        let scaleX = Float(sender.scale) * plane.scale.x
                        let scaleY = Float(sender.scale) * plane.scale.y
                        let scaleZ = Float(sender.scale) * plane.scale.z
                        
                        plane.scale = SCNVector3(scaleX, scaleY, scaleZ)
                        
                        sender.scale = 1
                    }
                }
            }
    // Rotation Gesture
    @IBAction func rotationGesture(_ sender: UIRotationGestureRecognizer) {
        if sender.state == .changed {
                 let areaTouched = sender.view as? SCNView
                 let location = sender.location(in: areaTouched)

                 let hitTestResults = thirdSceneView.hitTest(location, options: nil)
                 
                 if let hitTest = hitTestResults.first {
                     let plane = hitTest.node
                     newAngleZ = Float(-sender.rotation)
                     newAngleZ += currentAngleZ
                     plane.eulerAngles.z = newAngleZ
                 }
             } else if sender.state == .ended {
                     currentAngleZ = newAngleZ
             }
    }
    
    //Pan Gesture
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let areaPanned = sender.view as? SCNView
        let location = sender.location(in: areaPanned)
        let hitTestResults = areaPanned?.hitTest(location, options: nil)
        print("\(String(describing: areaPanned))")
       if let hitTest = hitTestResults?.first {
           if let plane = hitTest.node.parent {
               if sender.state == .changed {
                   let translate = sender.translation(in: areaPanned)
                   plane.localTranslate(by: SCNVector3(translate.x/10000,-translate.y/10000,0.0))
                }
           }
       }
    }
    
    
    //----------------------FUNCITONS BELOW-----------------------

    
//1. Menu Button Functions: Show options when Menu button is clicked
    func showOptions(){
            let openLinkAction = UIAlertAction(title: "More about protein", style: .default){
                (ACTION) in
                self.openLink()
            }
            
            let helpScreenAction = UIAlertAction(title: "Help", style: .default) {
                (ACTION) in
                self.helpScreen()
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            
            AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [openLinkAction, helpScreenAction,cancelAction], completion: nil)
            
        }
       
     // Create functions inside of Menu Button
  
        // 1.1. Function to open link to RCSB
            func openLink(){
                guard let url = URL(string: "https://www.rcsb.org/") else { return }
         UIApplication.shared.open(url)
     }
        // 1.2. Function to pop-up Help screen
            let helpView = UIView(frame:CGRect(x:0, y: 0, width: 400, height: 250))
             func helpScreen (){
                 let helpText = UITextView(frame:CGRect(x:20, y: 20, width: 350, height: 230))
                helpText.text = "1. Tap on fCoil, rCoil, Helix, Sheet to look at each individual polypeptide. \n\n2. Tap on TRY to create a new Protein!\n\n3. Tap on Clear to try again."
      
         
                helpView.backgroundColor = UIColor(red: 0.4, green: 0.36, blue: 0.46, alpha: 1)
                helpView.alpha = 0.8
                helpText.backgroundColor = UIColor(red: 0.4, green: 0.36, blue: 0.46, alpha: 1)
                helpText.alpha = 1
                helpText.textAlignment = .left
                
                helpText.font = .boldSystemFont(ofSize: 20)
                helpText.textColor = UIColor(red: 0.95, green: 0.65, blue: 0.75, alpha: 0.8)
                                   
                self.view.addSubview(helpView)
                helpView.center = self.view.center
                helpView.addSubview(helpText)
                                   
                helpText.layer.cornerRadius = 5
     }
    
    
//2. Record Button Function: Function to record the screen

   @objc func handleTapGesture(){
       stopRecording()
       print("Tap")
       
   }
   
    @objc func handleLongPress() {
       startRecording()
       print("Long pressed")
   }
       // 2.1. Record Screen Function
   let recorder = RPScreenRecorder.shared()
   func startRecording(){
       recorder.startRecording{(error) in
           if let error = error {
               print(error)
           }
       }
   }
       // 2.2. Stop recording Function
   func stopRecording(){
       recorder.stopRecording {(previewVC, error) in
           if let previewVC = previewVC {
           previewVC.previewControllerDelegate = self
           self.present(previewVC, animated: true, completion: nil)
       }
       if let error = error {
           print(error)
       }
       }
   }
func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
      dismiss(animated: true, completion: nil)
  }
  
    

//3. Camera Button Function: take a photo of the screen
    // 3.1. Objective C function to save Image
    @objc func saveImage(_ image:UIImage, error:Error?, context: UnsafeMutableRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        print("Image was saved in the photo gallery")
        //UIApplication.shared.open(URL(string:"photos-redirect://")!): open Camera Library every time after photo is taken
    }
    // 3.2. Functions to take screen shot
    func takeScreenshot(){
        let capturedImage = ARSCNView.snapshot(thirdSceneView!)
        
        UIImageWriteToSavedPhotosAlbum(capturedImage(), self, #selector(saveImage(_:error:context:)), nil)
    }

// 4. Polypeptide Button Functions: To add protein onto the screens when button is pressed
        func addProtein(name: String) {
          
            let proteinScene = SCNScene(named: "models.scnassets/" + name + ".scn")!
           //These models have only 1 rootnode as the model, add cameranode
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
            scene.rootNode.addChildNode(cameraNode)
            
            
            let nodeName = proteinScene.rootNode.childNodes[0].name
            
            guard let proteinNode = proteinScene.rootNode.childNode(withName: nodeName!, recursively: true) else {return}

            
            proteinNode.scale = SCNVector3(x: 0.008, y: 0.008, z: 0.008)
            proteinNode.position = SCNVector3(x: -0.005, y: 0, z: -0.010)
            
            let randomx = Float.random(in: (-Float.pi)...(Float.pi))
            let randomy = Float.random(in: (-Float.pi)...(Float.pi))
            let randomz = Float.random(in: (-Float.pi)...(Float.pi))

            
            proteinNode.eulerAngles = SCNVector3(x: randomx, y:randomy, z:randomz)
            scene.rootNode.addChildNode(proteinNode)
            
            let centerConstraint = SCNLookAtConstraint(target: proteinNode)
            cameraNode.constraints = [centerConstraint]
            
            thirdSceneView.scene = scene
            
        }

    
    func createProtein(){
        clearAll()
        let newProteinName = proteinArray.joined()
        print(newProteinName)
        
        let newProtein = SCNScene(named: "Combinations.scnassets/" + newProteinName + ".scn")
        if newProtein != nil {
            displayText1()
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
            scene.rootNode.addChildNode(cameraNode)
                            
                            
            let nodeName = newProtein?.rootNode.childNodes[0].name
                            
            guard let proteinNode = newProtein?.rootNode.childNode(withName: nodeName!, recursively: true) else {
                         fatalError("Model is not found")
                 }

                   
        proteinNode.scale = SCNVector3(x: 0.008, y: 0.008, z: 0.008)
        proteinNode.position = SCNVector3(x: -0.005, y: 0, z: -0.005)
        scene.rootNode.addChildNode(proteinNode)
                   
            let centerConstraint = SCNLookAtConstraint(target: proteinNode)
            cameraNode.constraints = [centerConstraint]
            
            } else {
            print("Model is not found")
            displayText2()
        }
                   
            thirdSceneView.scene = scene
    }
    

    
    //Function to clear screen
    func clearAll(){
            print("deleting " + String(scene.rootNode.childNodes.count))
            
            for node in scene.rootNode.childNodes
            {
                print(node.name as Any)
                node.removeFromParentNode()
            }
            
        }
    //6. Clear Button Functions: Clear All on screen and in Array
    func deleteAll(){
        clearAll()
        proteinArray.removeAll()
    }
    
    //7. Function to display text
    //When successfully create a new protein
    func displayText1(){
        let newElements = proteinArray.joined(separator: "-")
        let text = SCNText(string: "Congratulations!\nYou have created \na new protein made of \(newElements)", extrusionDepth: 2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemTeal
        text.materials = [material]
        let node = SCNNode()
        node.position = SCNVector3(x: -0.005, y: -0.005, z: -0.01)
        node.scale = SCNVector3(0.0005, 0.0005, 0.0005)
        node.geometry = text
        node.name = "shape"
        thirdSceneView.scene.rootNode.addChildNode(node)
       
    }
     //When unsuccessfully create a new protein
    func displayText2(){
          let newElements = proteinArray.joined(separator: "-")
          let text = SCNText(string: "Sorry!\nThe combination of \(newElements) cannot be made.", extrusionDepth: 2)
          let material = SCNMaterial()
          material.diffuse.contents = UIColor.black
          text.materials = [material]
          let node = SCNNode()
          node.position = SCNVector3(x: -0.007,y: -0.005, z: -0.01)
          node.scale = SCNVector3(0.0005, 0.0005, 0.0005)
          node.geometry = text
          node.name = "shape2"
          thirdSceneView.scene.rootNode.addChildNode(node)
      }
    
    
    
       
        
//---------FUNCTIONS FOR INTERACTION AND DESIGN-------

    //1. Dismiss Help Screen by touching other part of the screen
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch: UITouch? = (touches.first!)
            if touch?.view != helpView{
                self.helpView.isHidden = true
                }
            }

        
    //2. Make Camera Button change after clicked
        
    //3. Lighting and Shading functions
        
    //4. Functions to interact with Protein Models on screen
//--------------OVERRIDE FUNCTIONS BELOW------------------------
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            thirdSceneView.delegate = self
            thirdSceneView.showsStatistics = true
            //thirdSceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            recordButton.addGestureRecognizer(tapGesture)
            recordButton.addGestureRecognizer(longPressGesture)
            
            }

        
        override func viewWillAppear(_ animated: Bool) {
            
            super.viewWillAppear(animated)
            
            
            
            let configuration = ARWorldTrackingConfiguration()
            thirdSceneView.session.run(configuration)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            thirdSceneView.session.pause()
            
        }
        
    }
    extension UIButton {
        open override func draw(_ rect: CGRect) {
            //provide custom style
            self.layer.cornerRadius = 20
            //self.layer.masksToBounds = true
            
        
            
        }
    }






    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


