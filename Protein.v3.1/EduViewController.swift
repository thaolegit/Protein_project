//
//  ViewController.swift
//  Protein.v2
//
//  Created by Thao P Le on 08/07/2020.
//  Copyright © 2020 Thao P Le. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Foundation
import WebKit
import CoreData
import ReplayKit
import AVFoundation

class EduViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate, RPPreviewViewControllerDelegate{
    
 // ------------------VARIABLES DECLARTION-----------------------
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      
    var proteinManagedObject : Protein! = nil
      
    var entity: NSEntityDescription!=nil
      
      var frc : NSFetchedResultsController<NSFetchRequestResult>! = nil
      
      func makeRequest() -> NSFetchRequest<NSFetchRequestResult>{
          let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Protein")
          let sorter = NSSortDescriptor(key: "name", ascending: true)
          request.sortDescriptors = [sorter]
          
          return request
      }
    
    
    /*func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        proteinManagedObject.name = context.name
        }*/
    
    
    

    
    
    let configuration = ARWorldTrackingConfiguration()
    
    let scene = SCNScene()
    var newAngleZ : Float = 0.0
    var currentAngleZ : Float = 0.0

//----------------------OUTLET CONNECTIONS-------------------------
    //AR Scene
    @IBOutlet weak var secondSceneView: ARSCNView!
    
    //TextField to input the Protein Name
    @IBOutlet weak var textField: UITextField!
     
     
     //textView for displaying fetched data
     @IBOutlet weak var textView: UITextView!
    
    
//----------------------BUTTON CONNECTIONS--------------------------
    
    //Menu Button with options using Alert Service
    @IBAction func menuButton(_ sender: UIButton) {
        showOptions()
    }
    
    //Record Butotn to record 3D onscreen
   
    @IBOutlet weak var recordButton: UIButton!
    
    //Camera Button to capture the screen and save to Photo Library
    @IBAction func cameraButton(_ sender: AnyObject) {
           if let cameraButton : UIButton = sender as? UIButton {
                     cameraButton.isSelected = !cameraButton.isSelected
                     if (cameraButton.isSelected){
                         cameraButton.tintColor = UIColor(red: 0.95, green: 0.65, blue: 0.75, alpha: 1)//change to pink colour
                         takeScreenshot()//action
                         cameraButton.tintColor = UIColor(red: 0.4, green: 0.36, blue: 0.46, alpha: 1)//change back to original colour
                             
                         } else {
                         cameraButton.tintColor = UIColor(red: 0.4, green: 0.36, blue: 0.46, alpha: 1)
                 }
                 }
    }
     
    //Get Button to get the pDB files and display
     @IBAction func getButton(_ sender: UIButton) {
    //download(fileURL: fileURL, parameter: parameter)
    getDownloadURL()
    displayProteinfake(name: textField.text!)
     
     }
    
    //Exit Button
    @IBAction func exitButton(_ sender: UIButton) {
    }
    
    
    @IBAction func clearButton(_ sender: UIButton) {
        secondSceneView.scene = scene
        print("deleting " + String(scene.rootNode.childNodes.count))
        
        for node in scene.rootNode.childNodes
        {
            print(node.name as Any)
            node.removeFromParentNode()
        }
        
    }
    
 //----------------------FUNCTIONS TO ENABLE INTERACTIONS---------------
 //Gestures Recognizer
   //Pinch Gesture
    @IBAction func pinchGesture(_ sender:
    UIPinchGestureRecognizer) {
    if sender.state == .changed{
            let areaPinched = sender.view as? SCNView
                let location = sender.location(in: areaPinched)
                let hitTestResults = secondSceneView.hitTest(location, options: nil)
                
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

                    let hitTestResults = secondSceneView.hitTest(location, options: nil)
                    
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
      if let hitTest = hitTestResults?.first {
          if let plane = hitTest.node.parent {
              if sender.state == .changed {
                  let translate = sender.translation(in: areaPanned)
                  plane.localTranslate(by: SCNVector3(translate.x/10000,-translate.y/10000,0.0))
               }
          }
      }
    }
    
    
    
//------------FUNCTIONS THAT MAKE ACTIONS---------------------------
   
    func displayProteinfake(name: String) {
        let proteinScene = SCNScene(named: "Sample.scnassets/"  + name + ".dae")
        if proteinScene == nil {
            print("Model does not exist")
            displayText(name: name)
        } else {
            
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
            scene.rootNode.addChildNode(cameraNode)
            
            let node = proteinScene!.rootNode
            node.scale = SCNVector3(x: 0.0008, y: 0.0008, z: 0.0008)
            
            
            let node1 = proteinScene?.rootNode.childNode(withName: "node_1", recursively: true)!
            node1!.scale = SCNVector3(x: 0.0008, y: 0.0008, z: 0.0008)
        
            let centerConstraint = SCNLookAtConstraint(target: node)
            cameraNode.constraints = [centerConstraint]
            secondSceneView.scene = proteinScene!
        }
    }

    //idea of the function that should be able to display the protein if there is a converter
    func displayProtein(name: String) {
        let proteinScene = SCNScene(named: proteinManagedObject.location! + "/"  + name + ".dae")
        if proteinScene == nil {
            print("Model does not exist")
            displayText(name: name)
        } else {
            
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
            scene.rootNode.addChildNode(cameraNode)
            
            let node = proteinScene!.rootNode
            node.scale = SCNVector3(x: 0.0008, y: 0.0008, z: 0.0008)
            
            
            let node1 = proteinScene?.rootNode.childNode(withName: "node_1", recursively: true)!
            node1!.scale = SCNVector3(x: 0.0008, y: 0.0008, z: 0.0008)
        
            let centerConstraint = SCNLookAtConstraint(target: node)
            cameraNode.constraints = [centerConstraint]
            secondSceneView.scene = proteinScene!
        }
    }
    func displayText(name: String){
        let text = SCNText(string: name + " does not exist...Try another!", extrusionDepth: 2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.4, green: 0.36, blue: 0.46, alpha: 1)
        text.materials = [material]
        let node = SCNNode()
        node.position = SCNVector3(x: -0.005, y: -0.005, z: -0.01)
        node.scale = SCNVector3(0.0005, 0.0005, 0.0005)
        node.geometry = text
        node.name = "shape"
        secondSceneView.scene.rootNode.addChildNode(node)
       
    }
    
    
    
    
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
            
                let pDB101Action = UIAlertAction(title: "PDB 101", style: .default) {
                                   (ACTION) in
                    self.pdb101()
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                
                AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [openLinkAction, helpScreenAction, pDB101Action, cancelAction], completion: nil)
                
            }
           
