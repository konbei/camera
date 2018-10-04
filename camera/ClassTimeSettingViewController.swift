//
//  SettingsViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/09/25.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit
import CoreData
//テーブルビュデータ


//入力した開始時間と終了時間をそれぞれ別の配列に格納


class ClassTimeSettingViewController: UITableViewController,DatePickerViewDelegate {
    
  //  var a = UITableView.cellForRow()
    
    
    
    private var daycounts = 5
    private var classcounts = 6
    
    //TableViewで扱う空の配列(ここで初期化したらコンパイル時にエラーはいたのでViewDidLoadで初期化
    private var sectionTitle: [String] = []  //1限、2限...
    var startClassTime:[Int] = []   //時限ごとの開始時刻データ
    var finishClassTime:[Int] = []  //時限ごとの終了時刻データ
    

    @IBAction func saveButton(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SettingsTime> = SettingsTime.fetchRequest()
        let SettingsData = try! context.fetch(fetchRequest)
        if !SettingsData.isEmpty{
            for i in 0..<SettingsData.count{
                
                SettingsData[i].startClassTime = Int16(startClassTime[i])
                SettingsData[i].finishClassTime = Int16(finishClassTime[i])
                do{
                    try context.save()
                }catch{
                    print(error)
                }
            }
            
        }else{
            //Core Dataにデータ格納してない時
            for row in 0..<classcounts{
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let SettingData = SettingsTime(context:context)
                SettingData.startClassTime = Int16(startClassTime[row])
                SettingData.finishClassTime = Int16(finishClassTime[row])
                print(SettingData.startClassTime)
                do{
                    try context.save()
                }catch{
                    print(error)
                }
                
            }
            
        }
    }
    
    //開始時間と終了時間をCore Dataに格納
    func Save(){
      
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SettingsTime> = SettingsTime.fetchRequest()
        let SettingsData = try! context.fetch(fetchRequest)
        if !SettingsData.isEmpty{
            for i in 0..<SettingsData.count{
                
                SettingsData[i].startClassTime = Int16(startClassTime[i])
                SettingsData[i].finishClassTime = Int16(finishClassTime[i])
                do{
                    try context.save()
                }catch{
                    print(error)
                }
            }
            
        }else{
            //Core Dataにデータ格納してない時
            for row in 0..<classcounts{
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let SettingData = SettingsTime(context:context)
                SettingData.startClassTime = Int16(startClassTime[row])
                SettingData.finishClassTime = Int16(finishClassTime[row])
                print(SettingData.startClassTime)
                do{
                    try context.save()
                }catch{
                    print(error)
                }
                
            }
            
        }
    }
    //開始時刻と終了時刻をCoreDataから取得
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
    
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
        getClassTimeData()
        // taskTableViewを再読み込みする
       tableView.reloadData()
    }
    
    //時間をH:mm のStringに変換して返す
    func convertStringTime(time:Int) -> String{
        let stringtime = String(time)
        let zero = stringtime.startIndex
        let zeroo = stringtime.index(zero,offsetBy:0)
        var start1 = stringtime.index(zero,offsetBy:0)
        var start2 = stringtime.index(zero,offsetBy:0)
        var end = stringtime.index(zero, offsetBy: 0)
        
        if stringtime.count == 4{
            start1 = stringtime.index(zero, offsetBy: 1)
            start2 = stringtime.index(zero, offsetBy: 2)
            end = stringtime.index(zero, offsetBy: 3)
        }else if stringtime.count == 3{
            start1 = stringtime.index(zero, offsetBy: 0)
            start2 = stringtime.index(zero, offsetBy: 1)
            end = stringtime.index(zero, offsetBy: 2)
        }else{
            return "0:\(stringtime)"
        }
        return "\(stringtime[zeroo...start1]):\(stringtime[start2...end])"
    }
   
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //セクション毎の行数を返す
    
        return 2 //開始時刻と終了時刻
       
    }
    
  override   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //各行に表示するセルを返す
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.row == 0{
            cell.textLabel?.text = "開始時刻：" + convertStringTime(time: startClassTime[indexPath.section])
        }else{
            cell.textLabel?.text = "終了時刻：" + convertStringTime(time: finishClassTime[indexPath.section])
        }
        
      
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        //セクション数を返す
         return sectionTitle.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        //セクションタイトルを返す
        return sectionTitle[section]
    }
    
    //オリジナルDatePickerをインスタンス化
    let animatedDatePicker = AnimatedDatePickerView()
    
    
    //datepickerのcancelとDoneを押した時の動作
    
    func datePickerViewDidCancel(picker: AnimatedDatePickerView) {
        picker.hide()
    }
    
    func datePickerViewDidComplete(picker: AnimatedDatePickerView) {
        let format2 = DateFormatter()
        format2.dateFormat = "Hmm"
        let StringTime = format2.string(from: picker.picker.date)
        let time = Int(StringTime)
        
        if let indexpath = self.tableView.indexPathForSelectedRow{
            if indexpath.row == 0 {
                startClassTime[indexpath.section] = time!
            }else{
                finishClassTime[indexpath.section] = time!
            }
    
        }
        self.tableView.reloadData()
        picker.hide()
    }
    
  
    
    //行がタップされた時の動作
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        animatedDatePicker.delegate = self
        animatedDatePicker.center = self.view.center
        view.addSubview(animatedDatePicker)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //テーブルデータ初期化
        sectionTitle = ["1限","2限","3限","4限","5限","6限"]

         startClassTime = [2359,2359,2359,2359,2359,2359]
         finishClassTime = [2359,2359,2359,2359,2359,2359]
        
    }
}
