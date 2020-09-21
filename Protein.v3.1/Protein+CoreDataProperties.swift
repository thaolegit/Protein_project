//
//  Protein+CoreDataProperties.swift
//  Protein.v3.1
//
//  Created by Thao P Le on 21/09/2020.
//  Copyright © 2020 Thao P Le. All rights reserved.
//
//

import Foundation
import CoreData


extension Protein {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Protein> {
        return NSFetchRequest<Protein>(entityName: "Protein")
    }

    @NSManaged public var location: String?
    @NSManaged public var name: String?

}

extension Protein : Identifiable {

}