         // Create functions inside of Menu Button
      
        // 1.1. Function to open link to RCSB
                func openLink(){
                    guard let url = URL(string: "https://www.rcsb.org/") else { return }
             UIApplication.shared.open(url)
         }
    
    
        // 1.2. Function to pop-up Help screen
                //Make helpView a global variable for usage later.
                let helpView = UIView(frame:CGRect(x:0, y: 0, width: 400, height: 250))
                            func helpScreen (){
                                let helpText = UITextView(frame:CGRect(x:20, y: 20, width: 350, height: 230))
                               helpText.text = "1. Type in the box the name of Protein that you want. \n\n2. Tap on GET to get the structure of it. \n\n3. Play with it!"
                     
                        
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
                            
                               helpView.layer.cornerRadius = 10
                               //helpText.layer.cornerRadius = 5
                    }
               
        
         
            // 1.3. Functions to open pDB 101
                func pdb101(){
                    guard let url = URL(string: "http://pdb101.rcsb.org/") else { return }
                    UIApplication.shared.open(url)
                }
        
        
    //2. Record Button Function: Function to record the screen
        // objective-C function to handle the Gesture Recognizer
        //Tap Gesture
    @objc func handleTapGesture(){
     stopRecording()
     recordButton.tintColor = UIColor(red: 0.4, green: 0.36, blue: 0.46, alpha: 1)
     print("Tap")
     }
        //Long press gesture
    @objc func handleLongPress() {
     startRecording()
     recordButton.tintColor = UIColor.red
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
        // 2.2. Stop recording Function and show the preview screen
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
    // 2.3. Dismiss the preview screen
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
            //Enable this to open camera every time photo is taken
            //UIApplication.shared.open(URL(string:"photos-redirect://")!)
        }
        // 3.2. Functions to take screen shot
        func takeScreenshot(){
            let capturedImage = ARSCNView.snapshot(secondSceneView!)
            
            UIImageWriteToSavedPhotosAlbum(capturedImage(), self, #selector(saveImage(_:error:context:)), nil)
        }
    
//4. Get Button Functions: Download PDB files from the PDB Bank and Display them
    //4.1. Download Functions: To download and save PDB files to Documents Directory after user input text
    

    var task: URLSessionTask!
    
    func getDownloadURL() {
        //Create URL to the source file to download
        let parameter = textField.text
        let domain = "https://files.rcsb.org/download/"
        let fileExt = ".pdb"
        let fileURL = URL(string: "\(domain)" + parameter! + "\(fileExt)")!
        print(fileURL)
        download(fileURL: fileURL, parameter: parameter!)
    }
        
    func download(fileURL:URL, parameter: String){
        //Use URLSession and downloadTask
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: fileURL)
        let task = session.downloadTask(with: request) { temporaryURL, response, error in
                //Get the httpresonse code to make sure file exists
                if let statusCode = (response as? HTTPURLResponse)?.statusCode{
                    print("Successfully downloaded. Status code:\(statusCode)")
                }else {
                    return
                }
                guard let temporaryURL = temporaryURL, error == nil else {
                    print(error ?? "Unknown error")
                    return
                }
                    do {
                    //download file and save as pre-defined format
                    let documentsUrl =  try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let destinationURL = documentsUrl.appendingPathComponent(parameter + ".pdb")
                    
                        /*
                        //Enable (1) and (2) to move downloaded file to the main app
                        //(1) Create the path to the main app's Bundle
                        let newFolderURL = Bundle.main.bundleURL
                        let newFileURL = newFolderURL.appendingPathComponent("/Sample.scnassets" + parameter! + ".pdb")
                        */
                        
                    //manage the downloaded files
                    let manager = FileManager.default
                    try? manager.removeItem(at: destinationURL)// remove the old one, if there is any
                    try manager.moveItem(at: temporaryURL, to: destinationURL)// move the new one to destinationURL
                    print(destinationURL)
                        /*//(2) Move to app bundle
                         try manager.moveItem(at: temporaryURL, to: newFileURL)// move the new one to destinationURL*/
                
                    //Save Files information to Core Data
                    self.saveContext(name:parameter, location: String(describing: documentsUrl))
                
                }
                catch let moveError {
                    print("\(moveError)")
                }
        }
        task.resume()
    }
    
