//
//  FirstViewController.swift
//  Protein.v3.1
//
//  Created by Thao P Le on 14/08/2020.
//  Copyright © 2020 Thao P Le. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Foundation

class FirstViewController: UIViewController, ARSCNViewDelegate, UITextViewDelegate {

    @IBOutlet weak var firstSceneView: ARSCNView!
    
    
    @IBAction func IntroButton(_ sender: UIButton) {
    }
    
    
    @IBAction func EduButton(_ sender: UIButton) {
    }
    
    
    @IBAction func GameButton(_ sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firstSceneView.delegate = self
        firstSceneView.showsStatistics = true
        //let firstScene = SCNScene(named: "")!
        //firstSceneView.scene = firstScene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        firstSceneView.session.run(configuration)
}
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firstSceneView.session.pause()
}
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
   
}
