//
//  ViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/09/23.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//
import UIKit
import CoreData







class ViewController: UIViewController {
    
    var daycounts = 5
    var classcounts = 6
    var startClassTime:[Int] = []   //時限ごとの開始時刻データ
    var finishClassTime:[Int] = []
    
    func numberday(num:Int) ->String{
        switch num{
        case 0:
            return "Mon"
        case 1:
            return "Tues"
        case 2:
            return "Wednes"
        case 3:
            return "Thurs"
        case 4:
            return "Fri"
        default:
            return ""
        }
        
    }
    
    //写真データを格納するディレクトリを作成
    func makeDirectory(){
        let fileManager = FileManager.default
        let DocumentPath = NSHomeDirectory() + "/Documents"
        for day in 0..<daycounts{
            for classes in 0...classcounts{
                let DirectoryPath = DocumentPath + "/" + numberday(num: day) + "\(classes)"
                print(DirectoryPath)
                if fileManager.fileExists(atPath: DirectoryPath) == false{
                    do{
                        try fileManager.createDirectory(atPath: DirectoryPath, withIntermediateDirectories: true, attributes: nil)
                    }catch{
                        print("error")
                    }
                }else{
                    print("file exsist")
                }
            }
        }
    }
    
    //Core Dataから開始時刻と終了時刻を取ってくる
    func getClassTimeData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SettingsTime> = SettingsTime.fetchRequest()
        let SettingsData = try! context.fetch(fetchRequest)
        if !SettingsData.isEmpty{
            for i in 0..<SettingsData.count{
                startClassTime[i] = Int(SettingsData[i].startClassTime)
                finishClassTime[i] = Int(SettingsData[i].finishClassTime)
                
            }
        }
    }
    //現時時刻から何限か返す
    func getClassTime()->Int{
        let now = Date()
        let format = DateFormatter()
        format.dateFormat = "Hmm"
        let StringTime = format.string(from: now)
        let intTime = Int(StringTime)
        
        for i in 0..<classcounts{
          let  ClassTimeRange = startClassTime[i]...finishClassTime[i]
            if ClassTimeRange.contains(intTime!) == true{
                return i+1
            }
        }
        return 0
    }

    
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
        getClassTimeData()
        print(startClassTime)
    }
    
    override func viewDidLoad() {
        makeDirectory()
        startClassTime = [0,0,0,0,0,0]
        finishClassTime = [0,0,0,0,0,0]
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }


}

