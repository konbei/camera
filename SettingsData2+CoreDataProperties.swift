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

    @NSManaged public var nameday: String?   //授業のの曜日
    @NSManaged public var nameclass: String? //授業の時限
    @NSManaged public var classname: String?  //授業の名前
    
   

}