    func saveContext(name: String, location: String) {
        //proteinManagedObject = frc.object(at: IndexPath(row: 0, section: 0)) as? Protein
        proteinManagedObject = Protein(context: context)
        proteinManagedObject.name = name
        proteinManagedObject.location = location
        do {
            try context.save()
            print("Data saved to CoreData")
        } catch {
            print("Cannot create a new object")
        }
    }
    
   /* func getText(){
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let archiveURL = dir.appendingPathComponent("Text").appendingPathExtension("txt")
            print(archiveURL)
        
        do{
                title = try! String(contentsOfFile: String(describing: archiveURL), encoding: .utf8)
                print("Response data string")
            if let range = title!.range(of: "TITLE ") {
                     
                _ = title![range]
                     
                     // get more data
                let endIndex = title!.index(range.lowerBound, offsetBy: 10)
                let mySubstring = title![range.lowerBound..<endIndex]
                    
                   
                     print(String(mySubstring))
                     //self.textView.text = "Molecular weight:" + String(mySubstring)
                 }
                 else {
                   print("String not present")
                }
    
        }
        
    }
    }*/
    
    
   /* func copyFiles(pathFromDocument : String, pathDestBundle: String) {
        if let pdbFileURL = Bundle.main.url(forResource: textField.text, withExtension: ".dae", subdirectory: "Sample.scnassets") {
            print(pdbFileURL)
        }
        let pathFromDocument = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let pathDestBundle = Bundle.main.url(forResource: textField.text, withExtension: ".dae", subdirectory: "Sample.scnassets")
        let fileManagerIs = FileManager.default
        do {
            let filelist = try fileManagerIs.contentsOfDirectory(atPath: pathFromDocument)
            try? fileManagerIs.copyItem(atPath: pathFromDocument, toPath: pathDestBundle)

            for filename in filelist {
                try? fileManagerIs.copyItem(atPath: "\(pathFromDocument)/\(filename)", toPath: "\(pathDestBundle)/\(filename)")
            }
        } catch {
            print("\nError\n")
        }
    }*/
    
    
    
    
       
    
//---------FUNCTIONS FOR INTERACTION AND DESIGN-------
 //1. Dismiss keyboard after entering protein's name
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
//2. Dismiss Help Screen by touching other part of the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = (touches.first!)
        if touch?.view != helpView{
            self.helpView.isHidden = true
            }
    }


    
    
    
    
    
    
    
    
    
    
    
    
    

  // TRY AND FETCH SOMETHING FROM THE WEB WITH POST REQUEST

    func post() {
        
       textField.isUserInteractionEnabled = true

        let url = URL(string: "https://www.rcsb.org/")
        
        guard let requestURL = url else { fatalError() }


        //Prepare URL Request Object
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"

        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "search-bar-input-text=\(String(describing: textField.text))";

        //Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        print(url!)
        //Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            DispatchQueue.main.async {
            //Check for Error
            if let error = error {
                print ("Error took place \(error)")
                return
            }
         //Convert HTTP Response Data to a String
                 /* if let data = data, let dataString = String(data: data, encoding: .utf8){
                      //print("Response data string:\n \(dataString)")
                      if let range = dataString.range(of: " weight:</B>") {
                          
                          _ = dataString[range]
                          
                          // get more data
                          let endIndex = dataString.index(range.upperBound, offsetBy: 10)
                          let mySubstring = dataString[range.upperBound..<endIndex]
                         
                        
                          print(String(mySubstring))
                          self.textView.text = "Molecular weight:" + String(mySubstring)
                      }
                      else {
                        print("String not present")
                      }
                  }*/
        }
        }
        task.resume()
        
    }
    

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //textView.delegate = self
        //self.textView.reloadInputViews()
        
        textField.delegate = self

        secondSceneView.delegate = self
        secondSceneView.showsStatistics = true
        //secondSceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            recordButton.addGestureRecognizer(tapGesture)
            recordButton.addGestureRecognizer(longPressGesture)
            
        //make the frc and fetch
               frc = NSFetchedResultsController(fetchRequest: makeRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
               frc.delegate = self
               
               do {
                   try frc.performFetch()
               } catch {
                   print("frc cannot fetch")
               }
        /*// populate the fileds if update
            if proteinManagedObject != nil{
                textField.text = proteinManagedObject.name
                             }*/
            
        }
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        secondSceneView.session.run(configuration)
        textField.delegate = self
        textField.returnKeyType = .done
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        secondSceneView.session.pause()
        
    }
    
}

