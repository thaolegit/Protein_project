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

class EduViewController: UIViewController, ARSCNViewDelegate, UITextViewDelegate {
    
    var proteinData: Protein!
    
    let configuration = ARWorldTrackingConfiguration()
    
    let scene = SCNScene()
    
    
    @IBOutlet weak var secondSceneView: ARSCNView!
    
    @IBAction func cameraButton(_ sender: UIButton) {        takeScreenshot()
    }
    
    
    
    @IBAction func recordButton(_ sender: UIButton) {
    }
    
    
    @IBAction func exitButton(_ sender: UIButton) {
    }
    

    
    @IBAction func menuButton(_ sender: UIButton) {
        showOptions()
    }
    
    
    
    //Functions to show options for the menu
    func showOptions(){
        let fCoilAction = UIAlertAction(title: "Help", style: .default){
            (ACTION) in
            self.addProtein(name: "flexCoil")
        }
        
        let rCoilAction = UIAlertAction(title: "Information", style: .default) {
            (ACTION) in
            self.addProtein(name: "rigCoil")
            
        }
        
        let helixAction = UIAlertAction(title: "About us", style: .default){
            (ACTION) in
            self.addProtein(name: "helix")
        }
        
        let sheetAction = UIAlertAction(title: "Whatever", style: .default) {
            (ACTION) in self.addProtein(name:"sheet")
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [fCoilAction, rCoilAction, helixAction, sheetAction, cancelAction], completion: nil)
        
    }
    
   // Create functions for the menu button
    
    
    
    //Functions for the camera button
        //Function to save the image
    @objc func saveImage(_ image:UIImage, error:Error?, context: UnsafeMutableRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        print("Image was saved in the photo gallery")
        //UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
      
    func takeScreenshot(){
        let capturedImage = ARSCNView.snapshot(secondSceneView!)
        
        UIImageWriteToSavedPhotosAlbum(capturedImage(), self, #selector(saveImage(_:error:context:)), nil)
        /*UIGraphicsBeginImageContextWithOptions(
            CGSize(width: view.bounds.width, height: view.bounds.height),
            false,
            2
        )

        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        UIImageWriteToSavedPhotosAlbum(screenshot, self, #selector(saveImage(_:error:context:)), nil)*/
    }
      
    
    
    
    
    
    
    
    
  // TRY AND FETCH SOMETHING FROM THE WEB
    //textView for inputting data
    @IBOutlet weak var textInputView: UITextView!

    
    
    
    //textView for displaying fetched data
    @IBOutlet weak var textView: UITextView!
   
    //Post Button
    @IBAction func postButton(_ sender: UIButton) {
        post()
    }
    
    @IBAction func getButton(_ sender: UIButton) {
        get()
    }
    /* //Get button
    @IBAction func getButton(_ sender: UIButton) {
        get(dataString: "userId")
    }*/
    
    struct ResponseModel: Codable{
    var userId: Int
    var id: Int?
    var title: String
    var completed: Bool
}
    
    //Create POST function for both posting and getting the information from the web
    
    func post() {
        
        textInputView.isEditable = true
        textInputView.isUserInteractionEnabled = true
        
        let url = URL(string: "https://www.rcsb.org")
            //structure/\( String(describing: textInputView.text))")
        guard let requestURL = url else { fatalError() }


        //Prepare URL Request Object
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"

        //HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "search-bar-input-text=\(String(describing: textInputView.text))";

        //Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);

        //Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            DispatchQueue.main.async {
            //Check for Error
            if let error = error {
                print ("Error took place \(error)")
                return
            }
            //Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8){
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
            }
        }
        }
        task.resume()
        
    }
    
    
    
    func get() {
        // Create URL
        let url = URL(string: "https://files.rcsb.org/download/6MK1\( String(describing: textInputView.text)).pdb")
        guard let requestUrl = url else { fatalError() }
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
                
                /*
                if let range = dataString.range(of: "weight:") {
                    let substring = dataString[dataString.startIndex..<range.lowerBound]
                  //let substring = dataString[..<range.lowerBound] // or str[str.startIndex..<range.lowerBound]
                  print(substring)  // Prints ab
                }
                else {
                  print("String not present")
                }
 */
                print("Response data string:\n \(dataString)")
                self.textView.text = dataString
            }
            
        }
        }
        task.resume()
        
        
    }
    
   
    

    
    func addProtein(name: String) {
        secondSceneView.delegate = self
        secondSceneView.showsStatistics = true
        
        let proteinScene = SCNScene(named: "models.scnassets/" + name + ".scn")!
        
        // proteinData.name = name
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
        
        
        let nodeName = proteinScene.rootNode.childNodes[0].name
        
        let proteinNode = proteinScene.rootNode.childNode(withName: nodeName!, recursively: true)
        
        
        
        
        proteinNode!.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        proteinNode!.position = SCNVector3(x: -0.005, y: 0, z: -0.005)
        scene.rootNode.addChildNode(proteinNode!)
        
        let centerConstraint = SCNLookAtConstraint(target: proteinNode)
        cameraNode.constraints = [centerConstraint]
        
        secondSceneView.scene = scene
        
        
    }
    
    
   /* func showChoices(){
        let fCoilAction = UIAlertAction(title: "fCoil", style: .default){
            (ACTION) in
            self.removeProtein(name: "flexCoil")
        }
    
        let rCoilAction = UIAlertAction(title: "rCoil", style: .default) {
            (ACTION) in
            self.removeProtein(name: "rigCoil")
     
        }
        
        let helixAction = UIAlertAction(title: "Helix", style: .default){
            (ACTION) in
            self.removeProtein(name: "helix")
        }
        
        let sheetAction = UIAlertAction(title: "Sheet", style: .default) {
            (ACTION) in self.removeProtein(name:"sheet")
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [fCoilAction, rCoilAction, helixAction, sheetAction, cancelAction], completion: nil)
        
    }*/
    
  // Create function for removing all protein from screen
    func removeProtein(name: String){
        //let proteinScene = SCNScene(named: "models.scnassets/" + name + ".scn")!
        //let nodeName = proteinScene.rootNode.childNodes[0].name
        
        // let proteinNode = proteinScene.rootNode.childNode(withName: nodeName!, recursively: true)
        scene.rootNode.childNode(withName: name, recursively: true)?.removeFromParentNode()
        //scene.rootNode.removeFromParentNode()
        
    }
    
   /* //DISPLAYING TEXT ON SCREEN
    func showText() {
    let text = SCNText(string: "Hello", extrusionDepth: 1)
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.systemPink
    text.materials = [material]
        
    let textNode = SCNNode()
    textNode.position = SCNVector3(0,0,0)
    textNode.scale = SCNVector3 (0.01, 0.01, 0.01)
    textNode.geometry = text

    sceneView.scene.rootNode.addChildNode(textNode)
    }*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        textView.delegate = self
        self.textView.reloadInputViews()

        secondSceneView.delegate = self
        secondSceneView.showsStatistics = true
        secondSceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        
        let configuration = ARWorldTrackingConfiguration()
        secondSceneView.session.run(configuration)
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
