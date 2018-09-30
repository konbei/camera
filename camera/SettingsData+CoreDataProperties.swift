//
//  SettingsData+CoreDataProperties.swift
//  camera
//
//  Created by 中西航平 on 2018/09/27.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//
//

import Foundation
import CoreData


extension SettingsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsData> {
        return NSFetchRequest<SettingsData>(entityName: "SettingsData")
    }

    @NSManaged public var name: String?
    @NSManaged public var timeTitle: String?
    @NSManaged public var stime: Int16
    @NSManaged public var ftime: Int16

}
