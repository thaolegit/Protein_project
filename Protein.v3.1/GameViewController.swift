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

class GameViewController: UIViewController, ARSCNViewDelegate, UITextViewDelegate {
    
  
 //Outlets connections
    @IBOutlet weak var thirdSceneView: ARSCNView!
        let configuration = ARWorldTrackingConfiguration()
        let scene = SCNScene()

//Button connections
    
     @IBAction func showButton(_ sender: UIButton) {
             showOptions()
         }
    
    @IBAction func recordButton(_ sender: UIButton) {
    }
    
    @IBAction func cameraButton(_ sender: UIButton) {
        takeScreenshot()
        
    }
    
    
    @IBAction func fCoilButton(_ sender: Any) {
            //clearAll()
            addProtein(name: "flexCoil")
        }

    @IBAction func rCoilButton(_ sender: Any) {
            //clearAll()
            addProtein(name: "rigCoil")
        }
        
    @IBAction func helixButton(_ sender: Any) {
            //clearAll()
            addProtein(name: "helix")
        }
        
        
    @IBAction func sheetButton(_ sender: Any) {
            //clearAll()
            addProtein(name: "sheet")
        }
        
 
        
    @IBAction func clearButton(_ sender: UIButton) {
            clearAll()
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
            let helpView = UIView(frame:CGRect(x:0, y: 0, width: 400, height: 300))
             func helpScreen (){
                 let helpText = UITextView(frame:CGRect(x:20, y: 20, width: 350, height: 230))
                helpText.text = "Click on fCoil, rCoil, Helix, Sheet to look at each individual polypeptide. \nHold and drag the polypeptide on top of each other to create a new Protein. Tap on TRY to create the new Protein! "
      
         
                helpView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
                helpView.alpha=0.8
                helpText.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
                helpText.alpha=0.8
                helpText.textAlignment = .left
                helpText.font = .boldSystemFont(ofSize: 20)
                helpText.textColor = UIColor.black
                                   
                self.view.addSubview(helpView)
                helpView.center = self.view.center
                helpView.addSubview(helpText)
                                   
                helpText.layer.cornerRadius = 5
     }
    
    
//2. Record Button Function: Function to record the screen
    // 2.1. Record Screen Function
    // 2.2. Save video Function
    

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
            
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
            scene.rootNode.addChildNode(cameraNode)
            
            
            let nodeName = proteinScene.rootNode.childNodes[0].name
            
            let proteinNode = proteinScene.rootNode.childNode(withName: nodeName!, recursively: true)

            
            proteinNode!.scale = SCNVector3(x: 0.008, y: 0.008, z: 0.008)
            proteinNode!.position = SCNVector3(x: -0.005, y: 0, z: -0.005)
            scene.rootNode.addChildNode(proteinNode!)
            
            let centerConstraint = SCNLookAtConstraint(target: proteinNode)
            cameraNode.constraints = [centerConstraint]
            
            thirdSceneView.scene = scene
            
            
        }

    
    func createProtein(){
        clearAll()
        let newProteinName = proteinArray.joined()
        print(newProteinName)
        let newProtein = SCNScene(named: "Combinations.scnassets/" + newProteinName + ".scn")!
        
        let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
            scene.rootNode.addChildNode(cameraNode)
                   
                   
        let nodeName = newProtein.rootNode.childNodes[0].name
                   
            guard let proteinNode = newProtein.rootNode.childNode(withName: nodeName!, recursively: true) else {
                fatalError("Model is not found")
        }

                   
        proteinNode.scale = SCNVector3(x: 0.008, y: 0.008, z: 0.008)
        proteinNode.position = SCNVector3(x: -0.005, y: 0, z: -0.005)
        scene.rootNode.addChildNode(proteinNode)
                   
            let centerConstraint = SCNLookAtConstraint(target: proteinNode)
            cameraNode.constraints = [centerConstraint]
                   
            thirdSceneView.scene = scene
    }
    
    /*func createProtein(proteinName: String){
   //Display the new structure from combinations folder
        let newProtein = SCNScene(named:"Combinations.scnassets/" + proteinName + ".scn")!
        
        let name1 = "fCoil"
        let name2 = "rCoil"
        let name3 = "Helix"
        let name4 = "Sheet"
        
        var proteinName = name1 + name2 + name3 + name4
        if name1 == nil {
            proteinName = name2 + name3 + name4
        }
        if name2 == nil {
            proteinName = name1 + name3 + name4
        }
        if name3 == nil {
            proteinName = name1 + name2 + name4
        }
        if name4 == nil{
            proteinName = name1 + name2 + name3
        }
        
        
        
        
    }*/
    
//6. Clear Button Functions: Clear All
    func clearAll(){
            print("deleting " + String(scene.rootNode.childNodes.count))
            
            for node in scene.rootNode.childNodes
            {
                print(node.name as Any)
                node.removeFromParentNode()
            }
            
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


