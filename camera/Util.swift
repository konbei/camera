//
//  Util.swift
//  camera
//
//  Created by 中西航平 on 2018/10/25.
//  Copyright © 2018 kohei nakanishi. All rights reserved.
//
import UIKit

class Util{
    let documentPath = NSHomeDirectory() + "/Documents"
    let dayCounts = 6
    let classCounts = 7
    let fileManager = FileManager.default
    
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
        case 5:
            return "Satur"
        case 6:
            return "Sun"
        default:
            return ""
        }
    }
    
    private func stringInt(int:String)->Int{
        let splitNumbers = (int.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
        let number = splitNumbers.joined()
        return Int(number)!
    }
    
    public func loadImage(selectedDirectoryName:String)->[(name:String,date:String,modify:Date,image:UIImage?)]?{
        let holderDirectory = documentPath + "/" + selectedDirectoryName
        var fileNames:[String] = []
        var file:[(name:String,date:String,modify:Date,image:UIImage?)] = []
        
        //ディレクトリからファイルの名前を取ってくる
        if selectedDirectoryName == "All"{
            for day in 0...dayCounts{
                let directoryPath = documentPath + "/" + numberday(num: day)
                do{
                    try fileNames = FileManager.default.contentsOfDirectory(atPath: directoryPath)
                    if fileNames.count != 0{
                        for i in 0..<fileNames.count{
                            var item:NSDictionary?
                            do{
                                item = try fileManager.attributesOfItem(atPath: directoryPath + "/" + fileNames[i]) as NSDictionary?
                            }catch{
                            }
                            file.append((name: fileNames[i], date: numberday(num:day), modify: (item?.fileCreationDate())!, image: nil))
                        }
                    }
                }catch{
                }
                for classes in 0...classCounts{
                    let directoryPath = documentPath + "/" + numberday(num: day) + "\(classes)"
                    do{
                        try fileNames = fileManager.contentsOfDirectory(atPath: directoryPath)
                        if fileNames.count != 0{
                            for i in 0..<fileNames.count{
                                var item:NSDictionary?
                                do{
                                    item = try fileManager.attributesOfItem(atPath: directoryPath + "/" + fileNames[i]) as NSDictionary?
                                }catch{
                                }
                                
                                file.append((name: fileNames[i], date: numberday(num:day) + "\(classes)", modify: (item?.fileCreationDate())!, image: nil))
                            }
                        }
                    }catch{
                    }
                }
            }
        }else{
            do{
                try fileNames = fileManager.contentsOfDirectory(atPath: holderDirectory)
                for i in 0..<fileNames.count{
                    var item:NSDictionary?
                    do{
                        item = try fileManager.attributesOfItem(atPath: holderDirectory + "/" + fileNames[i]) as NSDictionary?
                    }catch{
                    }
                    file.append((name: fileNames[i], date: selectedDirectoryName, modify: (item?.fileCreationDate())!, image: nil))
                }
            }catch{
                fileNames = []
            }
        }
        
        for i in 0..<file.count{
            for j in (i+1..<file.count).reversed(){
                if stringInt(int: file[j-1].name) < stringInt(int: file[j].name){
                    let temp = file[j]
                    file[j] = file[j-1]
                    file[j-1] = temp
                }
            }
        }
        
        //ファイルパスからファイルデータ(写真イメージ)を取ってくる
        if selectedDirectoryName == "All"{
            for i in 0..<file.count{
                let filePath = documentPath + "/" + file[i].date + "/" + file[i].name
                file[i].image = UIImage(contentsOfFile:filePath)!
            }
        }else{
            for i in 0..<fileNames.count{
                let fileDirectory = holderDirectory + "/" + file[i].name
                if let image = UIImage(contentsOfFile:fileDirectory){
                    file[i].image = image
                }
            }
        }
        
        return file
    }
    
}
