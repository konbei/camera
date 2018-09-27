//
//  ClassName.swift
//  camera
//
//  Created by 中西航平 on 2018/09/26.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit

class ClassName: UITableViewController,TextEditedDelegate{
    
    
    

    
    //TableViewで扱う空の配列(ここで初期化したらコンパイル時にエラーはいたのでViewDidLoadで初期化
    var sectionTitles: [String] = []
    public var rowTitles:[String] = []
    public var rowData:[String] = []
    public var cellData:[[String]] = []
    
    
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
        rowTitles = ["1限","2限","3限","4限","5限","6限"]
        rowData = ["1限の名前を入力して下さい","2限の名前を入力して下さい","3限の名前を入力して下さい","4限の名前を入力して下さい","5限の名前を入力して下さい","6限の名前を入力して下さい"]
        cellData = [rowData,rowData,rowData,rowData,rowData]
        
        //自作セル追加
        let classXib = UINib(nibName:"ClassNameTableCell", bundle:nil)
        tableView.register(classXib, forCellReuseIdentifier:"Cell")
        
    }
    

    
    //returnキー押した後の動作(ClassNameTableCellのtextfieldデリゲートメソッドtextFieldDidEndEditing(return内のキーを押した後の動作)からデリゲート)
    func textFieldDidEndEditing(cell: ClassNameTableCell, value: String) {
        let index = tableView.indexPathForRow(at:cell.convert(cell.bounds.origin, to:tableView))//タップしたらタップしたセルのインデックスを得る(動作確認済み)
        
        cellData[index!.section][index!.row] = value
        tableView.reloadData()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     
     */
    
}

