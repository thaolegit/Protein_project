//
//  People.swift
//  Person Data
//
//  Created by Thao P Le on 11/02/2020.
//  Copyright © 2020 Thao P Le. All rights reserved.
//

import Foundation

class ProteinArray {
    var data : [Protein]!
    
    init(){
        //initalize data
        
 
        data = [
            Protein(name: "flexCoil", seq: "GGGGSGGGGSGGGGS", cScore: "1", para01: "good"),
            Protein(name: "rigCoil", seq: "EAAAKEAAAKEAAAK", cScore: "2", para01: "good"),
            Protein(name: "helix", seq: "MSVKELEDKVEELLSKNYHLENEVARLKKLVGER", cScore: "3", para01: "good"),
            Protein(name: "sheet", seq: "ATYFTYYSA", cScore: "4", para01: "good")
            
            ]
        
    }
    

}
