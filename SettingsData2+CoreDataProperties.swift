//
//  SettingsData2+CoreDataProperties.swift
//  camera
//
//  Created by 中西航平 on 2018/09/30.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//
//

import Foundation
import CoreData


extension SettingsData2 {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsData2> {
        return NSFetchRequest<SettingsData2>(entityName: "SettingsData2")
    }

    @NSManaged public var nameday: String?
    @NSManaged public var nameclass: String?
    @NSManaged public var classname: String?
    @NSManaged public var stime: Int16
    @NSManaged public var ftime: Int16
   

}
