//
//  SettingsTime+CoreDataProperties.swift
//  camera
//
//  Created by 中西航平 on 2018/09/30.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//
//

import Foundation
import CoreData


extension SettingsTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsTime> {
        return NSFetchRequest<SettingsTime>(entityName: "SettingsTime")
    }

    @NSManaged public var startClassTime: Int16
    @NSManaged public var finishClassTime: Int16

}
