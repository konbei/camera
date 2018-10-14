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
    
    // 画面を自動で回転させるか
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面の向きを指定
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    // 授業一覧
    private var classes: [SettingsData2]?
    
    //曜日と時限数
    private var daycounts = 5
    private var classcounts = 6
    
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
    
    //保存ボタン押した時にCoreDataに名前を保存する
    @IBAction func SaveBotton() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! context.save()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // CoreDataからデータをfetchしてくる
        self.classes = ClassDataManager().fetchAllClasses()
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
        //各行に表示するセルを返す
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)  as! ClassNameTableCell //自作セル登録
        let rowTitle = rowTitles[indexPath.row]
        cell.ClassNumber!.text = rowTitle  //時限セット
        
        let nameDay = self.numberday(num: indexPath.section)
        let period = String(indexPath.row + 1)
        let matchedClass = self.classes?.first { $0.nameday == nameDay && $0.nameclass == period }
        cell.ClassNameText!.text = matchedClass?.classname ?? ""      //名前セット
        
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
        
        //自作セル追加
        let classXib = UINib(nibName:"ClassNameTableCell", bundle:nil)
        tableView.register(classXib, forCellReuseIdentifier:"Cell")
        
    }
    
    
    
    //returnキー押した後の動作(ClassNameTableCellのtextfieldデリゲートメソッドtextFieldDidEndEditing(return内のキーを押した後の動作)からデリゲート)
    func textFieldDidEndEditing(cell: ClassNameTableCell, value: String) {
        
        let index = tableView.indexPathForRow(at:cell.convert(cell.bounds.origin, to:tableView))//タップしたらタップしたセルのインデックスを得る(動作確認済み)
        
        let section = index?.section
        let row = index?.row
        let nameDay = self.numberday(num: section!)
        let period = String(row! + 1)
        
        // indexPathに対応した授業名、曜日、時限を記録する
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newClass = SettingsData2(context: context)
        newClass.classname = value
        newClass.nameday = nameDay
        newClass.nameclass = period
        
        removeDuplicatedClass(newClass)
        self.classes?.append(newClass)
    }
    
    private func removeDuplicatedClass(_ target: SettingsData2) {
        // 同じ曜日、時限の授業を取り除く
        let dup = self.classes?.first { $0.nameday == target.nameday && $0.nameclass == target.nameclass }
        guard let duplicated = dup else {
            return
        }
        
        let index = self.classes?.firstIndex(of: duplicated)
        self.classes?.remove(at: index!)
    }
    
}
/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 
 */
