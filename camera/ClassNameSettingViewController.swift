//
//  ClassName.swift
//  camera
//
//  Created by 中西航平 on 2018/09/26.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit
import CoreData


class ClassNameSettingViewController: UITableViewController,TextEditedDelegate{

    //曜日と時限数
    private var daycounts = 5
    private var classcounts = 6
    
    private var MonClassName:[String] = []
    private var TuesClassName:[String] = []
    private var WedClassName:[String] = []
    private var ThursClassName:[String] = []
    private var FriClassName:[String] = []
    
    //数字に対応する曜日のStringを返す
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
    
    
    //数字に対応する曜日の配列を返す
    func dayname(num:Int)->[String]{
        switch num{
        case 0:
            return MonClassName
        case 1:
            return TuesClassName
        case 2:
            return WedClassName
        case 3:
            return ThursClassName
        case 4:
            return FriClassName
        default:
            return MonClassName
        }
    }
  
    //Core Data から授業の名前を取ってくる
    func getNmaeData() {
        for day in 0..<daycounts{
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<SettingsData2> = SettingsData2.fetchRequest()
            let predicate = NSPredicate(format:"%K = %@","nameday",numberday(num: day)) //指定した曜日の名前データを取ってくる
            fetchRequest.predicate = predicate
            
            let SettingsData = try! context.fetch(fetchRequest)
            //曜日ごとの名前データを取得
            if(!SettingsData.isEmpty){
                for i in 0..<SettingsData.count{
                    switch day{
                    case 0:
                        MonClassName[i] = SettingsData[i].classname!
                        
                    case 1:
                        TuesClassName[i] = SettingsData[i].classname!
                        
                    case 2:
                        WedClassName[i] = SettingsData[i].classname!
                        
                    case 3:
                        ThursClassName[i] = SettingsData[i].classname!
                        
                    case 4:
                        FriClassName[i] = SettingsData[i].classname!
                        
                    default:
                        break
                    }
                    
                    do{
                        try context.save()
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
    //保存ボタン押した時にCoreDataに名前を保存する
    @IBAction func SaveBotton() {
        for day in 0..<daycounts {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<SettingsData2> = SettingsData2.fetchRequest()
            let predicate = NSPredicate(format:"%K = %@","nameday",numberday(num: day)) //曜日ごとに名前を取ってくる
            fetchRequest.predicate = predicate
            
            let SettingsData = try! context.fetch(fetchRequest)
            print(SettingsData.count)
            if !SettingsData.isEmpty{
                for i in 0..<SettingsData.count{
                    
                    SettingsData[i].classname = dayname(num: day)[i]  //曜日の名前データを格納
                    
                }
                do{
                    try context.save()
                }catch{
                    print(error)
                }
                
            }else{
                for row in 0..<classcounts{
                    //データない時、に曜日、名前、授業時限を順番に格納
                    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    
                    let SData2 = SettingsData2(context: context)
                    
                    SData2.classname = cellData[day][row]
                    SData2.nameday = numberday(num: day)
                    SData2.nameclass = "\(day + 1)"
                    do{
                        try context.save()
                    }catch{
                        print(error)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
       getNmaeData()
        // ttableViewを再読み込みする
       tableView.reloadData()
    }

    //TableViewで扱う空の配列(ここで初期化したらコンパイル時にエラーはいたのでViewDidLoadで初期化
    private var sectionTitles: [String] = [] //月火...
    private var rowTitles:[String] = []     //1限,2限。...
    private var cellData:[[String]] = []    //曜日ごとの名前データ
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       //行数を返す
        return rowTitles.count
        
    }
    
    override   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        cellData = [MonClassName,TuesClassName,WedClassName,ThursClassName,FriClassName]
        //各行に表示するセルを返す
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)  as! ClassNameTableCell //自作セル登録
        let rowTitle = rowTitles[indexPath.row]
        cell.ClassNumber!.text = rowTitle  //時限セット
        
        let name = cellData[indexPath.section][indexPath.row]
        cell.ClassNameText!.text = name      //名前セット
        
        cell.delegate = self
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        //セクション数を返す
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        //セクションタイトルを返す
        return sectionTitles[section]
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //テーブルデータ初期化
        sectionTitles = ["月曜","火曜","水曜","木曜","金曜"]
        rowTitles = ["1限:","2限:","3限:","4限:","5限:","6限:"]
        MonClassName = ["","","","","",""]
        TuesClassName = ["","","","","",""]
        WedClassName = ["","","","","",""]
        ThursClassName = ["","","","","",""]
        FriClassName = ["","","","","",""]
        
        cellData = [MonClassName,TuesClassName,WedClassName,ThursClassName,FriClassName]

    
        
  
        //自作セル追加
        let classXib = UINib(nibName:"ClassNameTableCell", bundle:nil)
        tableView.register(classXib, forCellReuseIdentifier:"Cell")
        
    }
    

    
    //returnキー押した後の動作(ClassNameTableCellのtextfieldデリゲートメソッドtextFieldDidEndEditing(return内のキーを押した後の動作)からデリゲート)
    func textFieldDidEndEditing(cell: ClassNameTableCell, value: String) {
        
        let index = tableView.indexPathForRow(at:cell.convert(cell.bounds.origin, to:tableView))//タップしたらタップしたセルのインデックスを得る(動作確認済み)
        
        let section = index?.section
        let row = index?.row
        
        
       
        switch section{
        case 0:
             MonClassName[row!] = value
            
        case 1:
            TuesClassName[row!] = value
            
        case 2:
             WedClassName[row!] = value
            
        case 3:
            ThursClassName[row!] = value
            
            
        case 4:
            FriClassName[row!] = value
            
        default:
            break
        }
        
        tableView.reloadData()
        }

}
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     
     */
    



