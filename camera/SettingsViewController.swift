//
//  SettingsViewController.swift
//  camera
//
//  Created by 中西航平 on 2018/09/25.
//  Copyright © 2018年 kohei nakanishi. All rights reserved.
//

import UIKit

//テーブルビュデータ


//入力した開始時間と終了時間をそれぞれ別の配列に格納
var stime = Array(repeating: 0, count: 7)
var ftime = Array(repeating: 0, count: 7)

class SettingsViewController: UITableViewController {
    
    //TableViewで扱う空の配列(ここで初期化したらコンパイル時にエラーはいたのでViewDidLoadで初期化
    var sectionTitle: [String] = []
    public var section:[String] = []
    public  var tableData:[[String]] = []

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //セクション毎の行数を返す
        let sectionData = tableData[section]
        return sectionData.count
       
    }
    
  override   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //各行に表示するセルを返す
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let sectionData = tableData[(indexPath as NSIndexPath).section]
        let cellData = sectionData[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = cellData
      
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
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //テーブルデータ初期化
        sectionTitle = ["1限","2限","3限","4限","5限","6限"]
        section = ["開始時刻","終了時刻"]
        tableData = [section,section,section,section,section,section]
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showdatepicker" {
            //タップしたセルのセクションと行数をdatePickerクラスに送る
            if let indexpath = self.tableView.indexPathForSelectedRow{
                    (segue.destination as! SdatePickerviewController).selctedsection = indexpath.section
                (segue.destination as! SdatePickerviewController).selectedrow = indexpath.row
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    */

}
