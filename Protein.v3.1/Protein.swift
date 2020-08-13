//
//  Protein.swift
//  Protein.v1
//
//  Created by Thao P Le on 07/07/2020.
//  Copyright © 2020 Thao P Le. All rights reserved.
//

import Foundation

class Protein {
 
    var name:String
    var seq:String
    var cScore:String
    var para01:String
    
    
    init(name:String, seq:String, cScore:String, para01:String)
    {
        /*self.name = "defaultName"
        self.seq = "defaultSeq"
        self.cScore = "defaultCScore"
        self.para01 = "defaultblarblar"*/
        self.name = name
        self.seq = seq
        self.cScore = cScore
        self.para01 = para01
        
    }
}



/*
var protein = Protein()
protein.name = "flexCoilSheet"
*/
