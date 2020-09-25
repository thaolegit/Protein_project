//
//  downloadTest.swift
//  ProteinARUnitTests
//
//  Created by Thao P Le on 23/09/2020.
//  Copyright © 2020 Thao P Le. All rights reserved.
//

import XCTest
@testable import Protein_v3_1

class downloadTest: XCTestCase {

    var proteindownloaded: Protein!
    func testIfDownloadFunctionWorked(){
        proteindownloaded = Protein()
        let bundle = Bundle(for: downloadTest.self)
    }

}
