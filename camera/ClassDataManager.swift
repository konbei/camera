//
//  ClassDataManager.swift
//  camera
//
//  Created by 中西航平 on 2018/10/14.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//

import UIKit
import CoreData

class ClassDataManager {
    public func fetchAllClasses() -> [SettingsData2] {
        // CoreDataから全授業を取ってくる
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<SettingsData2> = SettingsData2.fetchRequest()
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            fatalError("failed to read from CoreData. error: \(error)")
        }
    }
}

