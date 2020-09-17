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

class EduViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate, UITextViewDelegate, NSFetchedResultsControllerDelegate, RPPreviewViewControllerDelegate {
    
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
        download()
     }
    
    //Exit Button
    @IBAction func exitButton(_ sender: UIButton) {
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
    
func download(){
              let parameter = textField.text
              // Create destination URL
              let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
                 print("docDire" + String(describing: documentsUrl))
                 let dataPath = documentsUrl.appendingPathComponent("pDBFiles")
                 let destinationURL = dataPath.appendingPathComponent("/" + parameter! + ".pdb")
                 let FileExists = FileManager().fileExists(atPath: destinationURL.path)
                 
                
        
                 //Create URL to the source file you want to download
                   let domain = "https://files.rcsb.org/download/"
                   let fileExt = ".pdb"
                   let fileURL:NSURL = NSURL(string: "\(domain)" + parameter! + "\(fileExt)")!
        
    
                 
                 let sessionConfig = URLSessionConfiguration.default
                 let session = URLSession(configuration: sessionConfig)
                 let request = URLRequest(url:fileURL as URL)
                 let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    DispatchQueue.main.async {
                    
                     if let tempLocalUrl = tempLocalUrl, error == nil {
                         // Success
                         if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                             print("Successfully downloaded. Status code: \(statusCode)")
                            //make a new proteinManagedObject
                            self.proteinManagedObject = Protein(context: self.context)
                                 
                                 //give the attributes from the downloaded file
                            self.proteinManagedObject.name = self.textField.text
                            self.proteinManagedObject.location = String(describing: destinationURL)
                                 do{
                                    try self.context.save()
                                    print(self.proteinManagedObject.name!)
                                    print(self.proteinManagedObject.location!)
                                    self.textView.text = self.proteinManagedObject.name
                                    
                                 } catch {
                                     print("Cannot create a new object")
                                 }
                            
                         }
                        
                       do {
                       
                        try FileManager.default.copyItem(at: tempLocalUrl, to: destinationURL)
                         } catch (let writeError) {
                             print("Error creating a file \(destinationURL) : \(writeError)")
                         }
                         
                     } else {
                      print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
                     }
                 }
               }
             //Check if File exists. If it does, print and do not download
                 if FileExists == true {
                   print("This file was already downloaded.")
                   task.cancel()
                   }
               
           task.resume()
                 
               }
    
        //Save to Core Data

       //4.2. Function to Display pDB file as 3D Models in AR
       //4.3. Function to link downloaded file information to CoreData
       //4.4. Function to fetch some data from the sites (text data)
       
    
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


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  // TRY AND FETCH SOMETHING FROM THE WEB
    //textView for inputting data


    
   

    /* //Get button
    @IBAction func getButton(_ sender: UIButton) {
        get(dataString: "userId")
    }*/
    
    /*struct ResponseModel: Codable{
    var userId: Int
    var id: Int?
    var title: String
    var completed: Bool
}*/
    
    

    
    //Create POST function for both posting and getting the information from the web
    /*func evaluateJavaScript(_ javaScriptString: String,
    completionHandler: ((Any?, Error?) -> Void)? = nil)
    {*/
      
        

    
 
  
    
    
    
    func post() {
        
       textField.isUserInteractionEnabled = true
        //textField.isEditable = true
        //textInputView.endEditing(true)
        
       /* let tap = UITapGestureRecognizer(target:self.view, action: #selector(UIView.endEditing(_:)))
        secondSceneView.addGestureRecognizer(tap)*/
        
        let url = URL(string: "https://www.rcsb.org/")// files.rcsb.org/download/6MK1.pdb
        
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
    
    func getTry(){
           
           let domain = "https://www.rcsb.org/structure/"
           let parameter = "\(textField.text ?? "1111")"
           let myURLString:NSURL = NSURL(string: "\(domain)\(parameter)")!
           print(myURLString)
          // let userType =
           //let myURLString = (userType)"
           guard let myURL:NSURL = NSURL(string: "\(myURLString)") else {
               print ("Error: \(myURLString) doesn't seem to be valid")
               return
           }
       
       
       do{
           let myHTMLString = try String(contentsOf: myURL as URL,  encoding: .ascii)
           print("HTML : \(myHTMLString)")
       } catch let error {
           print("Error: \(error)")
       }
       }
    
   
    /*struct Website {

        var url: URL
        var img: URL
        var title: String

        init(url: URL, img: URL, text: String) {
            self.url = url
            self.img = img
            self.title = text
        }
    }*/
    
        
    
    
   /* func get() {

        
        // Create URL
        let domain = "https://www.rcsb.org/structure/"
        let parameter = "\(textField.text ?? "1111")"
        let myURLString:NSURL = NSURL(string: "\(domain)\(parameter)")!
        print(myURLString)
       // print(url!)
        guard let requestUrl = myURLString else { fatalError() }
        
        /* webView.evaluateJavaScript("document.getElementById(\"contentStructureWeight\").innerHtml;") {(response, Error) in
            if (response != nil) {
                self.textView.text = response as? String
            }
        }*/
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
           DispatchQueue.main.async {

            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                
                if let range = dataString.range(of: "Structure weight:") {
                    
                    _ = dataString[range]
                   
                    let endIndex = dataString.index(range.upperBound, offsetBy: 10)
                    
                    let mySubString = dataString[range.upperBound..<endIndex]
                 
                    //let substring = dataString[..<range.lowerBound] // or str[str.startIndex..<range.lowerBound]
                  print(String(mySubString))
                    self.textView.text = "Weight:" + String(mySubString)// Prints ab
                }
                else {
                  print("String not present")
                }
 
               /* print("Response data string:\n \(dataString)")
                self.textView.text = dataString*/
            }
            
        }
        }
        task.resume()
        
        
    }*/
    
   
    


 
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        textView.text = proteinManagedObject.name
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        textView.delegate = self
        self.textView.reloadInputViews()
        
        textField.delegate = self

        secondSceneView.delegate = self
        secondSceneView.showsStatistics = true
        secondSceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
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

/*extension UIButton {
    open override func draw(_ rect: CGRect) {
        //provide custom style
        self.layer.cornerRadius = 20
        //self.layer.masksToBounds = true
        
    
        
    }
}
*/


/*//WEB FETCHING EXTENSION
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
*/
