//
//  Protein_v3_1Tests.swift
//  Protein.v3.1Tests
//
//  Created by Thao P Le on 24/09/2020.
//  Copyright © 2020 Thao P Le. All rights reserved.
//

import XCTest
@testable import Protein_v3_1

class Protein_v3_1Tests: XCTestCase {
    var sut: EduViewController!
    override func setUp(){
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = EduViewController()
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }

    func testDownload() {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //1. given
        let fileURL = URL(string: "https://files.rcsb.org/download/6K03.pdb")!
        let parameter = "6K03"
        //2. when
        sut.download(fileURL: fileURL, parameter: parameter)
        //3.then
        let fm = FileManager.default
        do {
            let documentsUrl =  try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationURL = documentsUrl.appendingPathComponent(parameter + ".pdb")
            try? fm.removeItem(at: destinationURL)// remove the old one, if there is any
            try fm.moveItem(at: destinationURL, to: destinationURL)
            print(destinationURL)
            print("Hello")
            
            XCTAssert(fm.fileExists(atPath: (String(describing: destinationURL))), "File does not exist")
        } catch {
            print("Error")
        }
    }
 }
